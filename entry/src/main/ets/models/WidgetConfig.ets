export class WidgetConfig {
  widgetType: WidgetType = WidgetType.PRODUCT_RECOMMEND;
  size: string = '2x2';
  refreshInterval: number = 30;
  deepLink: string = '';
  isDarkMode: boolean = false;
}

export enum WidgetType {
  PRODUCT_RECOMMEND = 'PRODUCT_RECOMMEND',
  CREDIT_OVERVIEW = 'CREDIT_OVERVIEW',
  QUICK_PUBLISH = 'QUICK_PUBLISH'
}