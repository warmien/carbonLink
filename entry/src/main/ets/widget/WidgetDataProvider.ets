import { productRepository, SPUListResult } from '../repository/ProductRepository';
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

export class WidgetDataProvider {
  private static cachedProductData: Record<string, string> = {};
  private static cachedCreditData: Record<string, string> = {};

  static async refreshCache(): Promise<void> {
    try {
      await WidgetDataProvider.refreshProductCache();
    } catch (e) {
    }
    try {
      await WidgetDataProvider.refreshCreditCache();
    } catch (e) {
    }
  }

  private static async refreshProductCache(): Promise<void> {
    const result: SPUListResult = await productRepository.fetchProducts();
    const count = Math.min(result.list.length, 2);
    const data: Record<string, string> = {};
    data['count'] = count.toString();
    for (let i = 0; i < count; i++) {
      const idx = i.toString();
      data['product_' + idx + '_id'] = result.list[i].id;
      data['product_' + idx + '_title'] = result.list[i].title;
      data['product_' + idx + '_price'] = result.list[i].minPrice.toString();
      const images = result.list[i].images;
      data['product_' + idx + '_image'] = images.length > 0 ? WidgetDataProvider.getDisplayImage(images) : '';
    }
    WidgetDataProvider.cachedProductData = data;
  }

  private static async refreshCreditCache(): Promise<void> {
    const resp = await HttpService.GET('/stats');
    if (resp.code === 0 && resp.data !== null) {
      const data: Record<string, string> = {};
      data['balance'] = toStr(resp.data['creditBalance']);
      data['level'] = toStr(resp.data['creditLevel']);
      data['totalEarned'] = toStr(resp.data['totalEarned']);
      WidgetDataProvider.cachedCreditData = data;
    }
  }

  static getProductRecommendData(): Record<string, string> {
    return WidgetDataProvider.cachedProductData;
  }

  static getCreditOverviewData(): Record<string, string> {
    return WidgetDataProvider.cachedCreditData;
  }

  static getQuickPublishData(): Record<string, string> {
    const data: Record<string, string> = {};
    data['deepLink'] = 'carbonlink://publish';
    data['label'] = '一键发布';
    return data;
  }

  private static getDisplayImage(images: string[]): string {
    for (let i = 0; i < images.length; i++) {
      if (images[i].length > 0 && !images[i].endsWith('.svg')) {
        return images[i];
      }
    }
    return '';
  }
}
