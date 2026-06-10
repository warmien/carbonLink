import { Product } from '../models/Product';
import { MockProducts } from '../mock/MockProducts';
import { MockUsers } from '../mock/MockUsers';

export class ProductRepository {
  getProducts(): Product[] {
    return MockProducts.getProducts();
  }

  getProductById(id: string): Product | undefined {
    return MockProducts.getProductById(id);
  }

  getProductsByCategory(category: string): Product[] {
    return MockProducts.getProductsByCategory(category);
  }

  getProductsBySeller(sellerId: string): Product[] {
    return MockProducts.getProductsBySeller(sellerId);
  }

  searchProducts(keyword: string): Product[] {
    return MockProducts.searchProducts(keyword);
  }

  getFavoriteProducts(): Product[] {
    const ids = MockUsers.getFavoriteIds();
    return MockProducts.getFavoriteProducts(ids);
  }

  toggleFavorite(productId: string): boolean {
    return MockProducts.toggleFavorite(productId);
  }

  addProduct(product: Product): void {
    MockProducts.addProduct(product);
  }
}

export const productRepository = new ProductRepository();
