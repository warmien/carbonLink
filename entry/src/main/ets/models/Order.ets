export class Order {
  id: string = '';
  productId: string = '';
  productTitle: string = '';
  productImage: string = '';
  price: number = 0;
  buyerId: string = '';
  sellerId: string = '';
  buyerName: string = '';
  sellerName: string = '';
  status: OrderStatus = OrderStatus.PENDING_PAYMENT;
  createdAt: number = Date.now();
  paidAt: number = 0;
  shippedAt: number = 0;
  receivedAt: number = 0;
  completedAt: number = 0;
  shippingMethod: string = '';
  trackingNumber: string = '';

  static getStatusLabel(status: OrderStatus): string {
    switch (status) {
      case OrderStatus.PENDING_PAYMENT: return '待付款';
      case OrderStatus.PENDING_SHIPMENT: return '待发货';
      case OrderStatus.SHIPPED: return '待收货';
      case OrderStatus.RECEIVED: return '已收货';
      case OrderStatus.COMPLETED: return '已完成';
      case OrderStatus.CANCELLED: return '已取消';
      default: return '未知';
    }
  }
}

export enum OrderStatus {
  PENDING_PAYMENT = 'pending_payment',
  PENDING_SHIPMENT = 'pending_shipment',
  SHIPPED = 'shipped',
  RECEIVED = 'received',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}
