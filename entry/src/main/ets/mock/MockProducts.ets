import { Product, ProductCondition, ProductStatus } from '../models/Product';
import { MockUsers } from './MockUsers';
import { CarbonCreditTable } from '../config/CarbonCreditTable';

export class MockProducts {
  private static products: Product[] = [];

  private static buildProduct(
    id: string, title: string, desc: string, price: number, origPrice: number,
    category: string, subCategory: string, condition: string, brand: string,
    location: string, distance: string, sellerId: string, sellerName: string,
    viewCount: number, favCount: number, tags: string[], daysAgo: number
  ): Product {
    const p = new Product();
    p.id = id;
    p.title = title;
    p.description = desc;
    p.price = price;
    p.originalPrice = origPrice;
    p.images = ['/product_placeholder.png'];
    p.category = category;
    p.subCategory = subCategory;
    p.condition = condition;
    p.brand = brand;
    p.location = location;
    p.distance = distance;
    p.sellerId = sellerId;
    p.sellerName = sellerName;
    p.sellerAvatar = '';
    p.viewCount = viewCount;
    p.favoriteCount = favCount;
    p.isFavorited = false;
    p.status = ProductStatus.SELLING;
    p.createdAt = Date.now() - 86400000 * daysAgo;
    p.tags = tags;
    const creditResult = CarbonCreditTable.calculate(category, subCategory, condition);
    p.carbonReduction = creditResult.carbonReduction;
    p.carbonCredits = creditResult.carbonCredits;
    return p;
  }

  private static init(): void {
    MockProducts.products = [
      MockProducts.buildProduct('p001', 'iPhone 15 Pro 256GB 原色钛金属',
        '去年11月购入，一直带壳使用，无划痕无磕碰。电池健康度98%，配件齐全，原盒在。因换新机出售。',
        6800, 8999, '电子数码', '旧手机', ProductCondition.B_GRADE, 'Apple',
        '深圳·南山区', '1.2km', 'u001', '小明同学', 328, 45, ['iPhone', '5G', '闲置'], 3),
      MockProducts.buildProduct('p002', 'MacBook Air M2 8GB+256GB 午夜色',
        '2024年教育优惠购入，轻度办公使用，屏幕完美，键盘无油光。AppleCare+ 到2025年12月。',
        6500, 8999, '电子数码', '平板电脑', ProductCondition.B_GRADE, 'Apple',
        '北京·海淀区', '3.5km', 'u002', '海淀码农', 512, 67, ['MacBook', 'M2', '轻薄本'], 5),
      MockProducts.buildProduct('p003', '设计心理学（套装4册）全新未拆封',
        '朋友送的礼物，已经有电子版了，全新未拆封，四本一套。适合设计师、产品经理阅读。',
        89, 198, '图书教材', '书籍', ProductCondition.A_GRADE, '',
        '上海·浦东新区', '0.8km', 'u003', '阅读者小王', 156, 23, ['设计', '心理学', '全新'], 2),
      MockProducts.buildProduct('p004', 'Nike Air Force 1 经典白色 42码',
        '只穿过3次，码数买小了故出。鞋底几乎没有磨损，鞋面干净，原盒在。经典百搭款。',
        399, 799, '服装鞋帽', '外套', ProductCondition.C_GRADE, 'Nike',
        '广州·天河区', '2.1km', 'u004', '广州潮人', 234, 34, ['Nike', 'AF1', '经典款'], 4),
      MockProducts.buildProduct('p005', '小米空气净化器 4 Pro',
        '使用半年，滤芯还剩80%寿命。搬家换了大房子换了大功率的，这个闲置了。',
        799, 1499, '家居生活', '台灯', ProductCondition.D_GRADE, '小米',
        '杭州·西湖区', '5.0km', 'u005', '杭州家居控', 189, 28, ['小米', '空气净化器', '智能家居'], 6),
      MockProducts.buildProduct('p006', 'Sony WH-1000XM5 无线降噪耳机 黑色',
        '公司年会奖品，只用过一周，基本全新。降噪效果天花板，音质出色。',
        1799, 2499, '电子数码', '蓝牙耳机', ProductCondition.B_GRADE, 'Sony',
        '成都·高新区', '1.8km', 'u006', '数码玩家老张', 456, 89, ['Sony', '降噪耳机', '无线'], 1),
      MockProducts.buildProduct('p007', '人体工学椅 办公椅 Ergomax Evolution',
        '用了8个月，网布完好，各种调节功能正常。腰部支撑很舒服，适合长时间办公。自取。',
        1200, 2599, '文具办公', '背书椅', ProductCondition.D_GRADE, 'Ergomax',
        '武汉·洪山区', '4.2km', 'u007', '程序员小陈', 267, 41, ['人体工学椅', '办公椅', '自取'], 7),
      MockProducts.buildProduct('p008', '瑜伽垫 Liforme 天然橡胶 6mm',
        '冲动消费买了没怎么用，大概用了5次。Liforme的垫子防滑性很好。',
        299, 580, '运动户外', '跳绳', ProductCondition.C_GRADE, 'Liforme',
        '深圳·福田区', '2.6km', 'u008', '瑜伽爱好者', 112, 17, ['瑜伽垫', '运动', 'Liforme'], 2),
      MockProducts.buildProduct('p009', '富士 X-T5 微单相机 + 18-55mm镜头',
        '2024年6月购入，快门数不到2000。出片色彩绝了，胶片模拟很好用。',
        9500, 13999, '电子数码', '旧手机', ProductCondition.B_GRADE, 'Fujifilm',
        '南京·鼓楼区', '3.0km', 'u009', '摄影爱好者', 678, 112, ['富士', '微单', '相机'], 4),
      MockProducts.buildProduct('p010', '北面 1996 经典羽绒服 黑色 L码',
        '去年冬天买的，穿了不到十次。正品，吊牌和购买记录都在。版型经典百搭。',
        899, 1899, '服装鞋帽', '外套', ProductCondition.C_GRADE, 'The North Face',
        '北京·朝阳区', '1.5km', 'u010', '朝阳群众', 345, 56, ['北面', '羽绒服', '冬季'], 8),
    ];
    const favoriteIds = MockUsers.getFavoriteIds();
    for (const p of MockProducts.products) {
      if (favoriteIds.includes(p.id)) {
        p.isFavorited = true;
      }
    }
  }

  static getProducts(): Product[] {
    if (MockProducts.products.length === 0) MockProducts.init();
    return JSON.parse(JSON.stringify(MockProducts.products)) as Product[];
  }

  static getProductById(id: string): Product | undefined {
    if (MockProducts.products.length === 0) MockProducts.init();
    const p = MockProducts.products.find(p => p.id === id);
    return p ? (JSON.parse(JSON.stringify(p)) as Product) : undefined;
  }

  static getProductsByCategory(category: string): Product[] {
    if (MockProducts.products.length === 0) MockProducts.init();
    return JSON.parse(JSON.stringify(MockProducts.products.filter(p => p.category === category))) as Product[];
  }

  static getProductsBySeller(sellerId: string): Product[] {
    if (MockProducts.products.length === 0) MockProducts.init();
    return JSON.parse(JSON.stringify(MockProducts.products.filter(p => p.sellerId === sellerId))) as Product[];
  }

  static getFavoriteProducts(ids: string[]): Product[] {
    if (MockProducts.products.length === 0) MockProducts.init();
    return JSON.parse(JSON.stringify(MockProducts.products.filter(p => ids.includes(p.id)))) as Product[];
  }

  static searchProducts(keyword: string): Product[] {
    if (MockProducts.products.length === 0) MockProducts.init();
    const kw = keyword.toLowerCase();
    return JSON.parse(JSON.stringify(MockProducts.products.filter(p =>
      p.title.toLowerCase().includes(kw) ||
      p.description.toLowerCase().includes(kw) ||
      p.brand.toLowerCase().includes(kw) ||
      p.tags.some(t => t.toLowerCase().includes(kw))
    ))) as Product[];
  }

  static addProduct(product: Product): void {
    if (MockProducts.products.length === 0) MockProducts.init();
    product.id = 'p' + (MockProducts.products.length + 1).toString().padStart(3, '0');
    product.createdAt = Date.now();
    product.viewCount = 0;
    product.favoriteCount = 0;
    product.isFavorited = false;
    MockProducts.products.unshift(JSON.parse(JSON.stringify(product)) as Product);
  }

  static toggleFavorite(productId: string): boolean {
    if (MockProducts.products.length === 0) MockProducts.init();
    const p = MockProducts.products.find(p => p.id === productId);
    if (!p) return false;
    p.isFavorited = !p.isFavorited;
    MockUsers.toggleFavoriteId(productId, p.isFavorited);
    return p.isFavorited;
  }
}
