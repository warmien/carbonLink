import { Product, ProductCondition } from '../models/Product';
import { User } from '../models/User';
import { Conversation } from '../models/Message';
import { PricingResult } from '../models/PricingResult';

import { productRepository } from '../repository/ProductRepository';
import { userRepository } from '../repository/UserRepository';
import { messageRepository } from '../repository/MessageRepository';
import { DateUtils } from '../utils/DateUtils';
import { ProductCard } from '../components/ProductCard';
import { AISearchBar } from '../components/AISearchBar';
import { BannerView } from '../components/BannerView';
import { UserCard } from '../components/UserCard';
import { EmptyState } from '../components/EmptyState';
import { AIRecognitionIndicator } from '../components/AIRecognitionIndicator';
import { ImagePickerPanel } from '../components/ImagePickerPanel';
import { AIPricingResultCard } from '../components/AIPricingResultCard';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';
import { AiBackendConfig } from '../constants/AiBackendConfig';
import { RouterManager } from '../router/RouterManager';
import { CreditEngine } from '../engine/CreditEngine';
import { AchievementDetector } from '../engine/AchievementDetector';
import { DeviceAdapterManager } from '../adaptation/DeviceAdapterManager';
import { RecommendationEngine } from '../engine/RecommendationEngine';
import { BehaviorCollector } from '../services/BehaviorCollector';
import { RecommendSection } from '../components/RecommendSection';
import { Recommendation } from '../models/Recommendation';
import { ImagePickerService } from '../services/ImagePickerService';
import { AIRecognitionService } from '../services/AIRecognitionService';
import { AIPricingService } from '../services/AIPricingService';
import { AIDescriptionService } from '../services/AIDescriptionService';
import { promptAction } from '@kit.ArkUI';

export class CategoryIconItem {
  name: string;
  icon: ResourceStr;
  color: string;
  constructor(name: string, icon: ResourceStr, color: string) {
    this.name = name;
    this.icon = icon;
    this.color = color;
  }
}

@Entry
@Component
struct Index {
  @StorageLink('currentTabIndex') currentTabIndex: number = 0;
  @State tabScale: number = 1;
  @State publishScale: number = 1;
  private tabsController: TabsController = new TabsController();

  build() {

    Stack() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController,
        index: this.currentTabIndex
      }) {
        TabContent() {
          HomePageView()
        }

        TabContent() {
          CategoryPageView()
        }

        TabContent() {
          PublishPageView()
        }

        TabContent() {
          MessagePageView()
        }

        TabContent() {
          ProfilePageView()
        }
      }
      .barHeight(0)
      .scrollable(false)
      .animationDuration(300)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .width('100%')
      .height('100%')
      .padding({ bottom: 80 })
      .backgroundColor(ThemeManager.BG_PRIMARY)

      Column() {
        Row() {
          Column({ space: 2 }) {
            Image(this.currentTabIndex === 0 ? $r('sys.symbol.house_fill') : $r('sys.symbol.house'))
              .width(24)
              .height(24)
              .fillColor(this.currentTabIndex === 0 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
            Text('首页')
              .fontSize(10)
              .fontColor(this.currentTabIndex === 0 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .scale({ x: this.currentTabIndex === 0 ? this.tabScale : 1, y: this.currentTabIndex === 0 ? this.tabScale : 1 })
          .animation({ duration: 100, curve: Curve.EaseOut })
          .onClick(() => {
            animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 0.9; });
            setTimeout(() => { animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 1; }); }, 100);
            this.currentTabIndex = 0; this.tabsController.changeIndex(0);
          })

          Column({ space: 2 }) {
            Image(this.currentTabIndex === 1 ? $r('sys.symbol.leaf_fill') : $r('sys.symbol.leaf_fill'))
              .width(24)
              .height(24)
              .fillColor(this.currentTabIndex === 1 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
            Text('分类')
              .fontSize(10)
              .fontColor(this.currentTabIndex === 1 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .scale({ x: this.currentTabIndex === 1 ? this.tabScale : 1, y: this.currentTabIndex === 1 ? this.tabScale : 1 })
          .animation({ duration: 100, curve: Curve.EaseOut })
          .onClick(() => {
            animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 0.9; });
            setTimeout(() => { animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 1; }); }, 100);
            this.currentTabIndex = 1; this.tabsController.changeIndex(1);
          })

          Column() {
            Stack() {
              Column()
                .width(52)
                .height(52)
                .borderRadius(26)
                .backgroundColor(Color.White)
                .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 2 })
              Column()
                .width(44)
                .height(44)
                .borderRadius(22)
                .linearGradient({
                  direction: GradientDirection.Bottom,
                  colors: [['#66C2A5', 0], ['#006D77', 1]]
                })
              Image($r('app.media.ic_publish_icon'))
                .width(24)
                .height(24)
            }
            .width(52)
            .height(52)
            .offset({ y: -10 })
            .scale({ x: this.publishScale, y: this.publishScale })
            .animation({ duration: 100, curve: Curve.EaseOut })

            Text('发布减碳')
              .fontSize(10)
              .fontColor('#000000')
              .margin({ top: -6 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.publishScale = 0.9; });
            setTimeout(() => { animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.publishScale = 1; }); }, 100);
            this.currentTabIndex = 2; this.tabsController.changeIndex(2);
          })

          Column({ space: 2 }) {
            Image(this.currentTabIndex === 3 ? $r('sys.symbol.message_fill') : $r('sys.symbol.message'))
              .width(24)
              .height(24)
              .fillColor(this.currentTabIndex === 3 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
            Text('消息')
              .fontSize(10)
              .fontColor(this.currentTabIndex === 3 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .scale({ x: this.currentTabIndex === 3 ? this.tabScale : 1, y: this.currentTabIndex === 3 ? this.tabScale : 1 })
          .animation({ duration: 100, curve: Curve.EaseOut })
          .onClick(() => {
            animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 0.9; });
            setTimeout(() => { animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 1; }); }, 100);
            this.currentTabIndex = 3; this.tabsController.changeIndex(3);
          })

          Column({ space: 2 }) {
            Image(this.currentTabIndex === 4 ? $r('sys.symbol.person_fill') : $r('sys.symbol.person'))
              .width(24)
              .height(24)
              .fillColor(this.currentTabIndex === 4 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
            Text('我的')
              .fontSize(10)
              .fontColor(this.currentTabIndex === 4 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .scale({ x: this.currentTabIndex === 4 ? this.tabScale : 1, y: this.currentTabIndex === 4 ? this.tabScale : 1 })
          .animation({ duration: 100, curve: Curve.EaseOut })
          .onClick(() => {
            animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 0.9; });
            setTimeout(() => { animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.tabScale = 1; }); }, 100);
            this.currentTabIndex = 4; this.tabsController.changeIndex(4);
          })
        }
        .width('100%')
        .height(80)
        .backgroundColor(ThemeManager.BG_CARD)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(80)
      .position({ x: 0, y: '100%' })
      .translate({ y: -80 })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

// ========== 首页 ==========
@Component
struct HomePageView {
  @State searchKeyword: string = '';
  @State products: Product[] = [];
  @State recommendations: Recommendation[] = [];
  @State categoryIcons: CategoryIconItem[] = [];
  @State isFiltered: boolean = false;
  @State isRefreshing: boolean = false;
  private allProducts: Product[] = [];

  aboutToAppear(): void {
    this.allProducts = productRepository.getProducts();
    this.products = this.allProducts;
    this.recommendations = RecommendationEngine.getHomeRecommendations('user_1', 10);
    this.categoryIcons = [
      new CategoryIconItem('电子产品', $r('sys.symbol.camera_fill'), '#1890FF'),
      new CategoryIconItem('图书', $r('sys.symbol.doc_text_fill'), '#FAAD14'),
      new CategoryIconItem('服装', $r('sys.symbol.gift_fill'), '#FF6B35'),
      new CategoryIconItem('家居', $r('sys.symbol.house_fill'), '#52C41A'),
      new CategoryIconItem('数码', $r('sys.symbol.camera_fill'), '#722ED1'),
      new CategoryIconItem('办公', $r('sys.symbol.briefcase_fill'), '#13C2C2'),
    ];
  }

  onPageShow(): void {
    const needRefresh = AppStorage.get<boolean>('needRefreshProducts') ?? false;
    if (needRefresh) {
      this.allProducts = productRepository.getProducts();
      this.products = this.isFiltered ? this.products : this.allProducts;
      AppStorage.setOrCreate('needRefreshProducts', false);
    }
  }

  build() {
    Column() {
      Row() {
        Blank()
        Image($r('sys.symbol.qrcode'))
          .width(22)
          .height(22)
          .fillColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 48 })

      AISearchBar({ value: $searchKeyword, onSearch: (kw: string, productIds: string[]) => {
        if (productIds.length > 0) {
          const all = productRepository.getProducts();
          this.products = all.filter((p: Product) => productIds.indexOf(p.id) >= 0);
          this.isFiltered = true;
        } else if (kw !== '') {
          this.products = productRepository.searchProducts(kw);
          this.isFiltered = true;
        } else {
          this.products = this.allProducts;
          this.isFiltered = false;
        }
      }})

      Refresh({ refreshing: $$this.isRefreshing }) {
        Scroll() {
          Column({ space: AppConstants.SPACING_LG }) {
            BannerView()

            SectionHeader({ title: '热门分类' })
            Scroll() {
              Row({ space: 16 }) {
                ForEach(this.categoryIcons, (item: CategoryIconItem) => {
                  Column({ space: 8 }) {
                    Column() {
                      Image(item.icon)
                        .width(24)
                        .height(24)
                        .fillColor(item.color)
                    }
                    .width(48)
                    .height(48)
                    .borderRadius(AppConstants.RADIUS_LG)
                    .backgroundColor(item.color + '15')
                    .justifyContent(FlexAlign.Center)

                    Text(item.name)
                      .fontSize(AppConstants.FONT_XS)
                      .fontColor(ThemeManager.TEXT_SECONDARY)
                  }
                  .onClick(() => {
                    this.products = productRepository.getProductsByCategory(item.name);
                    this.isFiltered = true;
                  })
                })
              }
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 8, bottom: 8 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            Row() {
              Text('推荐好物')
                .fontSize(AppConstants.FONT_LG)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeManager.TEXT_PRIMARY)
              Blank()
              if (this.isFiltered) {
                Text('清除筛选')
                  .fontSize(AppConstants.FONT_SM)
                  .fontColor(ThemeManager.COLOR_PRIMARY)
                  .onClick(() => {
                    this.products = this.allProducts;
                    this.isFiltered = false;
                  })
              } else {
                Text('更多 >')
                  .fontSize(AppConstants.FONT_SM)
                  .fontColor(ThemeManager.TEXT_HINT)
              }
            }
            .width('100%')
            .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
            WaterfallGrid({ products: this.products })

            RecommendSection({ title: '为你推荐', recommendations: this.recommendations, isHorizontal: false })

            SectionHeader({ title: '附近闲置' })
            NearbyProducts({ products: this.products.length > 0 ? this.products.slice(0, 4) : [] })

            Blank().height(120)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.allProducts = productRepository.getProducts();
          this.products = this.allProducts;
          this.recommendations = RecommendationEngine.getHomeRecommendations('user_1', 10);
          this.isRefreshing = false;
        }, 1500);
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}

// ========== 分类页 ==========
@Component
struct CategoryPageView {
  @State categories: string[] = AppConstants.CATEGORIES;
  @State selectedCategory: string = AppConstants.CATEGORIES[0];
  @State products: Product[] = [];

  aboutToAppear(): void {
    this.products = productRepository.getProductsByCategory(this.selectedCategory);
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('分类浏览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 48, bottom: AppConstants.SPACING_SM })

      Row() {
        // 左侧分类列表
        List({ space: 0 }) {
          ForEach(this.categories, (cat: string) => {
            ListItem() {
              Text(cat)
                .fontSize(AppConstants.FONT_MD)
                .fontColor(this.selectedCategory === cat ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_SECONDARY)
                .fontWeight(this.selectedCategory === cat ? FontWeight.Medium : FontWeight.Normal)
                .width('100%')
                .height(48)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.selectedCategory === cat ? ThemeManager.BG_CARD : ThemeManager.BG_PRIMARY)
                .borderWidth({ left: this.selectedCategory === cat ? 3 : 0 })
                .borderColor({ left: this.selectedCategory === cat ? ThemeManager.COLOR_PRIMARY : 'transparent' })
            }
            .onClick(() => {
              this.selectedCategory = cat;
              this.products = productRepository.getProductsByCategory(cat);
            })
          })
        }
        .width(90)
        .height('100%')
        .backgroundColor(ThemeManager.BG_PRIMARY)

        // 右侧商品网格
        Scroll() {
          if (this.products.length === 0) {
            EmptyState({ message: '该分类暂无商品' })
          } else {
            Grid() {
              ForEach(this.products, (product: Product) => {
                GridItem() {
                  ProductCard({
                    product: product,
                    onCardClick: () => RouterManager.toProductDetail(product.id)
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(AppConstants.SPACING_SM)
            .rowsGap(AppConstants.SPACING_SM)
            .padding({ left: AppConstants.SPACING_SM, right: AppConstants.SPACING_SM, bottom: 80 })
          }
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(ThemeManager.BG_CARD)
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
  }
}

// ========== 发布页 ==========
@Component
struct PublishPageView {
  @State title: string = '';
  @State description: string = '';
  @State price: string = '';
  @State originalPrice: string = '';
  @State selectedCategory: string = '';
  @State selectedCondition: string = '';
  @State images: string[] = [];
  @State showCategoryPicker: boolean = false;
  @State showConditionPicker: boolean = false;
  @State showImageSourcePicker: boolean = false;

  @State recognitionStatus: string = 'idle';
  @State recognitionError: string = '';
  @State isRecognizing: boolean = false;
  @State isPricing: boolean = false;
  @State isGeneratingDesc: boolean = false;
  @State pricingResult: PricingResult = new PricingResult();
  private recognizedUris: Set<string> = new Set();

  aboutToAppear(): void {
  }

  private async handleImageAdd(): Promise<void> {
    if (this.images.length >= 9) {
      promptAction.showToast({ message: '最多添加9张图片' });
      return;
    }
    this.showImageSourcePicker = true;
  }

  private async selectFromGallery(): Promise<void> {
    this.showImageSourcePicker = false;
    const maxCount = 9 - this.images.length;
    const uris = await ImagePickerService.selectFromGallery(maxCount);
    if (uris.length === 0) {
      return;
    }
    this.images = [...this.images, ...uris];
    this.tryRecognize(uris[0]);
  }

  private async takePhoto(): Promise<void> {
    this.showImageSourcePicker = false;
    const uri = await ImagePickerService.takePhoto();
    if (uri) {
      this.images = [...this.images, uri];
      this.tryRecognize(uri);
    }
  }

  private async tryRecognize(imageUri: string): Promise<void> {
    if (this.isRecognizing || this.recognizedUris.has(imageUri)) {
      return;
    }
    this.isRecognizing = true;
    this.recognitionStatus = 'loading';
    this.recognizedUris.add(imageUri);
    const config = AiBackendConfig.getRecognitionConfig();
    const result = await AIRecognitionService.recognize(imageUri, config);
    this.isRecognizing = false;
    if (result.success) {
      if (result.itemName && this.title.trim() === '') {
        this.title = result.itemName;
      }
      if (result.mappedCondition && this.selectedCondition === '') {
        this.selectedCondition = result.mappedCondition;
      }
      if (result.condition && this.selectedCategory === '') {
        const matchedCat = this.matchCategory(result.itemName || '');
        if (matchedCat) {
          this.selectedCategory = matchedCat;
        }
      }
      this.recognitionStatus = 'success';
      setTimeout(() => { this.recognitionStatus = 'idle'; }, 1500);
    } else {
      this.recognitionError = result.errorMessage;
      this.recognitionStatus = 'error';
      setTimeout(() => { this.recognitionStatus = 'idle'; }, 3000);
    }
  }

  private matchCategory(name: string): string {
    const categories: string[] = ['电子产品', '图书', '服装', '家居', '数码', '运动'];
    const keywords: string[][] = [
      ['手机', 'iPhone', 'iPad', '电脑', '笔记本', '耳机', '音箱', '手表', '平板', '相机', '键盘', '鼠标'],
      ['书', '教材', '小说', '杂志', '绘本', '字典'],
      ['衣服', '裤', '裙', '外套', '鞋', 'T恤', '衬衫', '夹克', '羽绒服'],
      ['家具', '沙发', '床', '桌', '椅', '灯', '收纳', '装饰'],
      ['充电', '数据线', '保护壳', '贴膜', '支架', '移动电源'],
      ['跑步', '瑜伽', '健身', '球', '滑板', '自行车'],
    ];
    for (let i = 0; i < categories.length; i++) {
      const kws = keywords[i];
      for (const kw of kws) {
        if (name.indexOf(kw) >= 0) {
          return categories[i];
        }
      }
    }
    return '';
  }

  private async reRecognize(): Promise<void> {
    if (this.images.length === 0 || this.isRecognizing) return;
    this.recognizedUris.clear();
    this.tryRecognize(this.images[0]);
  }


  private async doPricing(): Promise<void> {
    if (this.title.trim() === '') {
      promptAction.showToast({ message: '请先输入商品标题' });
      return;
    }
    if (this.selectedCategory === '') {
      promptAction.showToast({ message: '请先选择分类' });
      return;
    }
    this.isPricing = true;
    const config = AiBackendConfig.getPricingConfig();
    const result = await AIPricingService.pricing(this.title, this.selectedCategory, this.selectedCondition, '', config);
    this.pricingResult = result;
    this.isPricing = false;
    if (!result.success) {
      promptAction.showToast({ message: result.errorMessage });
    }
  }

  private async doGenerateDesc(): Promise<void> {
    if (this.title.trim() === '') {
      promptAction.showToast({ message: '请先输入商品标题' });
      return;
    }
    this.isGeneratingDesc = true;
    const config = AiBackendConfig.getDescriptionConfig();
    const result = await AIDescriptionService.generate(this.title, this.selectedCategory, this.selectedCondition, this.images, config);
    this.isGeneratingDesc = false;
    if (result.success && result.description) {
      if (this.description.trim() === '') {
        this.description = result.description;
      } else {
        this.description = result.description;
      }
    } else {
      promptAction.showToast({ message: result.errorMessage || '描述生成失败' });
    }
  }

  build() {
    Stack() {
    Column() {
      Row() {
        Text('发布闲置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
        Blank()
        Button('发布')
          .fontSize(AppConstants.FONT_MD)
          .fontColor(Color.White)
          .backgroundColor(this.title !== '' && this.price !== '' && this.selectedCategory !== '' ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
          .borderRadius(20)
          .height(36)
          .padding({ left: 20, right: 20 })
          .enabled(this.title !== '' && this.price !== '' && this.selectedCategory !== '')
          .animation({ duration: 300 })
          .onClick(() => {
            if (this.title.trim() === '') {
              promptAction.showToast({ message: '请输入商品标题' });
              return;
            }
            if (this.selectedCategory === '') {
              promptAction.showToast({ message: '请选择分类' });
              return;
            }
            const priceVal = parseFloat(this.price);
            if (isNaN(priceVal) || priceVal <= 0) {
              promptAction.showToast({ message: '请输入有效价格' });
              return;
            }
            const origPriceVal = this.originalPrice !== '' ? parseFloat(this.originalPrice) : 0;
            if (this.originalPrice !== '' && (isNaN(origPriceVal) || origPriceVal <= 0)) {
              promptAction.showToast({ message: '请输入有效原价' });
              return;
            }
            if (origPriceVal > 0 && origPriceVal <= priceVal) {
              promptAction.showToast({ message: '原价应大于售价' });
              return;
            }
            const user = userRepository.getCurrentUser();
            const product = new Product();
            product.title = this.title;
            product.description = this.description;
            product.price = priceVal;
            product.originalPrice = origPriceVal;
            product.category = this.selectedCategory;
            product.condition = this.selectedCondition;
            product.images = this.images;
            product.sellerId = user.id;
            product.sellerName = user.nickname;
            product.sellerAvatar = user.avatar;
            product.location = user.location;
            product.distance = '0km';
            productRepository.addProduct(product);
            CreditEngine.onProductPublished(product.id, user.id);
            AchievementDetector.detect(user.id, 'publish');
            promptAction.showToast({ message: '发布成功！+10积分' });
            this.title = '';
            this.description = '';
            this.price = '';
            this.originalPrice = '';
            this.selectedCategory = '';
            this.selectedCondition = '';
            this.images = [];
            this.pricingResult = new PricingResult();
            AppStorage.setOrCreate('needRefreshProducts', true);
          })
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 48, bottom: AppConstants.SPACING_SM })

      Scroll() {
        Column({ space: 0 }) {
          Stack() {
            ImagePickerPanel({
              images: $images,
              maxCount: 9,
              onImageAdd: () => { this.handleImageAdd(); },
              onImageDelete: (index: number) => {
                const removed = this.images[index];
                this.images = this.images.filter((_: string, i: number) => i !== index);
                this.recognizedUris.delete(removed);
              }
            })
            AIRecognitionIndicator({ status: this.recognitionStatus, errorMessage: this.recognitionError })
              .position({ top: 0, left: 0 })
          }
          .width('100%')
          .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

          Row() {
            Button('AI识别')
              .fontSize(AppConstants.FONT_XS)
              .backgroundColor('#E8F8F0')
              .fontColor(ThemeManager.COLOR_PRIMARY)
              .borderRadius(14)
              .height(26)
              .padding({ left: 10, right: 10 })
              .enabled(!this.isRecognizing && this.images.length > 0)
              .onClick(() => { this.reRecognize(); })
          }
          .width('100%')
          .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })

          Column() {
            FormItem({ label: '标题', required: true }) {
              TextInput({ text: this.title, placeholder: '如：iPhone 15 Pro 256G' })
                .fontSize(AppConstants.FONT_MD)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((text: string) => { this.title = text; })
            }

            FormItem({ label: '分类', required: true }) {
              Row() {
                Text(this.selectedCategory !== '' ? this.selectedCategory : '请选择分类')
                  .fontSize(AppConstants.FONT_MD)
                  .fontColor(this.selectedCategory !== '' ? ThemeManager.TEXT_PRIMARY : ThemeManager.TEXT_HINT)
                Blank()
                Image($r('sys.symbol.chevron_right'))
                  .width(14)
                  .height(14)
                  .fillColor(ThemeManager.TEXT_HINT)
              }
              .layoutWeight(1)
              .onClick(() => { this.showCategoryPicker = true; })
            }

            FormItem({ label: '成色' }) {
              Row() {
                Text(this.selectedCondition !== '' ? this.selectedCondition : '请选择成色')
                  .fontSize(AppConstants.FONT_MD)
                  .fontColor(this.selectedCondition !== '' ? ThemeManager.TEXT_PRIMARY : ThemeManager.TEXT_HINT)
                Blank()
                Image($r('sys.symbol.chevron_right'))
                  .width(14)
                  .height(14)
                  .fillColor(ThemeManager.TEXT_HINT)
              }
              .layoutWeight(1)
              .onClick(() => { this.showConditionPicker = true; })
            }

            FormItem({ label: '售价 ¥', required: true }) {
              Row({ space: 8 }) {
                TextInput({ text: this.price, placeholder: '0.00' })
                  .fontSize(AppConstants.FONT_MD)
                  .type(InputType.Number)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .onChange((text: string) => { this.price = text; })
                Button('AI估价')
                  .fontSize(AppConstants.FONT_XS)
                  .backgroundColor('#E8F8F0')
                  .fontColor(ThemeManager.COLOR_PRIMARY)
                  .borderRadius(14)
                  .height(26)
                  .padding({ left: 10, right: 10 })
                  .enabled(!this.isPricing)
                  .onClick(() => { this.doPricing(); })
              }
              .layoutWeight(1)
            }

            if (this.isPricing) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color(ThemeManager.COLOR_PRIMARY)
                Text('AI估价中...')
                  .fontSize(AppConstants.FONT_SM)
                  .fontColor(ThemeManager.COLOR_PRIMARY)
              }
              .width('100%')
              .padding({ left: 78, top: 4, bottom: 4 })
              .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
            }

            if (this.pricingResult.success) {
              AIPricingResultCard({
                result: this.pricingResult,
                onAdopt: (price: number) => {
                  this.price = price.toString();
                  this.pricingResult = new PricingResult();
                }
              })
              .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.95, y: 0.95 })).animation({ duration: 300 }))
            }

            FormItem({ label: '原价 ¥' }) {
              TextInput({ text: this.originalPrice, placeholder: '选填' })
                .fontSize(AppConstants.FONT_MD)
                .type(InputType.Number)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((text: string) => { this.originalPrice = text; })
            }
          }
          .width('100%')
          .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
          .backgroundColor(ThemeManager.BG_CARD)
          .borderRadius(AppConstants.RADIUS_LG)
          .margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM })

          Column() {
            Row() {
              Text('商品描述')
                .fontSize(AppConstants.FONT_LG)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeManager.TEXT_PRIMARY)
              Blank()
              Button('AI生成描述')
                .fontSize(AppConstants.FONT_XS)
                .backgroundColor('#E8F8F0')
                .fontColor(ThemeManager.COLOR_PRIMARY)
                .borderRadius(14)
                .height(26)
                .padding({ left: 10, right: 10 })
                .enabled(!this.isGeneratingDesc)
                .onClick(() => { this.doGenerateDesc(); })
            }
            .width('100%')

            if (this.isGeneratingDesc) {
              Row({ space: 6 }) {
                LoadingProgress()
                  .width(14)
                  .height(14)
                  .color(ThemeManager.COLOR_PRIMARY)
                Text('AI生成中...')
                  .fontSize(AppConstants.FONT_SM)
                  .fontColor(ThemeManager.COLOR_PRIMARY)
              }
              .width('100%')
              .margin({ top: 6 })
              .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
            }

            TextArea({ text: this.description, placeholder: '描述商品使用情况、购买时间、瑕疵等...' })
              .fontSize(AppConstants.FONT_MD)
              .height(120)
              .backgroundColor(ThemeManager.BG_PRIMARY)
              .borderRadius(AppConstants.RADIUS_MD)
              .padding(AppConstants.SPACING_MD)
              .margin({ top: AppConstants.SPACING_SM })
              .onChange((text: string) => { this.description = text; })
          }
          .width('100%')
          .padding(AppConstants.SPACING_MD)
          .backgroundColor(ThemeManager.BG_CARD)
          .borderRadius(AppConstants.RADIUS_LG)
          .margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_LG })

          Blank().height(80)
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)

    if (this.showCategoryPicker) {
      this.CategoryPickerDialog()
    }
    if (this.showConditionPicker) {
      this.ConditionPickerDialog()
    }
    if (this.showImageSourcePicker) {
      this.ImageSourcePickerDialog()
    }

    }
    .width('100%')
    .height('100%')
  }

  @Builder CategoryPickerDialog() {
    Column() {
      Blank()
      Column() {
        Row() {
          Blank()
          Column()
            .width(36)
            .height(4)
            .borderRadius(2)
            .backgroundColor(ThemeManager.DIVIDER)
          Blank()
        }
        .width('100%')
        .padding({ top: 10, bottom: 6 })

        Row() {
          Text('选择分类')
            .fontSize(AppConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.TEXT_PRIMARY)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('取消')
            .fontSize(AppConstants.FONT_MD)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .onClick(() => { this.showCategoryPicker = false; })
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })

        Divider().color(ThemeManager.DIVIDER)

        Grid() {
          ForEach(AppConstants.CATEGORIES, (cat: string) => {
            GridItem() {
              Text(cat)
                .fontSize(AppConstants.FONT_MD)
                .fontColor(this.selectedCategory === cat ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_PRIMARY)
                .fontWeight(this.selectedCategory === cat ? FontWeight.Medium : FontWeight.Normal)
                .width('100%')
                .height(44)
                .textAlign(TextAlign.Center)
                .borderRadius(AppConstants.RADIUS_MD)
                .backgroundColor(this.selectedCategory === cat ? '#E8F8F0' : Color.Transparent)
            }
            .onClick(() => {
              this.selectedCategory = cat;
              this.showCategoryPicker = false;
            })
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(AppConstants.SPACING_XS)
        .columnsGap(AppConstants.SPACING_XS)
        .width('100%')
        .height(220)
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM })
      }
      .width('100%')
      .backgroundColor(ThemeManager.BG_CARD)
      .borderRadius({ topLeft: 20, topRight: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')

    .onClick(() => { this.showCategoryPicker = false; })
    .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
    .zIndex(999)
  }

  @Builder ConditionPickerDialog() {
    Column() {
      Blank()
      Column() {
        Row() {
          Blank()
          Column()
            .width(36)
            .height(4)
            .borderRadius(2)
            .backgroundColor(ThemeManager.DIVIDER)
          Blank()
        }
        .width('100%')
        .padding({ top: 10, bottom: 6 })

        Row() {
          Text('选择成色')
            .fontSize(AppConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.TEXT_PRIMARY)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('取消')
            .fontSize(AppConstants.FONT_MD)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .onClick(() => { this.showConditionPicker = false; })
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })

        Divider().color(ThemeManager.DIVIDER)

        Column({ space: AppConstants.SPACING_SM }) {
          ForEach([ProductCondition.BRAND_NEW, ProductCondition.LIKE_NEW, ProductCondition.LIGHTLY_USED, ProductCondition.NORMAL_USED], (cond: string) => {
            Row() {
              Text(cond)
                .fontSize(AppConstants.FONT_MD)
                .fontColor(this.selectedCondition === cond ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_PRIMARY)
                .fontWeight(this.selectedCondition === cond ? FontWeight.Medium : FontWeight.Normal)
                .layoutWeight(1)
              if (this.selectedCondition === cond) {
                Image($r('sys.symbol.checkmark_circle_fill'))
                  .width(20)
                  .height(20)
                  .fillColor(ThemeManager.COLOR_PRIMARY)
              }
            }
            .width('100%')
            .height(48)
            .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
            .borderRadius(AppConstants.RADIUS_MD)
            .backgroundColor(this.selectedCondition === cond ? '#E8F8F0' : Color.Transparent)
            .onClick(() => {
              this.selectedCondition = cond;
              this.showConditionPicker = false;
            })
          })
        }
        .width('100%')
        .padding({ top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_LG })
      }
      .width('100%')
      .backgroundColor(ThemeManager.BG_CARD)
      .borderRadius({ topLeft: 20, topRight: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')

    .onClick(() => { this.showConditionPicker = false; })
    .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
    .zIndex(999)
  }

  @Builder ImageSourcePickerDialog() {
    Column() {
      Blank()
      Column() {
        Row() {
          Blank()
          Column()
            .width(36)
            .height(4)
            .borderRadius(2)
            .backgroundColor(ThemeManager.DIVIDER)
          Blank()
        }
        .width('100%')
        .padding({ top: 10, bottom: 6 })

        Text('选择图片来源')
          .fontSize(AppConstants.FONT_LG)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_MD })

        Row({ space: AppConstants.SPACING_XXL }) {
          Column({ space: 10 }) {
            Column() {
              Image($r('sys.symbol.camera_fill'))
                .width(28)
                .height(28)
                .fillColor(ThemeManager.COLOR_PRIMARY)
            }
            .width(56)
            .height(56)
            .borderRadius(28)
            .backgroundColor('#E8F8F0')
            .justifyContent(FlexAlign.Center)
            Text('从相册选择')
              .fontSize(AppConstants.FONT_MD)
              .fontColor(ThemeManager.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
          }
          .onClick(() => { this.selectFromGallery(); })

          if (DeviceAdapterManager.hasCapability('camera')) {
            Column({ space: 10 }) {
              Column() {
                Image($r('sys.symbol.camera_fill'))
                  .width(28)
                  .height(28)
                  .fillColor(ThemeManager.COLOR_PRIMARY)
              }
              .width(56)
              .height(56)
              .borderRadius(28)
              .backgroundColor('#E8F8F0')
              .justifyContent(FlexAlign.Center)
              Text('拍照')
                .fontSize(AppConstants.FONT_MD)
                .fontColor(ThemeManager.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
            }
            .onClick(() => { this.takePhoto(); })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: AppConstants.SPACING_MD, bottom: AppConstants.SPACING_LG })

        Divider().color(ThemeManager.DIVIDER)

        Text('取消')
          .fontSize(AppConstants.FONT_MD)
          .fontColor(ThemeManager.TEXT_SECONDARY)
          .width('100%')
          .height(48)
          .textAlign(TextAlign.Center)
          .onClick(() => { this.showImageSourcePicker = false; })
      }
      .width('100%')
      .backgroundColor(ThemeManager.BG_CARD)
      .borderRadius({ topLeft: 20, topRight: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')

    .onClick(() => { this.showImageSourcePicker = false; })
    .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
    .zIndex(999)
  }
}

// ========== 消息页 ==========
@Component
struct MessagePageView {
  @State conversations: Conversation[] = [];

  aboutToAppear(): void {
    this.conversations = messageRepository.getConversations();
  }

  build() {
    Column() {
      Row() {
        Text('消息')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 48, bottom: AppConstants.SPACING_SM })

      if (this.conversations.length === 0) {
        EmptyState({ icon: $r('sys.symbol.message_fill'), message: '暂无消息' })
      } else {
        List({ space: 0 }) {
          ForEach(this.conversations, (conv: Conversation) => {
            ListItem() {
              Row({ space: AppConstants.SPACING_MD }) {
                // 头像
                Stack() {
                  Image(conv.targetUserAvatar !== '' ? conv.targetUserAvatar : $r('sys.symbol.person_crop_circle_fill'))
                    .width(48)
                    .height(48)
                    .borderRadius(24)
                    .objectFit(ImageFit.Cover)

                  if (conv.unreadCount > 0) {
                    Text(conv.unreadCount > 99 ? '99+' : conv.unreadCount.toString())
                      .fontSize(10)
                      .fontColor(Color.White)
                      .backgroundColor(ThemeManager.COLOR_PRICE)
                      .borderRadius(10)
                      .width(conv.unreadCount > 9 ? 20 : 16)
                      .height(16)
                      .textAlign(TextAlign.Center)
                      .position({ right: -6, top: -4 })
                  }
                }

                // 会话信息
                Column({ space: 4 }) {
                  Row() {
                    Text(conv.targetUserName)
                      .fontSize(AppConstants.FONT_LG)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(ThemeManager.TEXT_PRIMARY)
                      .maxLines(1)
                      .layoutWeight(1)
                    Text(DateUtils.formatTimeAgo(conv.lastMessageTime))
                      .fontSize(AppConstants.FONT_XS)
                      .fontColor(ThemeManager.TEXT_HINT)
                  }
                  .width('100%')

                  Row({ space: 6 }) {
                    Text(conv.productTitle)
                      .fontSize(AppConstants.FONT_XS)
                      .fontColor(ThemeManager.COLOR_PRIMARY)
                      .backgroundColor('rgba(0,185,107,0.08)')
                      .borderRadius(AppConstants.RADIUS_SM)
                      .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                      .maxLines(1)
                    Text(conv.lastMessage)
                      .fontSize(AppConstants.FONT_SM)
                      .fontColor(ThemeManager.TEXT_HINT)
                      .maxLines(1)
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_MD, bottom: AppConstants.SPACING_MD })
            }
            .onClick(() => {
              RouterManager.toChat(conv.id, conv.targetUserName, conv.targetUserId);
            })
          })
        }
        .layoutWeight(1)
        .width('100%')
        .height('100%')
        .divider({ strokeWidth: 0.5, color: ThemeManager.DIVIDER })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_CARD)
  }
}

// ========== 个人中心页 ==========
@Component
struct ProfilePageView {
  @State user: User = userRepository.getCurrentUser();
  @State productCount: number = 0;
  @State soldCount: number = 0;
  @State favoriteCount: number = 0;

  aboutToAppear(): void {
    const user = userRepository.getCurrentUser();
    this.productCount = productRepository.getProductsBySeller(user.id).length;
    this.soldCount = user.soldCount;
    this.favoriteCount = productRepository.getFavoriteProducts().length;
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Column() {
          Row({ space: 12 }) {
            Stack() {
              Image(this.user.avatar !== '' ? this.user.avatar : $r('sys.symbol.person_crop_circle_fill'))
                .width(52)
                .height(52)
                .borderRadius(26)
                .objectFit(ImageFit.Cover)
            }

            Column({ space: 6 }) {
              Row({ space: 8 }) {
                Text(this.user.nickname)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                  .maxLines(1)

                Text(`信用：${this.user.creditLevel}`)
                  .fontSize(11)
                  .fontColor(ThemeManager.COLOR_PRIMARY)
                  .backgroundColor('#E8F8F0')
                  .borderRadius(10)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              }

              Row({ space: 16 }) {
                Text(`发布 ${this.user.productCount}`)
                  .fontSize(13)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
                Text(`售出 ${this.user.soldCount}`)
                  .fontSize(13)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
                Text(`粉丝 ${this.user.followerCount}`)
                  .fontSize(13)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
              }

              Text(this.user.bio)
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_HINT)
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Image($r('sys.symbol.chevron_right'))
              .width(16)
              .height(16)
              .fillColor(ThemeManager.TEXT_HINT)
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .backgroundColor('#F5F7FA')
        .borderRadius(16)
        .margin({ left: 16, right: 16, top: 32 })

        Row() {
          Column({ space: 4 }) {
            Text(this.productCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            Text('我的发布')
              .fontSize(12)
              .fontColor(ThemeManager.TEXT_SECONDARY)
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text(this.soldCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            Text('已售出')
              .fontSize(12)
              .fontColor(ThemeManager.TEXT_SECONDARY)
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text(this.favoriteCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            Text('我的收藏')
              .fontSize(12)
              .fontColor(ThemeManager.TEXT_SECONDARY)
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('128')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            Text('浏览记录')
              .fontSize(12)
              .fontColor(ThemeManager.TEXT_SECONDARY)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .backgroundColor(ThemeManager.BG_CARD)
        .borderRadius(16)
        .padding({ top: 16, bottom: 16 })
        .margin({ left: 16, right: 16 })

        Column() {
          Row() {
            Text('我的订单')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            Blank()
            Row({ space: 4 }) {
              Text('全部')
                .fontSize(13)
                .fontColor(ThemeManager.TEXT_HINT)
              Image($r('sys.symbol.chevron_right'))
                .width(14)
                .height(14)
                .fillColor(ThemeManager.TEXT_HINT)
            }
            .onClick(() => RouterManager.toOrderCenter())
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })

          Row() {
            Column({ space: 6 }) {
              Stack() {
                Column()
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor('#FFF7E6')
                Image($r('sys.symbol.creditcard_fill'))
                  .width(20)
                  .height(20)
                  .fillColor('#FAAD14')
              }
              Text('待付款')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
            }
            .layoutWeight(1)

            Column({ space: 6 }) {
              Stack() {
                Column()
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor('#E6F7FF')
                Image($r('sys.symbol.gift_fill'))
                  .width(20)
                  .height(20)
                  .fillColor('#1890FF')
              }
              Text('待发货')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
            }
            .layoutWeight(1)

            Column({ space: 6 }) {
              Stack() {
                Column()
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor('#E6FFFB')
                Image($r('sys.symbol.truck_box_fill'))
                  .width(20)
                  .height(20)
                  .fillColor('#13C2C2')
              }
              Text('待收货')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
            }
            .layoutWeight(1)

            Column({ space: 6 }) {
              Stack() {
                Column()
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor('#F6FFED')
                Image($r('sys.symbol.checkmark_circle_fill'))
                  .width(20)
                  .height(20)
                  .fillColor('#52C41A')
              }
              Text('已完成')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
          .padding({ top: 16, bottom: 16 })
        }
        .width('100%')
        .backgroundColor(ThemeManager.BG_CARD)
        .borderRadius(16)
        .margin({ left: 16, right: 16 })

        Column() {
          Row({ space: 10 }) {
            Stack() {
              Column()
                .width(28)
                .height(28)
                .borderRadius(6)
                .backgroundColor('#E6F7FF')
              Image($r('sys.symbol.leaf_fill'))
                .width(16)
                .height(16)
                .fillColor('#1890FF')
            }
            Text('碳积分中心')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.TEXT_PRIMARY)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 8 })

          Column() {
            Row() {
              Image($r('sys.symbol.gift_fill'))
                .width(20)
                .height(20)
                .fillColor('#FF6B35')
              Text('积分商城')
                .fontSize(15)
                .fontColor('#333333')
                .margin({ left: 12 })
                .layoutWeight(1)
              Image($r('sys.symbol.chevron_right'))
                .width(14)
                .height(14)
                .fillColor(ThemeManager.TEXT_HINT)
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => RouterManager.toCreditMall())

            Row()
              .width('100%')
              .height(0.5)
              .backgroundColor('#E8E8E8')
              .margin({ left: 48 })

            Row() {
              Image($r('sys.symbol.bell_fill'))
                .width(20)
                .height(20)
                .fillColor('#1890FF')
              Text('消息通知')
                .fontSize(15)
                .fontColor('#333333')
                .margin({ left: 12 })
                .layoutWeight(1)
              Image($r('sys.symbol.chevron_right'))
                .width(14)
                .height(14)
                .fillColor(ThemeManager.TEXT_HINT)
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)

            Row()
              .width('100%')
              .height(0.5)
              .backgroundColor('#E8E8E8')
              .margin({ left: 48 })

            Row() {
              Image($r('sys.symbol.gearshape_fill'))
                .width(20)
                .height(20)
                .fillColor('#999999')
              Text('设置')
                .fontSize(15)
                .fontColor('#333333')
                .margin({ left: 12 })
                .layoutWeight(1)
              Image($r('sys.symbol.chevron_right'))
                .width(14)
                .height(14)
                .fillColor(ThemeManager.TEXT_HINT)
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }
          .padding({ bottom: 8 })
        }
        .width('100%')
        .backgroundColor(ThemeManager.BG_CARD)
        .borderRadius(16)
        .margin({ left: 16, right: 16 })

        Blank().height(120)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .scrollBar(BarState.Off)
  }
}

// ========== 子组件定义 ==========

@Component
struct SectionHeader {
  @Prop title: string;

  build() {
    Row() {
      Text(this.title)
        .fontSize(AppConstants.FONT_LG)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeManager.TEXT_PRIMARY)
      Blank()
      Text('更多 >')
        .fontSize(AppConstants.FONT_SM)
        .fontColor(ThemeManager.TEXT_HINT)
    }
    .width('100%')
    .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
  }
}

@Component
struct CategoryIconGrid {
  @Prop icons: CategoryIconItem[];
  @State pressedCategory: string = '';
  onCategoryClick?: (category: string) => void;

  build() {
    Grid() {
      ForEach(this.icons, (item: CategoryIconItem) => {
        GridItem() {
          Column({ space: 6 }) {
            Column() {
              Image(item.icon)
                .width(24)
                .height(24)
                .fillColor(item.color)
            }
            .width(48)
            .height(48)
            .borderRadius(AppConstants.RADIUS_MD)
            .backgroundColor(item.color + '15')
            .justifyContent(FlexAlign.Center)

            Text(item.name)
              .fontSize(AppConstants.FONT_XS)
              .fontColor(ThemeManager.TEXT_SECONDARY)
          }
          .scale({ x: this.pressedCategory === item.name ? 0.9 : 1, y: this.pressedCategory === item.name ? 0.9 : 1 })
          .animation({ duration: 150, curve: Curve.EaseOut })
          .onClick(() => {
            if (this.onCategoryClick) {
              this.onCategoryClick(item.name);
            }
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.pressedCategory = item.name;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.pressedCategory = '';
            }
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(AppConstants.SPACING_MD)
    .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
    .height(120)
  }
}

@Component
struct WaterfallGrid {
  @Prop products: Product[];

  build() {
    if (this.products.length === 0) {
      EmptyState({ message: '暂无商品' })
    } else {
      Grid() {
        ForEach(this.products, (product: Product) => {
          GridItem() {
            ProductCard({
              product: product,
              onCardClick: () => RouterManager.toProductDetail(product.id)
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(AppConstants.SPACING_SM)
      .rowsGap(AppConstants.SPACING_SM)
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
      .layoutWeight(1)
    }
  }
}

@Component
struct NearbyProducts {
  @Prop products: Product[];
  @State pressedId: string = '';

  build() {
    Column({ space: AppConstants.SPACING_SM }) {
      ForEach(this.products, (product: Product) => {
        Row({ space: AppConstants.SPACING_MD }) {
          Image(product.images && product.images.length > 0 && product.images[0] !== '' ? product.images[0] : $r('app.media.startIcon'))
            .width(100)
            .height(100)
            .borderRadius(AppConstants.RADIUS_MD)
            .objectFit(ImageFit.Cover)

          Column({ space: 4 }) {
            Text(product.title)
              .fontSize(AppConstants.FONT_MD)
              .fontColor(ThemeManager.TEXT_PRIMARY)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Row({ space: 4 }) {
              Text('¥')
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.COLOR_PRICE)
              Text(product.price.toString())
                .fontSize(AppConstants.FONT_XL)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeManager.COLOR_PRICE)
            }
            Row() {
              Text(product.location)
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.TEXT_HINT)
              Text(' · ')
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.TEXT_HINT)
              Text(product.distance)
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.TEXT_HINT)
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('sys.symbol.chevron_right'))
            .width(16)
            .height(16)
            .fillColor(ThemeManager.TEXT_HINT)
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })
        .backgroundColor(this.pressedId === product.id ? ThemeManager.BG_PRIMARY : Color.Transparent)
        .borderRadius(AppConstants.RADIUS_MD)
        .animation({ duration: 150 })
        .onClick(() => RouterManager.toProductDetail(product.id))
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.pressedId = product.id;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.pressedId = '';
          }
        })
      })
    }
  }
}


@Component
struct FormItem {
  @Prop label: string = '';
  @Prop required: boolean = false;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder defaultContent() {}

  build() {
    Row({ space: AppConstants.SPACING_SM }) {
      Row() {
        if (this.required) {
          Text('*')
            .fontSize(AppConstants.FONT_MD)
            .fontColor(ThemeManager.COLOR_PRICE)
        }
        Text(this.label)
          .fontSize(AppConstants.FONT_MD)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width(70)

      this.content()
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)
  }
}

@Component
struct StatItem {
  @Prop label: string;
  @Prop value: string;
  @State isPressed: boolean = false;
  onItemClick?: () => void;

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(AppConstants.FONT_XXL)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeManager.TEXT_PRIMARY)
      Text(this.label)
        .fontSize(AppConstants.FONT_SM)
        .fontColor(ThemeManager.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .scale({ x: this.isPressed ? 0.92 : 1, y: this.isPressed ? 0.92 : 1 })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .onClick(() => {
      if (this.onItemClick) this.onItemClick();
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
  }
}

@Component
struct OrderStatusIcon {
  @Prop icon: ResourceStr;
  @Prop label: string;
  @State isPressed: boolean = false;

  build() {
    Column({ space: 6 }) {
      Image(this.icon)
        .width(24)
        .height(24)
        .fillColor(ThemeManager.TEXT_SECONDARY)
      Text(this.label)
        .fontSize(AppConstants.FONT_XS)
        .fontColor(ThemeManager.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .scale({ x: this.isPressed ? 0.9 : 1, y: this.isPressed ? 0.9 : 1 })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .onClick(() => RouterManager.toOrderCenter())
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
  }
}

@Component
struct ProfileMenuItem {
  @Prop icon: ResourceStr;
  @Prop label: string;
  @Prop color: string = '#333';
  onAction?: () => void;
  @State isPressed: boolean = false;

  build() {
    Row({ space: AppConstants.SPACING_MD }) {
      Image(this.icon)
        .width(22)
        .height(22)
        .fillColor(this.color)
      Text(this.label)
        .fontSize(AppConstants.FONT_MD)
        .fontColor(ThemeManager.TEXT_PRIMARY)
        .layoutWeight(1)
      Image($r('sys.symbol.chevron_right'))
        .width(14)
        .height(14)
        .fillColor(ThemeManager.TEXT_HINT)
    }
    .width('100%')
    .height(48)
    .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.isPressed ? ThemeManager.BG_PRIMARY : Color.Transparent)
    .animation({ duration: 150 })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onClick(() => {
      if (this.onAction) {
        this.onAction();
      }
    })
  }
}


