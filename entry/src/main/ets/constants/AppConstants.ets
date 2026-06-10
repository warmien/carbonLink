export class AppConstants {
  static readonly APP_NAME: string = '碳易链';
  static readonly APP_VERSION: string = '1.0.0';

  static readonly ROUTE_PRODUCT_DETAIL: string = 'pages/ProductDetailPage';
  static readonly ROUTE_CHAT: string = 'pages/ChatPage';
  static readonly ROUTE_MY_PRODUCTS: string = 'pages/MyProductsPage';
  static readonly ROUTE_MY_FAVORITES: string = 'pages/MyFavoritesPage';
  static readonly ROUTE_ORDER_CENTER: string = 'pages/OrderCenterPage';
  static readonly ROUTE_CREDIT_CENTER: string = 'pages/CreditCenterPage';
  static readonly ROUTE_CREDIT_LEDGER: string = 'pages/CreditLedgerPage';
  static readonly ROUTE_ECO_ACHIEVEMENT: string = 'pages/EcoAchievementPage';
  static readonly ROUTE_CREDIT_MALL: string = 'pages/CreditMallPage';


  static readonly TAB_HOME: number = 0;
  static readonly TAB_CATEGORY: number = 1;
  static readonly TAB_PUBLISH: number = 2;
  static readonly TAB_MESSAGE: number = 3;
  static readonly TAB_PROFILE: number = 4;

  // 商品分类
  static readonly CATEGORIES: string[] = [
    '电子产品', '图书', '服装', '家居', '数码', '办公',
    '运动', '母婴', '美妆', '食品', '其他'
  ];

  // 间距
  static readonly SPACING_XS: number = 4;
  static readonly SPACING_SM: number = 8;
  static readonly SPACING_MD: number = 12;
  static readonly SPACING_LG: number = 16;
  static readonly SPACING_XL: number = 24;
  static readonly SPACING_XXL: number = 32;

  // 圆角
  static readonly RADIUS_SM: number = 4;
  static readonly RADIUS_MD: number = 8;
  static readonly RADIUS_LG: number = 12;
  static readonly RADIUS_XL: number = 16;

  // 字体大小
  static readonly FONT_XS: number = 10;
  static readonly FONT_SM: number = 12;
  static readonly FONT_MD: number = 14;
  static readonly FONT_LG: number = 16;
  static readonly FONT_XL: number = 18;
  static readonly FONT_XXL: number = 22;
  static readonly FONT_TITLE: number = 28;
}
