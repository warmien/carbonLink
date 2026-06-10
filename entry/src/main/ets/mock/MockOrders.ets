import { Order, OrderStatus } from '../models/Order';

export class MockOrders {
  private static orders: Order[] = [];

  private static buildOrder(id: string, pid: string, title: string, price: number,
                             sellerId: string, sellerName: string,
                             status: OrderStatus, createdAt: number,
                             paidAt?: number, shippedAt?: number, receivedAt?: number,
                             completedAt?: number, shippingMethod?: string, trackingNumber?: string): Order {
    const o = new Order();
    o.id = id;
    o.productId = pid;
    o.productTitle = title;
    o.productImage = '/product_placeholder.png';
    o.price = price;
    o.buyerId = 'u000';
    o.sellerId = sellerId;
    o.buyerName = '碳易用户';
    o.sellerName = sellerName;
    o.status = status;
    o.createdAt = createdAt;
    o.paidAt = paidAt ?? 0;
    o.shippedAt = shippedAt ?? 0;
    o.receivedAt = receivedAt ?? 0;
    o.completedAt = completedAt ?? 0;
    o.shippingMethod = shippingMethod ?? '';
    o.trackingNumber = trackingNumber ?? '';
    return o;
  }

  private static init(): void {
    MockOrders.orders = [
      MockOrders.buildOrder('ord001', 'p001', 'iPhone 15 Pro 256GB 原色钛金属', 6800,
        'u001', '小明同学', OrderStatus.PENDING_PAYMENT, Date.now() - 3600000 * 2),
      MockOrders.buildOrder('ord002', 'p004', 'Nike Air Force 1 经典白色 42码', 399,
        'u004', '广州潮人', OrderStatus.PENDING_SHIPMENT, Date.now() - 86400000 * 1,
        Date.now() - 86400000 * 1 + 3600000),
      MockOrders.buildOrder('ord003', 'p006', 'Sony WH-1000XM5 无线降噪耳机', 1799,
        'u006', '数码玩家老张', OrderStatus.SHIPPED, Date.now() - 86400000 * 3,
        Date.now() - 86400000 * 3 + 7200000, Date.now() - 86400000 * 2,
        undefined, undefined, '顺丰快递', 'SF1234567890'),
      MockOrders.buildOrder('ord004', 'p010', '北面 1996 经典羽绒服 L码', 899,
        'u010', '朝阳群众', OrderStatus.SHIPPED, Date.now() - 86400000 * 5,
        Date.now() - 86400000 * 5 + 3600000, Date.now() - 86400000 * 3,
        undefined, undefined, '圆通快递', 'YT9876543210'),
      MockOrders.buildOrder('ord005', 'p002', 'MacBook Air M2 8GB+256GB', 6500,
        'u002', '海淀码农', OrderStatus.COMPLETED, Date.now() - 86400000 * 15,
        Date.now() - 86400000 * 15 + 3600000, Date.now() - 86400000 * 13,
        Date.now() - 86400000 * 10, Date.now() - 86400000 * 10, '京东物流', 'JD5678901234'),
      MockOrders.buildOrder('ord006', 'p007', '人体工学椅 Ergomax Evolution', 1200,
        'u007', '程序员小陈', OrderStatus.CANCELLED, Date.now() - 86400000 * 20),
    ];
  }

  static getOrders(): Order[] {
    if (MockOrders.orders.length === 0) MockOrders.init();
    return JSON.parse(JSON.stringify(MockOrders.orders)) as Order[];
  }

  static getOrdersByStatus(status: OrderStatus): Order[] {
    if (MockOrders.orders.length === 0) MockOrders.init();
    return JSON.parse(JSON.stringify(MockOrders.orders.filter(o => o.status === status))) as Order[];
  }

  static getOrdersByBuyer(buyerId: string): Order[] {
    if (MockOrders.orders.length === 0) MockOrders.init();
    return JSON.parse(JSON.stringify(MockOrders.orders.filter(o => o.buyerId === buyerId))) as Order[];
  }

  static getOrdersBySeller(sellerId: string): Order[] {
    if (MockOrders.orders.length === 0) MockOrders.init();
    return JSON.parse(JSON.stringify(MockOrders.orders.filter(o => o.sellerId === sellerId))) as Order[];
  }

  static getOrderById(id: string): Order | undefined {
    if (MockOrders.orders.length === 0) MockOrders.init();
    const o = MockOrders.orders.find(o => o.id === id);
    return o ? (JSON.parse(JSON.stringify(o)) as Order) : undefined;
  }

  static updateOrderStatus(orderId: string, newStatus: OrderStatus): boolean {
    if (MockOrders.orders.length === 0) MockOrders.init();
    const o = MockOrders.orders.find(o => o.id === orderId);
    if (!o) return false;
    o.status = newStatus;
    const now = Date.now();
    if (newStatus === OrderStatus.PENDING_SHIPMENT) {
      o.paidAt = now;
    } else if (newStatus === OrderStatus.RECEIVED) {
      o.receivedAt = now;
    } else if (newStatus === OrderStatus.COMPLETED) {
      o.completedAt = now;
    }
    return true;
  }

  static addOrder(order: Order): void {
    if (MockOrders.orders.length === 0) MockOrders.init();
    order.id = 'ord' + (MockOrders.orders.length + 1).toString().padStart(3, '0');
    order.createdAt = Date.now();
    MockOrders.orders.unshift(JSON.parse(JSON.stringify(order)) as Order);
  }
}
