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
  static readonly ROUTE_LOGIN: string = 'pages/LoginPage';
  static readonly ROUTE_REGISTER: string = 'pages/RegisterPage';
  static readonly ROUTE_SETTINGS: string = 'pages/SettingsPage';
  static readonly ROUTE_EDIT_PROFILE: string = 'pages/EditProfilePage';
  static readonly ROUTE_CHANGE_PASSWORD: string = 'pages/ChangePasswordPage';
  static readonly ROUTE_BROWSE_HISTORY: string = 'pages/BrowseHistoryPage';
  static readonly ROUTE_EDIT_PRODUCT: string = 'pages/EditProductPage';

  static readonly TAB_HOME: number = 0;
  static readonly TAB_CATEGORY: number = 1;
  static readonly TAB_PUBLISH: number = 2;
  static readonly TAB_MESSAGE: number = 3;
  static readonly TAB_PROFILE: number = 4;

  static readonly CATEGORIES: string[] = [
    '电子数码', '图书教材', '服装鞋帽', '家居生活', '美妆护肤',
    '运动户外', '文具办公', '乐器文创', '虚拟服务', '其他闲置'
  ];

  static readonly SUB_CATEGORIES: Record<string, string[]> = {
    '电子数码': ['旧手机', '平板电脑', '蓝牙耳机', '有线耳机', '充电宝', '智能手表', '鼠标', '键盘', '显示器', '吹风机', '46级耳机', '46级收音机', '插座'],
    '图书教材': ['书籍', '笔记本', '考研网课账号'],
    '服装鞋帽': ['外套', '包', '帽子', '袜子类', '丝巾类'],
    '家居生活': ['小电煮锅', '台灯', '散热架', '收纳用品', '开水瓶', '鞋架', '小风扇', '挂钩', '衣架', '体重秤', '小桌板', '手机支架', '小刀', '剪刀', '鞋子除臭喷雾'],
    '美妆护肤': ['面部护肤类', '面膜类', '防晒类', '卸妆清洁类', '底妆类', '眼妆类', '唇妆类', '面部彩妆类', '美甲类', '身体洗护类', '身体护理类', '手部护理类', '头发洗护类', '美发造型类', '美发饰品类', '美妆工具类', '香水香氛类', '美妆收纳盒类', '化妆包类', '美妆家居类', '颈部配饰类', '耳部配饰类', '手部配饰类', '服饰配饰类', '美妆小家电类', '女士护理类'],
    '运动户外': ['羽毛球', '羽毛球拍', '乒乓球', '乒乓球拍', '篮球', '跳绳', '自行车', '电动车', '健身卡', '水卡'],
    '文具办公': ['文具', '计算器', '背书椅'],
    '乐器文创': ['二手乐器', '文创产品', '绿植'],
    '虚拟服务': ['考研网课账号', '健身卡', '水卡'],
    '其他闲置': []
  };

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

  static readonly STATUS_BAR_HEIGHT: number = 48;
  static readonly HOME_INDICATOR_HEIGHT: number = 34;

  static readonly WS_URL: string = 'ws://YOUR_SERVER_IP:3001/ws/chat';
  static readonly WS_PING_INTERVAL: number = 30000;
  static readonly WS_RECONNECT_DELAYS: number[] = [1000, 2000, 4000, 8000, 16000];
  static readonly WS_MAX_RECONNECT_DELAY: number = 30000;
  static readonly CHAT_PAGE_SIZE: number = 20;
}
