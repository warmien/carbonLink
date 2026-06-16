import { ProductCondition } from '../models/Product';
import { SPU } from '../models/SPU';
import { User } from '../models/User';
import { Conversation, WsConnectionState } from '../models/Message';

import { productRepository } from '../repository/ProductRepository';

import { userRepository } from '../repository/UserRepository';
import { messageRepository } from '../repository/MessageRepository';
import { DateUtils } from '../utils/DateUtils';
import { ProductCard } from '../components/ProductCard';
import { AISearchBar } from '../components/AISearchBar';
import { BannerView } from '../components/BannerView';
import { EmptyState } from '../components/EmptyState';
import { AIRecognitionIndicator } from '../components/AIRecognitionIndicator';
import { ImagePickerPanel } from '../components/ImagePickerPanel';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';
import { AiBackendConfig } from '../constants/AiBackendConfig';
import { RouterManager } from '../router/RouterManager';
import { CreditEngine } from '../engine/CreditEngine';
import { AchievementDetector } from '../engine/AchievementDetector';
import { DeviceAdapterManager } from '../adaptation/DeviceAdapterManager';

import { ImagePickerService } from '../services/ImagePickerService';
import { AIRecognitionService } from '../services/AIRecognitionService';
import { AuthManager } from '../services/AuthManager';
import { ObsService } from '../services/ObsService';
import { HttpService } from '../services/HttpService';

import { ConversationItem } from '../views/message/ConversationItem';
import { promptAction } from '@kit.ArkUI';

class CategoryIdMap {
  private static names: string[] = ['电子数码', '图书教材', '服装鞋帽', '家居生活', '美妆护肤', '运动户外', '文具办公', '乐器文创', '虚拟服务', '其他闲置'];
  private static ids: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  static getId(name: string): number {
    for (let i = 0; i < CategoryIdMap.names.length; i++) {
      if (CategoryIdMap.names[i] === name) {
        return CategoryIdMap.ids[i];
      }
    }
    return 0;
  }
}

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
            SymbolGlyph(this.currentTabIndex === 0 ? $r('sys.symbol.house_fill') : $r('sys.symbol.house'))
              .fontSize(24)
              .fontColor(this.currentTabIndex === 0 ? [ThemeManager.COLOR_PRIMARY] : ['#000000'])
            Text('首页')
              .fontSize(10)
              .fontColor('#000000')
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
            SymbolGlyph($r('sys.symbol.leaf_fill'))
              .fontSize(24)
              .fontColor(this.currentTabIndex === 1 ? [ThemeManager.COLOR_PRIMARY] : ['#000000'])
            Text('分类')
              .fontSize(10)
              .fontColor('#000000')
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
                  colors: [[ThemeManager.COLOR_PRIMARY_LIGHT, 0], [ThemeManager.COLOR_PRIMARY_DARK, 1]]
                })
              SymbolGlyph($r('sys.symbol.plus'))
                .fontSize(24)
                .fontColor([Color.White])
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
            SymbolGlyph(this.currentTabIndex === 3 ? $r('sys.symbol.message_fill') : $r('sys.symbol.message'))
              .fontSize(24)
              .fontColor(this.currentTabIndex === 3 ? [ThemeManager.COLOR_PRIMARY] : ['#000000'])
            Text('消息')
              .fontSize(10)
              .fontColor('#000000')
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
            SymbolGlyph(this.currentTabIndex === 4 ? $r('sys.symbol.person_fill') : $r('sys.symbol.person'))
              .fontSize(24)
              .fontColor(this.currentTabIndex === 4 ? [ThemeManager.COLOR_PRIMARY] : ['#000000'])
            Text('我的')
              .fontSize(10)
              .fontColor('#000000')
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
  @State products: SPU[] = [];
  @State categoryIcons: CategoryIconItem[] = [];
  @State isFiltered: boolean = false;
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = true;
  private currentQuery: string = '';

  aboutToAppear(): void {
    this.categoryIcons = [
      new CategoryIconItem('电子数码', $r('sys.symbol.camera_fill'), '#1890FF'),
      new CategoryIconItem('图书教材', $r('sys.symbol.doc_text_fill'), '#FAAD14'),
      new CategoryIconItem('服装鞋帽', $r('sys.symbol.gift_fill'), '#FF6B35'),
      new CategoryIconItem('家居生活', $r('sys.symbol.house_fill'), '#52C41A'),
      new CategoryIconItem('美妆护肤', $r('sys.symbol.star_fill'), '#722ED1'),
      new CategoryIconItem('运动户外', $r('sys.symbol.heart_fill'), '#13C2C2'),
    ];
    this.loadProducts();
  }

  onPageShow(): void {
    const needRefresh = AppStorage.get<boolean>('needRefreshProducts') ?? false;
    if (needRefresh) {
      this.loadProducts();
      AppStorage.setOrCreate('needRefreshProducts', false);
    }
    const seq = AppStorage.get<number>('statsRefreshSeq') ?? 0;
    AppStorage.setOrCreate('statsRefreshSeq', seq + 1);
  }

  private async loadProducts(query?: string): Promise<void> {
    this.isLoading = true;
    try {
      const result = await productRepository.fetchProducts(query);
      this.products = result.list;
      this.currentQuery = query || '';
      this.isFiltered = (query !== undefined && query.length > 0);
    } catch (err) {
      this.products = [];
    }
    this.isLoading = false;
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
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.STATUS_BAR_HEIGHT })

        AISearchBar({ value: $searchKeyword, onSearch: (kw: string, productIds: string[]) => {
          if (kw !== '') {
            this.loadProducts('keyword=' + encodeURIComponent(kw));
          } else {
            this.loadProducts();
          }
        }})

        Refresh({ refreshing: $$this.isRefreshing }) {
          Scroll() {
            Column() {
              BannerView()

              SectionHeader({ title: '热门分类' })
              Scroll() {
                Row({ space: 16 }) {
                  ForEach(this.categoryIcons, (item: CategoryIconItem) => {
                    Column({ space: 6 }) {
                      Image(item.icon)
                        .width(28)
                        .height(28)
                        .fillColor(item.color)

                      Text(item.name)
                        .fontSize(AppConstants.FONT_XS)
                        .fontColor(ThemeManager.TEXT_SECONDARY)
                    }
                    .onClick(() => {
                      const catId = CategoryIdMap.getId(item.name);
                      if (catId > 0) {
                        this.loadProducts('categoryId=' + catId.toString());
                      }
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
                      this.loadProducts();
                    })
                } else {
                  Text('更多 >')
                    .fontSize(AppConstants.FONT_SM)
                    .fontColor(ThemeManager.TEXT_HINT)
                }
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_MD, bottom: AppConstants.SPACING_SM })

              if (this.products.length === 0) {
                EmptyState({ message: '暂无商品' })
                  .padding({ top: 40, bottom: 80 })
              } else {
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignContent: FlexAlign.Start }) {
                  ForEach(this.products, (spu: SPU) => {
                    ProductCard({
                      product: spu,
                      onCardClick: () => RouterManager.toProductDetail(spu.id)
                    })
                      .width('47%')
                      .margin({ left: '1.5%', right: '1.5%', bottom: AppConstants.SPACING_SM })
                  })
                }
                .width('100%')
                .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
              }

              Blank().height(100)
            }
            .width('100%')
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .onRefreshing(() => {
          this.loadProducts(this.currentQuery.length > 0 ? this.currentQuery : undefined).then(() => {
            this.isRefreshing = false;
          });
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
  @State products: SPU[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadByCategory(this.selectedCategory);
  }

  private async loadByCategory(category: string): Promise<void> {
    this.isLoading = true;
    const catId = CategoryIdMap.getId(category);
    try {
      const result = await productRepository.fetchProducts(catId > 0 ? 'categoryId=' + catId.toString() : undefined);
      this.products = result.list;
    } catch (err) {
      this.products = [];
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      Row() {
        Text('分类浏览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.STATUS_BAR_HEIGHT, bottom: AppConstants.SPACING_SM })

      Row() {
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
              this.loadByCategory(cat);
            })
          })
        }
        .width(90)
        .height('100%')
        .backgroundColor(ThemeManager.BG_PRIMARY)

        Scroll() {
          if (this.products.length === 0) {
            EmptyState({ message: '该分类暂无商品' })
          } else {
            Grid() {
              ForEach(this.products, (spu: SPU) => {
                GridItem() {
                  ProductCard({
                    product: spu,
                    onCardClick: () => RouterManager.toProductDetail(spu.id)
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
  @State selectedSubCategory: string = '';
  @State selectedCondition: string = '';
  @State calculatedCredits: number = 0;
  @State calculatedReduction: number = 0;
  @State images: string[] = [];
  @State showCategoryPicker: boolean = false;
  @State showConditionPicker: boolean = false;
  @State showImageSourcePicker: boolean = false;

  @State recognitionStatus: string = 'idle';
  @State recognitionError: string = '';
  @State isRecognizing: boolean = false;
  @State aiRecognizeScale: number = 1;
  @State isPublishing: boolean = false;
  @StorageProp('isLoggedIn') isLoggedIn: boolean = false;

  private recognizedUris: Set<string> = new Set();

  aboutToAppear(): void {

  }

  private updateCarbonCredits(): void {
    if (this.selectedCategory !== '' && this.selectedSubCategory !== '' && this.selectedCondition !== '') {
      const result = CreditEngine.calculateProductCredits(this.selectedCategory, this.selectedSubCategory, this.selectedCondition);
      this.calculatedCredits = result.carbonCredits;
      this.calculatedReduction = result.carbonReduction;
    } else if (this.selectedCategory !== '' && this.selectedSubCategory !== '') {
      const result = CreditEngine.calculateProductCredits(this.selectedCategory, this.selectedSubCategory, ProductCondition.C_GRADE);
      this.calculatedCredits = Math.round(result.carbonCredits * 100) / 100;
      this.calculatedReduction = Math.round(result.carbonReduction * 100) / 100;
    } else {
      this.calculatedCredits = 0;
      this.calculatedReduction = 0;
    }
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

  }

  private async takePhoto(): Promise<void> {
    this.showImageSourcePicker = false;
    const uri = await ImagePickerService.takePhoto();
    if (uri) {
      this.images = [...this.images, uri];

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
      if (result.itemName) {
        this.title = result.itemName;
      }
      if (result.mappedCondition) {
        this.selectedCondition = result.mappedCondition;
      }
      if (result.category) {
        const isValidCat = AppConstants.CATEGORIES.indexOf(result.category) >= 0;
        if (isValidCat) {
          this.selectedCategory = result.category;
        }
      }
      if (!this.selectedCategory && result.itemName) {
        const matchedCat = this.matchCategory(result.itemName);
        if (matchedCat) {
          this.selectedCategory = matchedCat;
        }
      }
      if (result.subCategory && this.selectedCategory) {
        const subs = AppConstants.SUB_CATEGORIES[this.selectedCategory];
        if (subs) {
          let matched = false;
          for (let i = 0; i < subs.length; i++) {
            if (subs[i] === result.subCategory || result.subCategory.indexOf(subs[i].replace('类', '')) >= 0 || subs[i].indexOf(result.subCategory) >= 0) {
              this.selectedSubCategory = subs[i];
              matched = true;
              break;
            }
          }
          if (!matched) {
            this.selectedSubCategory = subs.length > 0 ? subs[0] : '';
          }
        }
      }
      if (!this.selectedSubCategory && result.itemName && this.selectedCategory) {
        const matchedSub = this.matchSubCategory(result.itemName, this.selectedCategory);
        if (matchedSub) {
          this.selectedSubCategory = matchedSub;
        }
      }
      if (result.description) {
        this.description = result.description;
      }
      if (result.suggestedPrice > 0) {
        this.price = result.suggestedPrice.toString();
      }
      if (result.originalPrice > 0) {
        this.originalPrice = result.originalPrice.toString();
      }
      this.updateCarbonCredits();
      this.recognitionStatus = 'success';
      setTimeout(() => { this.recognitionStatus = 'idle'; }, 1500);
    } else {
      this.recognitionError = result.errorMessage;
      this.recognitionStatus = 'error';
      setTimeout(() => { this.recognitionStatus = 'idle'; }, 3000);
    }
  }

  private matchCategory(name: string): string {
    const categories: string[] = ['电子数码', '图书教材', '服装鞋帽', '家居生活', '美妆护肤', '运动户外', '文具办公', '乐器文创', '虚拟服务'];
    const keywords: string[][] = [
      ['手机', 'iPhone', 'iPad', '电脑', '笔记本', '耳机', '音箱', '手表', '平板', '相机', '键盘', '鼠标', '充电宝', '显示器', '吹风机', '收音机', '插座'],
      ['书', '教材', '小说', '杂志', '绘本', '字典', '网课'],
      ['衣服', '裤', '裙', '外套', '鞋', 'T恤', '衬衫', '夹克', '羽绒服', '包', '帽'],
      ['家具', '沙发', '床', '桌', '椅', '灯', '收纳', '装饰', '锅', '风扇', '秤', '剪刀'],
      ['护肤', '面膜', '防晒', '卸妆', '底妆', '眼妆', '唇', '美甲', '香水', '化妆'],
      ['跑步', '瑜伽', '健身', '球', '滑板', '自行车', '电动车', '跳绳'],
      ['文具', '计算器', '笔', '本'],
      ['乐器', '吉他', '钢琴', '文创', '绿植'],
      ['网课', '账号', '健身卡', '水卡'],
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

  private matchSubCategory(name: string, category: string): string {
    const subs = AppConstants.SUB_CATEGORIES[category];
    if (!subs || subs.length === 0) {
      return '';
    }
    for (let i = 0; i < subs.length; i++) {
      const sub = subs[i].replace('类', '');
      if (name.indexOf(sub) >= 0) {
        return subs[i];
      }
    }
    return subs[0];
  }

  private async reRecognize(): Promise<void> {
    if (this.images.length === 0 || this.isRecognizing) return;
    this.recognizedUris.clear();
    this.tryRecognize(this.images[0]);
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
          .onClick(async () => {
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
            const user = await AuthManager.getCurrentUser();
            if (!user) {
              promptAction.showToast({ message: '请先登录' });
              return;
            }
            const catId = CategoryIdMap.getId(this.selectedCategory);
            const createData: Record<string, string | number | object> = {};
            createData['title'] = this.title;
            createData['description'] = this.description;
            createData['categoryId'] = catId;
            createData['sellerId'] = user.id;
            createData['sellerName'] = user.nickname;
            createData['sellerAvatar'] = user.avatar;
            createData['location'] = user.location;
            createData['distance'] = '0km';
            if (this.images.length > 0) {
              this.isPublishing = true;
              const uploadedUrls = await ObsService.uploadImages(this.images);
              this.isPublishing = false;
              if (uploadedUrls.length === 0) {
                promptAction.showToast({ message: '图片上传失败，请重试' });
                return;
              }
              if (uploadedUrls.length < this.images.length) {
                promptAction.showToast({ message: `已上传${uploadedUrls.length}/${this.images.length}张图片` });
              }
              createData['images'] = uploadedUrls as object;
            } else {
              createData['images'] = [] as object;
            }
            const skuItem: Record<string, string | number | object> = {};
            skuItem['price'] = priceVal;
            skuItem['originalPrice'] = origPriceVal;
            skuItem['condition'] = this.selectedCondition || '九成新';
            skuItem['stock'] = 1;
            createData['skus'] = [skuItem] as object;
            const spu = await productRepository.createProduct(createData);
            if (spu) {
              CreditEngine.onProductPublished(spu.id, user.id);
              AchievementDetector.detect(user.id, 'publish');
              const toastMsg = this.calculatedCredits > 0 ?
                '发布成功！+10积分  碳积分+' + this.calculatedCredits :
                '发布成功！+10积分';
              promptAction.showToast({ message: toastMsg });
              this.title = '';
              this.description = '';
              this.price = '';
              this.originalPrice = '';
              this.selectedCategory = '';
              this.selectedSubCategory = '';
              this.selectedCondition = '';
              this.calculatedCredits = 0;
              this.calculatedReduction = 0;
              this.images = [];
              AppStorage.setOrCreate('needRefreshProducts', true);

            } else {
              promptAction.showToast({ message: '发布失败，请重试' });
            }
          })
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.STATUS_BAR_HEIGHT, bottom: AppConstants.SPACING_SM })

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
            if (this.isRecognizing) {
              Row({ space: 4 }) {
                LoadingProgress()
                  .width(14)
                  .height(14)
                  .color(Color.White)
                Text('识别中...')
                  .fontSize(AppConstants.FONT_XS)
                  .fontColor(Color.White)
              }
              .height(26)
              .padding({ left: 12, right: 12 })
              .borderRadius(13)
              .backgroundColor(ThemeManager.COLOR_PRIMARY)
            } else {
              Button('AI识别')
                .fontSize(AppConstants.FONT_XS)
                .backgroundColor(this.images.length > 0 ? ThemeManager.COLOR_PRIMARY : '#CCCCCC')
                .fontColor(Color.White)
                .borderRadius(13)
                .height(26)
                .padding({ left: 12, right: 12 })
                .enabled(this.images.length > 0)
                .scale({ x: this.images.length > 0 ? this.aiRecognizeScale : 1, y: this.images.length > 0 ? this.aiRecognizeScale : 1 })
                .animation({ duration: 100, curve: Curve.EaseOut })
                .onClick(() => {
                  animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.aiRecognizeScale = 0.9; });
                  setTimeout(() => { animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.aiRecognizeScale = 1; }); }, 100);
                  this.reRecognize();
    })
  }
}

          .width('100%')
          .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })

          Column() {
            Row() {
              Text('商品描述')
                .fontSize(AppConstants.FONT_LG)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeManager.TEXT_PRIMARY)
            }
            .width('100%')

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
          .margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM })

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
                Text(this.selectedCategory !== '' ? (this.selectedSubCategory !== '' ? this.selectedCategory + ' · ' + this.selectedSubCategory : this.selectedCategory) : '请选择分类')
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

            FormItem({ label: '碳积分' }) {
              Text(this.calculatedCredits > 0 ? '+' + this.calculatedCredits + ' 积分' : '选择分类和成色后计算')
                .fontSize(AppConstants.FONT_MD)
                .fontColor(this.calculatedCredits > 0 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
                .fontWeight(this.calculatedCredits > 0 ? FontWeight.Medium : FontWeight.Normal)
                .layoutWeight(1)
            }

            FormItem({ label: '碳减排' }) {
              Text(this.calculatedReduction > 0 ? this.calculatedReduction + ' kg CO₂e' : '选择分类和成色后计算')
                .fontSize(AppConstants.FONT_MD)
                .fontColor(this.calculatedReduction > 0 ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
                .fontWeight(this.calculatedReduction > 0 ? FontWeight.Medium : FontWeight.Normal)
                .layoutWeight(1)
            }

            FormItem({ label: '售价 ¥', required: true }) {
              TextInput({ text: this.price, placeholder: '0.00' })
                .fontSize(AppConstants.FONT_MD)
                .type(InputType.Number)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((text: string) => { this.price = text; })
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


          Blank().height(80)
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)

    this.PublishOverlays()

    if (!this.isLoggedIn) {
      Column() {
        EmptyState({ icon: $r('sys.symbol.plus_circle_fill'), message: '登录后即可发布闲置' })
        Button('去登录')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(ThemeManager.COLOR_PRIMARY)
          .borderRadius(20)
          .height(40)
          .padding({ left: 32, right: 32 })
          .margin({ top: 16 })
          .onClick(() => {
            RouterManager.toLogin();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255,255,255,0.95)')
      .zIndex(1000)
    }

    }
    .width('100%')
    .height('100%')
  }

  @Builder PublishOverlays() {
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

        Row() {
          Column() {
            ForEach(AppConstants.CATEGORIES, (cat: string) => {
              Text(cat)
                .fontSize(AppConstants.FONT_MD)
                .fontColor(this.selectedCategory === cat ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_PRIMARY)
                .fontWeight(this.selectedCategory === cat ? FontWeight.Medium : FontWeight.Normal)
                .width('100%')
                .height(44)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.selectedCategory === cat ? '#E8F8F0' : Color.Transparent)
                .onClick(() => {
                  this.selectedCategory = cat;
                  this.selectedSubCategory = '';
                })
            })
          }
          .width('35%')
          .backgroundColor('#F5F5F5')

          Scroll() {
            Column() {
              if (this.selectedCategory !== '') {
                ForEach(AppConstants.SUB_CATEGORIES[this.selectedCategory], (sub: string) => {
                  Text(sub)
                    .fontSize(AppConstants.FONT_MD)
                    .fontColor(this.selectedSubCategory === sub ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_PRIMARY)
                    .fontWeight(this.selectedSubCategory === sub ? FontWeight.Medium : FontWeight.Normal)
                    .width('100%')
                    .height(44)
                    .textAlign(TextAlign.Center)
                    .borderRadius(AppConstants.RADIUS_MD)
                    .backgroundColor(this.selectedSubCategory === sub ? '#E8F8F0' : Color.Transparent)
                    .onClick(() => {
                      this.selectedSubCategory = sub;
                      this.showCategoryPicker = false;
                      this.updateCarbonCredits();
                    })
                })
              }
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height(280)
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
          ForEach([ProductCondition.A_GRADE, ProductCondition.B_GRADE, ProductCondition.C_GRADE, ProductCondition.D_GRADE, ProductCondition.E_GRADE, ProductCondition.F_GRADE], (cond: string) => {
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
              this.updateCarbonCredits();
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
            Image($r('app.media.ic_gallery_pick'))
              .width(56)
              .height(56)
              .borderRadius(28)
              .objectFit(ImageFit.Cover)
            Text('从相册选择')
              .fontSize(AppConstants.FONT_MD)
              .fontColor(ThemeManager.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
          }
          .onClick(() => { this.selectFromGallery(); })

          if (DeviceAdapterManager.hasCapability('camera')) {
            Column({ space: 10 }) {
              Image($r('app.media.ic_camera_pick'))
                .width(56)
                .height(56)
                .borderRadius(28)
                .objectFit(ImageFit.Cover)
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
  @StorageProp('isLoggedIn') isLoggedIn: boolean = false;
  @State isLoading: boolean = false;
  @State loadFailed: boolean = false;
  @StorageProp('wsConvUpdatePayload') @Watch('onConvUpdate') wsConvUpdatePayload: string = '';
  @StorageProp('wsNewMessagePayload') @Watch('onNewMsg') wsNewMsgPayload: string = '';

  aboutToAppear(): void {
    if (this.isLoggedIn) {
      this.loadConversations();
    }
  }

  async loadConversations(): Promise<void> {
    this.isLoading = true;
    this.loadFailed = false;
    try {
      const result: Conversation[] = await messageRepository.getConversations();
      this.conversations = result;
    } catch (err) {
      this.loadFailed = true;
    }
    this.isLoading = false;
  }

  onConvUpdate(): void {
    if (this.wsConvUpdatePayload.length === 0) return;
    try {
      const payload: Record<string, string | number | object> = JSON.parse(this.wsConvUpdatePayload) as Record<string, string | number | object>;
      const dataRaw: string | number | object = payload['data'];
      if (typeof dataRaw !== 'object' || dataRaw === null) return;
      const data: Record<string, string | number | object> = dataRaw as Record<string, string | number | object>;
      const updatedConv: Conversation = new Conversation();
      updatedConv.id = data['id'] as string;
      updatedConv.targetUserId = data['targetUserId'] as string;
      updatedConv.targetUserName = data['targetUserName'] as string;
      updatedConv.targetUserAvatar = typeof data['targetUserAvatar'] === 'string' ? data['targetUserAvatar'] as string : '';
      updatedConv.productId = typeof data['productId'] === 'string' ? data['productId'] as string : '';
      updatedConv.productTitle = typeof data['productTitle'] === 'string' ? data['productTitle'] as string : '';
      updatedConv.productImage = typeof data['productImage'] === 'string' ? data['productImage'] as string : '';
      updatedConv.lastMessage = typeof data['lastMessage'] === 'string' ? data['lastMessage'] as string : '';
      updatedConv.lastMessageTime = typeof data['lastMessageTime'] === 'number' ? data['lastMessageTime'] as number : 0;
      updatedConv.unreadCount = typeof data['unreadCount'] === 'number' ? data['unreadCount'] as number : 0;

      const idx: number = this.findConversationIndex(updatedConv.id);
      if (idx >= 0) {
        this.conversations[idx] = updatedConv;
      } else {
        this.conversations.splice(0, 0, updatedConv);
      }
      this.sortConversations();
      this.refreshTotalUnread();
    } catch (err) {
      // ignore
    }
  }

  onNewMsg(): void {
    if (this.wsNewMsgPayload.length === 0) return;
    try {
      const payload: Record<string, string | number | object> = JSON.parse(this.wsNewMsgPayload) as Record<string, string | number | object>;
      const dataRaw: string | number | object = payload['data'];
      if (typeof dataRaw !== 'object' || dataRaw === null) return;
      const data: Record<string, string | number | object> = dataRaw as Record<string, string | number | object>;
      const convId: string = data['conversationId'] as string;
      const idx: number = this.findConversationIndex(convId);
      if (idx >= 0) {
        const conv: Conversation = this.conversations[idx];
        conv.lastMessage = typeof data['content'] === 'string' ? data['content'] as string : '';
        conv.lastMessageTime = typeof data['timestamp'] === 'number' ? data['timestamp'] as number : Date.now();
        const senderId: string = data['senderId'] as string;
        if (senderId !== this.getCurrentUserId()) {
          conv.unreadCount = conv.unreadCount + 1;
        }
        this.sortConversations();
        this.refreshTotalUnread();
      }
    } catch (err) {
      // ignore
    }
  }

  findConversationIndex(convId: string): number {
    for (let i = 0; i < this.conversations.length; i++) {
      if (this.conversations[i].id === convId) {
        return i;
      }
    }
    return -1;
  }

  sortConversations(): void {
    const sorted: Conversation[] = [...this.conversations];
    sorted.sort((a: Conversation, b: Conversation) => b.lastMessageTime - a.lastMessageTime);
    this.conversations = sorted;
  }

  refreshTotalUnread(): void {
    let total: number = 0;
    for (let i = 0; i < this.conversations.length; i++) {
      total += this.conversations[i].unreadCount;
    }
    AppStorage.setOrCreate('totalUnread', total);
  }

  getCurrentUserId(): string {
    const userJson: string = AppStorage.get<string>('currentUser') || '';
    if (userJson.length === 0) {
      return '';
    }
    try {
      const userObj: Record<string, string | number> = JSON.parse(userJson) as Record<string, string | number>;
      return userObj['id'] as string;
    } catch (err) {
      return '';
    }
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
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.STATUS_BAR_HEIGHT, bottom: AppConstants.SPACING_SM })

      if (!this.isLoggedIn) {
        Column() {
          EmptyState({ icon: $r('sys.symbol.message_fill'), message: '请先登录查看消息' })
          Button('去登录')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor(ThemeManager.COLOR_PRIMARY)
            .borderRadius(20)
            .height(40)
            .padding({ left: 32, right: 32 })
            .margin({ top: 16 })
            .onClick(() => {
              RouterManager.toLogin();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(ThemeManager.COLOR_PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.loadFailed) {
        Column() {
          Text('加载失败，点击重试')
            .fontSize(AppConstants.FONT_MD)
            .fontColor(ThemeManager.TEXT_SECONDARY)
            .onClick(() => {
              this.loadConversations();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.conversations.length === 0) {
        EmptyState({ icon: $r('sys.symbol.message_fill'), message: '暂无消息' })
      } else {
        List({ space: 0 }) {
          ForEach(this.conversations, (conv: Conversation) => {
            ListItem() {
              ConversationItem({ conversation: conv })
            }
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
  @State user: User = new User();
  @State productCount: number = 0;
  @State soldCount: number = 0;
  @State favoriteCount: number = 0;
  @State browseCount: number = 0;
  @StorageProp('isLoggedIn') isLoggedIn: boolean = false;
  @StorageProp('currentUser') @Watch('onUserChanged') currentUserJson: string = '';
  @StorageProp('statsRefreshSeq') @Watch('onStatsRefreshSeq') statsRefreshSeq: number = 0;
  private statsTimer: number = -1;

  aboutToAppear(): void {
    this.loadUserData();
    this.startStatsTimer();
  }

  aboutToDisappear(): void {
    if (this.statsTimer !== -1) {
      clearInterval(this.statsTimer);
      this.statsTimer = -1;
    }
  }

  onUserChanged(): void {
    this.loadUserData();
  }

  onStatsRefreshSeq(): void {
    this.loadUserStats();
  }

  private startStatsTimer(): void {
    this.statsTimer = setInterval(() => {
      if (this.isLoggedIn) {
        this.loadUserStats();
      }
    }, 5000) as number;
  }

  loadUserData(): void {
    if (this.isLoggedIn && this.currentUserJson.length > 0) {
      try {
        const userObj: Record<string, string | number> = JSON.parse(this.currentUserJson) as Record<string, string | number>;
        this.user = new User();
        this.user.id = userObj['id'] as string;
        this.user.nickname = userObj['nickname'] as string;
        this.user.avatar = userObj['avatar'] as string;
        this.user.phone = userObj['phone'] as string;
        this.user.gender = userObj['gender'] as string;
        this.user.bio = userObj['bio'] as string;
        const csVal = userObj['creditScore'];
        this.user.creditScore = typeof csVal === 'number' ? csVal : 0;
        this.user.creditLevel = userObj['creditLevel'] as string;
        this.user.productCount = 0;
        this.user.soldCount = 0;
        const fcVal = userObj['followerCount'];
        this.user.followerCount = typeof fcVal === 'number' ? fcVal : 0;
        const fgcVal = userObj['followingCount'];
        this.user.followingCount = typeof fgcVal === 'number' ? fgcVal : 0;
        this.user.joinDate = userObj['joinDate'] as string;
        this.user.location = userObj['location'] as string;
        this.loadUserStats();
      } catch (err) {
        this.user = userRepository.getCurrentUser();
      }
    } else {
      this.user = userRepository.getCurrentUser();
    }
  }

  async loadUserStats(): Promise<void> {
    try {
      const resp = await HttpService.GET('/stats');
      if (resp.code === 0 && resp.data !== null) {
        const data: Record<string, string | number | object> = resp.data;
        this.productCount = typeof data['productCount'] === 'number' ? data['productCount'] as number : 0;
        this.soldCount = typeof data['soldCount'] === 'number' ? data['soldCount'] as number : 0;
        this.favoriteCount = typeof data['favoriteCount'] === 'number' ? data['favoriteCount'] as number : 0;
        this.browseCount = typeof data['browseCount'] === 'number' ? data['browseCount'] as number : 0;
      }
    } catch (err) {
      this.productCount = this.user.productCount;
      this.soldCount = this.user.soldCount;
    }
  }


  build() {
    Scroll() {
      Column({ space: 12 }) {
        Column() {
          Row({ space: 12 }) {
            if (this.isLoggedIn) {
              Stack() {
                Image(this.user.avatar !== '' ? this.user.avatar : $r('sys.symbol.person_crop_circle_fill'))
                  .width(52)
                  .height(52)
                  .borderRadius(26)
                  .objectFit(ImageFit.Cover)
              }
            } else {
              Stack() {
                Image($r('sys.symbol.person_crop_circle_fill'))
                  .width(52)
                  .height(52)
                  .borderRadius(26)
                  .fillColor('#CCCCCC')
              }
            }

            if (this.isLoggedIn) {
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
                  Text(`发布 ${this.productCount}`)
                    .fontSize(13)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                  Text(`售出 ${this.soldCount}`)
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
            } else {
              Column({ space: 6 }) {
                Text('点击登录')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeManager.TEXT_PRIMARY)

                Text('游客模式 · 登录后查看更多信息')
                  .fontSize(13)
                  .fontColor(ThemeManager.TEXT_HINT)
                }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .onClick(() => {
                RouterManager.toLogin();
              })
            }

            if (this.isLoggedIn) {
              Image($r('sys.symbol.gearshape_fill'))
                .width(22)
                .height(22)
                .fillColor(ThemeManager.TEXT_SECONDARY)
                .onClick(() => {
                  RouterManager.toSettings();
                })
            } else {
              Image($r('sys.symbol.chevron_right'))
                .width(16)
                .height(16)
                .fillColor(ThemeManager.TEXT_HINT)
            }
          }
          .width('100%')
          .padding(16)
          .onClick(() => {
            if (this.isLoggedIn) {
              RouterManager.toEditProfile();
            } else {
              RouterManager.toLogin();
            }
          })
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
          .onClick(() => {
            if (this.isLoggedIn) {
              RouterManager.toMyProducts();
            }
          })

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
          .onClick(() => {
            if (this.isLoggedIn) {
              RouterManager.toOrderCenter(4);
            }
          })

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
          .onClick(() => {
            if (this.isLoggedIn) {
              RouterManager.toMyFavorites();
            }
          })

          Column({ space: 4 }) {
            Text(this.browseCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            Text('浏览记录')
              .fontSize(12)
              .fontColor(ThemeManager.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .onClick(() => {
            if (this.isLoggedIn) {
              RouterManager.toBrowseHistory();
            }
          })
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
            Column() {
              Stack() {
                Column()
                  .width(56).height(56).borderRadius(28)
                Image($r('app.media.ic_order_unpaid'))
                  .width(32).height(32)
              }
              .alignContent(Alignment.Center)
              Text('待付款')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              RouterManager.toOrderCenter(1);
            })

            Column() {
              Stack() {
                Column()
                  .width(56).height(56).borderRadius(28)
                Image($r('app.media.ic_order_unshipped'))
                  .width(32).height(32)
              }
              .alignContent(Alignment.Center)
              Text('待发货')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              RouterManager.toOrderCenter(2);
            })

            Column() {
              Stack() {
                Column()
                  .width(56).height(56).borderRadius(28)
                Image($r('app.media.ic_order_shipped'))
                  .width(32).height(32)
              }
              .alignContent(Alignment.Center)
              Text('待收货')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              RouterManager.toOrderCenter(3);
            })

            Column() {
              Stack() {
                Column()
                  .width(56).height(56).borderRadius(28)
                Image($r('app.media.ic_order_completed'))
                  .width(32).height(32)
              }
              .alignContent(Alignment.Center)
              Text('已完成')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              RouterManager.toOrderCenter(4);
            })

            Column() {
              Stack() {
                Column()
                  .width(56).height(56).borderRadius(28)
                Image($r('app.media.ic_order_cancelled'))
                  .width(32).height(32)
              }
              .alignContent(Alignment.Center)
              Text('已取消')
                .fontSize(12)
                .fontColor(ThemeManager.TEXT_SECONDARY)
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              RouterManager.toOrderCenter(5);
            })
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
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
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


