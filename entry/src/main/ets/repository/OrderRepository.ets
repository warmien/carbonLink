import { Order, OrderStatus } from '../models/Order';
import { MockOrders } from '../mock/MockOrders';

export class OrderRepository {
  getOrders(): Order[] {
    return MockOrders.getOrders();
  }

  getOrdersByStatus(status: OrderStatus): Order[] {
    return MockOrders.getOrdersByStatus(status);
  }

  getOrdersByBuyer(buyerId: string): Order[] {
    return MockOrders.getOrdersByBuyer(buyerId);
  }

  getOrdersBySeller(sellerId: string): Order[] {
    return MockOrders.getOrdersBySeller(sellerId);
  }

  getOrderById(id: string): Order | undefined {
    return MockOrders.getOrderById(id);
  }

  updateOrderStatus(orderId: string, newStatus: OrderStatus): boolean {
    return MockOrders.updateOrderStatus(orderId, newStatus);
  }

  addOrder(order: Order): void {
    MockOrders.addOrder(order);
  }
}

export const orderRepository = new OrderRepository();
