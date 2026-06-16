  import { MallProduct } from '../models/MallProduct';

function createProduct(id: string, name: string, image: string, requiredCredits: number, stock: number, description: string): MallProduct {
  const p = new MallProduct();
  p.id = id;
  p.name = name;
  p.image = image;
  p.requiredCredits = requiredCredits;
  p.stock = stock;
  p.description = description;
  return p;
}

export class MockMallProducts {
  private static products: MallProduct[] = [
    createProduct('mall_1', '环保购物袋', 'https://carbon-link.obs.cn-north-4.myhuaweicloud.com/carbonlink/seed/placeholder_16.png', 50, 100, '可重复使用的环保购物袋，减少塑料袋使用'),
    createProduct('mall_2', '竹纤维毛巾', 'https://carbon-link.obs.cn-north-4.myhuaweicloud.com/carbonlink/seed/placeholder_7.png', 80, 50, '天然竹纤维材质，柔软亲肤，环保可降解'),
    createProduct('mall_3', '种子盲盒', 'https://carbon-link.obs.cn-north-4.myhuaweicloud.com/carbonlink/seed/placeholder_15.png', 30, 200, '随机植物种子，种出你的绿色小花园'),
    createProduct('mall_4', '可降解餐具套装', 'https://carbon-link.obs.cn-north-4.myhuaweicloud.com/carbonlink/seed/placeholder_19.png', 120, 30, '玉米淀粉材质，可自然降解，环保出行必备'),
    createProduct('mall_5', '碳积分勋章', 'https://carbon-link.obs.cn-north-4.myhuaweicloud.com/carbonlink/seed/placeholder_17.png', 200, 10, '限量版环保勋章，彰显你的环保贡献')
  ];

  static getProducts(): MallProduct[] {
    return MockMallProducts.products;
  }

  static getProductById(id: string): MallProduct | undefined {
    for (let i = 0; i < MockMallProducts.products.length; i++) {
      if (MockMallProducts.products[i].id === id) {
        return MockMallProducts.products[i];
      }
    }
    return undefined;
  }

  static updateStock(id: string, delta: number): boolean {
    for (let i = 0; i < MockMallProducts.products.length; i++) {
      if (MockMallProducts.products[i].id === id) {
        if (MockMallProducts.products[i].stock + delta >= 0) {
          MockMallProducts.products[i].stock += delta;
          return true;
        }
        return false;
      }
    }
    return false;
  }
}
