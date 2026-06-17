import { Order, OrderStatus } from '../models/Order';
import { HttpService } from '../services/HttpService';

function toNum(val: string | number | boolean | object | undefined): number {
  if (typeof val === 'number') return val;
  if (typeof val === 'string') {
    const n = parseFloat(val);
    return isNaN(n) ? 0 : n;
  }
  return 0;
}

function toStr(val: string | number | boolean | object | undefined): string {
  if (typeof val === 'string') return val;
  if (typeof val === 'number') return val.toString();
  return '';
}

function toStatus(val: string | number | boolean | object | undefined): OrderStatus {
  if (typeof val === 'string') {
    if (val === 'pending_payment') return OrderStatus.PENDING_PAYMENT;
    if (val === 'pending_shipment') return OrderStatus.PENDING_SHIPMENT;
    if (val === 'shipped') return OrderStatus.SHIPPED;
    if (val === 'received') return OrderStatus.RECEIVED;
    if (val === 'completed') return OrderStatus.COMPLETED;
    if (val === 'cancelled') return OrderStatus.CANCELLED;
  }
  return OrderStatus.PENDING_PAYMENT;
}

function mapOrder(item: Record<string, string | number | object>): Order {
  const order = new Order();
  order.id = toStr(item['id']);
  order.productId = toStr(item['spuId']);
  order.productTitle = toStr(item['productTitle']);
  order.productImage = toStr(item['productImage']);
  order.price = toNum(item['price']);
  order.buyerId = toStr(item['buyerId']);
  order.sellerId = toStr(item['sellerId']);
  order.buyerName = toStr(item['buyerName']);
  order.sellerName = toStr(item['sellerName']);
  order.status = toStatus(item['status']);
  order.createdAt = toNum(item['createdAt']);
  order.paidAt = toNum(item['paidAt']);
  order.carbonCredits = toNum(item['carbonCredits']);
  order.carbonReduction = toNum(item['carbonReduction']);
  return order;
}

export class OrderRepository {
  async getBuyerOrders(status?: string): Promise<Order[]> {
    try {
      let path: string = '/orders/buyer';
      if (status && status.length > 0) {
        path += '?status=' + status;
      }
      const resp = await HttpService.GET(path);
      if (resp.code === 0 && resp.data !== null) {
        const data = resp.data;
        if (typeof data === 'object' && data !== null) {
          const obj = data as object;
          const candidate = obj as Record<string, string | number | object>[];
          if (typeof candidate.length === 'number') {
            const orders: Order[] = [];
            for (let i = 0; i < candidate.length; i++) {
              orders.push(mapOrder(candidate[i]));
            }
            return orders;
          }
        }
      }
    } catch (err) {
    }
    return [];
  }

  async getSellerOrders(status?: string): Promise<Order[]> {
    try {
      let path: string = '/orders/seller';
      if (status && status.length > 0) {
        path += '?status=' + status;
      }
      const resp = await HttpService.GET(path);
      if (resp.code === 0 && resp.data !== null) {
        const data = resp.data;
        if (typeof data === 'object' && data !== null) {
          const obj = data as object;
          const candidate = obj as Record<string, string | number | object>[];
          if (typeof candidate.length === 'number') {
            const orders: Order[] = [];
            for (let i = 0; i < candidate.length; i++) {
              orders.push(mapOrder(candidate[i]));
            }
            return orders;
          }
        }
      }
    } catch (err) {
    }
    return [];
  }

  async createOrder(spuId: string, skuId?: string, paymentMethod?: string): Promise<Order | null> {
    try {
      const body: Record<string, string | number | object> = {};
      body['spuId'] = spuId;
      if (skuId) body['skuId'] = skuId;
      body['paymentMethod'] = paymentMethod || 'wechat';
      const resp = await HttpService.POST('/orders', body);
      if (resp.code === 0 && resp.data !== null) {
        return mapOrder(resp.data as Record<string, string | number | object>);
      }
    } catch (err) {
    }
    return null;
  }

  async confirmReceive(orderId: string): Promise<boolean> {
    try {
      const resp = await HttpService.PUT('/orders/' + orderId + '/confirm', {});
      return resp.code === 0;
    } catch (err) {
      return false;
    }
  }

  async cancelOrder(orderId: string): Promise<boolean> {
    try {
      const resp = await HttpService.PUT('/orders/' + orderId + '/cancel', {});
      return resp.code === 0;
    } catch (err) {
      return false;
    }
  }

  async payOrder(orderId: string): Promise<boolean> {
    try {
      const resp = await HttpService.PUT('/orders/' + orderId + '/pay', {});
      return resp.code === 0;
    } catch (err) {
      return false;
    }
  }

  async shipOrder(orderId: string, trackingNumber?: string): Promise<boolean> {
    try {
      const body: Record<string, string | number | object> = {};
      if (trackingNumber) body['trackingNumber'] = trackingNumber;
      const resp = await HttpService.PUT('/orders/' + orderId + '/ship', body);
      return resp.code === 0;
    } catch (err) {
      return false;
    }
  }
}

export const orderRepository = new OrderRepository();
