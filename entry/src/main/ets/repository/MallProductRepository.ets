import { MallProduct } from '../models/MallProduct';
import { MockMallProducts } from '../mock/MockMallProducts';

export class MallProductRepository {
  getProducts(): MallProduct[] {
    return MockMallProducts.getProducts();
  }

  getProductById(id: string): MallProduct | undefined {
    return MockMallProducts.getProductById(id);
  }

  updateStock(id: string, delta: number): boolean {
    return MockMallProducts.updateStock(id, delta);
  }
}

export const mallProductRepository = new MallProductRepository();