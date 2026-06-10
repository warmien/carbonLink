import { formBindingData } from '@kit.FormKit';
import { productRepository } from '../repository/ProductRepository';
import { creditAccountRepository } from '../repository/CreditAccountRepository';

export class WidgetDataProvider {
  private static cachedProductData: Record<string, string> = {};
  private static cachedCreditData: Record<string, string> = {};

  static getProductRecommendData(): Record<string, string> {
    try {
      const products = productRepository.getProducts();
      const count = Math.min(products.length, 2);
      const data: Record<string, string> = {};
      data['count'] = count.toString();
      for (let i = 0; i < count; i++) {
        const idx = i.toString();
        data['product_' + idx + '_id'] = products[i].id;
        data['product_' + idx + '_title'] = products[i].title;
        data['product_' + idx + '_price'] = products[i].price.toString();
        data['product_' + idx + '_image'] = products[i].images.length > 0 ? products[i].images[0] : '';
      }
      WidgetDataProvider.cachedProductData = data;
      return data;
    } catch (e) {
      return WidgetDataProvider.cachedProductData;
    }
  }

  static getCreditOverviewData(): Record<string, string> {
    try {
      const account = creditAccountRepository.getOrCreate('user_1');
      const data: Record<string, string> = {};
      data['balance'] = account.balance.toString();
      data['level'] = account.level;
      data['totalEarned'] = account.totalEarned.toString();
      WidgetDataProvider.cachedCreditData = data;
      return data;
    } catch (e) {
      return WidgetDataProvider.cachedCreditData;
    }
  }

  static getQuickPublishData(): Record<string, string> {
    const data: Record<string, string> = {};
    data['deepLink'] = 'carbonlink://publish';
    data['label'] = '一键发布';
    return data;
  }
}