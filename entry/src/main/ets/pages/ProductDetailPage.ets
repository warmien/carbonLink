import { SPU } from '../models/SPU';
import { SKU } from '../models/SKU';
import { ProductAttribute, CategorySpecTree } from '../models/Spec';
import { productRepository } from '../repository/ProductRepository';
import { messageRepository } from '../repository/MessageRepository';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { EmptyState } from '../components/EmptyState';
import { SpecSelector } from '../components/SpecSelector';
import { AttributeList } from '../components/AttributeList';
import { BehaviorCollector } from '../services/BehaviorCollector';
import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ProductDetailPage {
  @State spu: SPU | null = null;
  @State skus: SKU[] = [];
  @State selectedSku: SKU | null = null;
  @State attributes: ProductAttribute[] = [];
  @State specTree: CategorySpecTree[] = [];
  @State isFavorited: boolean = false;
  @State favCount: number = 0;
  @State currentImageIndex: number = 0;
  @State favScale: number = 1;
  @State likeCount: number = 0;
  @State isLiked: boolean = false;
  @State likeScale: number = 1;
  @State searchKeyword: string = '';
  @State showSpecSelector: boolean = false;
  @State selectedSpecNameIds: number[] = [];
  @State selectedSpecValueIds: number[] = [];
  @State isLoading: boolean = true;
  private spuId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string | number | object>;
    if (params && params['productId']) {
      this.spuId = params['productId'] as string;
      this.loadProductDetail();
    }
  }

  private async loadProductDetail(): Promise<void> {
    this.isLoading = true;
    const result = await productRepository.getProductDetail(this.spuId);
    if (result !== null) {
      this.spu = result.spu;
      this.skus = result.skus;
      this.attributes = result.attributes;
      this.isFavorited = result.spu.isFavorited;
      this.favCount = result.spu.favoriteCount;
      this.likeCount = 0;

      if (this.skus.length > 0) {
        for (let i = 0; i < this.skus.length; i++) {
          if (this.skus[i].status === 'on_sale') {
            this.selectedSku = this.skus[i];
            break;
          }
        }
        if (this.selectedSku === null) {
          this.selectedSku = this.skus[0];
        }
      }

      BehaviorCollector.recordView('user_1', this.spuId, this.spu.categoryName, this.spu.minPrice);

      const tree = await productRepository.getCategorySpecTree(result.spu.categoryId);
      this.specTree = tree;
    }
    this.isLoading = false;
  }

  handleLike(): void {
    if (this.spu === null) {
      return;
    }
    if (this.isLiked) {
      this.isLiked = false;
      this.likeCount = Math.max(0, this.likeCount - 1);
      BehaviorCollector.recordDislike('user_1', this.spuId, this.spu.categoryName, this.spu.minPrice);
    } else {
      this.isLiked = true;
      this.likeCount += 1;
      BehaviorCollector.recordLike('user_1', this.spuId, this.spu.categoryName, this.spu.minPrice);
    }
    this.likeScale = 1.3;
    setTimeout(() => { this.likeScale = 1; }, 200);
  }

  private getCurrentPrice(): number {
    if (this.selectedSku !== null) {
      return this.selectedSku.price;
    }
    if (this.spu !== null) {
      return this.spu.minPrice;
    }
    return 0;
  }

  private getOriginalPrice(): number {
    if (this.selectedSku !== null) {
      return this.selectedSku.originalPrice;
    }
    return 0;
  }

  private getCondition(): string {
    if (this.selectedSku !== null) {
      return this.selectedSku.condition;
    }
    return '';
  }

  private getSelectedSpecText(): string {
    if (this.selectedSku === null || this.selectedSku.specValues.length === 0) {
      return '';
    }
    let specText: string = '';
    for (let i = 0; i < this.selectedSku.specValues.length; i++) {
      if (i > 0) {
        specText += ' / ';
      }
      specText += this.selectedSku.specValues[i].specValue;
    }
    return specText;
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(ThemeManager.COLOR_PRIMARY)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeManager.BG_PRIMARY)
      } else if (this.spu === null) {
        Column() {
          EmptyState({ message: '商品不存在', actionText: '返回首页', onAction: () => RouterManager.back() })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(ThemeManager.BG_PRIMARY)
      } else {
        Column() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor(['#666666'])
              .onClick(() => RouterManager.back())
              .scale({ x: 1, y: 1 })
              .animation({ duration: 100, curve: Curve.EaseOut })

            Row() {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(16)
                .fontColor(['#999999'])
                .margin({ left: 10, right: 6 })
              TextInput({ placeholder: '搜索商品', text: this.searchKeyword })
                .type(InputType.Normal)
                .fontSize(14)
                .fontColor('#333333')
                .placeholderColor('#BBBBBB')
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .height(36)
                .onChange((value: string) => {
                  this.searchKeyword = value;
                })
            }
            .layoutWeight(1)
            .height(36)
            .borderRadius(18)
            .backgroundColor('#F5F5F5')
            .margin({ left: 12, right: 12 })
            .alignItems(VerticalAlign.Center)

            SymbolGlyph($r('sys.symbol.share'))
              .fontSize(24)
              .fontColor(['#666666'])
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .margin({ top: AppConstants.STATUS_BAR_HEIGHT })

          Scroll() {
            Column({ space: AppConstants.SPACING_LG }) {
              Swiper() {
                ForEach(this.spu.images, (img: string) => {
                  Image(img !== '' ? img : $r('app.media.startIcon'))
                    .width('100%')
                    .aspectRatio(1)
                    .objectFit(ImageFit.Cover)
                })
              }
              .index(this.currentImageIndex)
              .indicator(true)
              .loop(true)
              .width('100%')
              .height(360)
              .backgroundColor(ThemeManager.BG_PRIMARY)

              Column({ space: AppConstants.SPACING_SM }) {
                Row({ space: 4 }) {
                  Text('¥')
                    .fontSize(AppConstants.FONT_MD)
                    .fontColor(ThemeManager.COLOR_PRICE)
                  Text(this.getCurrentPrice().toString())
                    .fontSize(32)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ThemeManager.COLOR_PRICE)
                  if (this.getOriginalPrice() > this.getCurrentPrice()) {
                    Text(`¥${this.getOriginalPrice()}`)
                      .fontSize(AppConstants.FONT_SM)
                      .fontColor(ThemeManager.TEXT_HINT)
                      .decoration({ type: TextDecorationType.LineThrough })
                  }
                  if (this.skus.length > 1) {
                    Text('多规格可选')
                      .fontSize(AppConstants.FONT_XS)
                      .fontColor(ThemeManager.COLOR_PRIMARY)
                      .backgroundColor('rgba(92,184,160,0.08)')
                      .borderRadius(AppConstants.RADIUS_SM)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .margin({ left: 8 })
                  }
                }
                .alignItems(VerticalAlign.Bottom)

                if (this.selectedSku !== null && this.selectedSku.carbonReduction > 0) {
                  Row({ space: 4 }) {
                    Image($r('app.media.startIcon'))
                      .width(14)
                      .height(14)
                      .fillColor(ThemeManager.COLOR_PRIMARY)
                    Text(`碳减排 ${this.selectedSku.carbonReduction}kg · 碳积分 +${this.selectedSku.carbonCredits}`)
                      .fontSize(AppConstants.FONT_XS)
                      .fontColor(ThemeManager.COLOR_PRIMARY)
                  }
                }

                Text(this.spu.title)
                  .fontSize(AppConstants.FONT_XXL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                  .width('100%')
                  .maxLines(3)

                Row({ space: AppConstants.SPACING_LG }) {
                  if (this.getCondition() !== '') {
                    TagBadge({ text: this.getCondition() })
                  }
                  TagBadge({ text: this.spu.categoryName })
                  if (this.spu.brand !== '') {
                    TagBadge({ text: this.spu.brand })
                  }
                }
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
              .alignItems(HorizontalAlign.Start)

              if (this.skus.length > 1) {
                Row() {
                  Text('已选规格')
                    .fontSize(AppConstants.FONT_MD)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                  if (this.selectedSku !== null && this.selectedSku.specValues.length > 0) {
                    Text(this.getSelectedSpecText())
                      .fontSize(AppConstants.FONT_MD)
                      .fontColor(ThemeManager.TEXT_PRIMARY)
                      .layoutWeight(1)
                      .margin({ left: 8 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  } else {
                    Text('请选择')
                      .fontSize(AppConstants.FONT_MD)
                      .fontColor(ThemeManager.TEXT_HINT)
                      .layoutWeight(1)
                      .margin({ left: 8 })
                  }
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(16)
                    .fontColor([ThemeManager.TEXT_HINT])
                }
                .width('100%')
                .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 12, bottom: 12 })
                .backgroundColor(Color.White)
                .borderRadius(AppConstants.RADIUS_MD)
                .margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
                .onClick(() => {
                  this.showSpecSelector = true;
                })
              }

              if (this.selectedSku !== null) {
                Row() {
                  Text('库存')
                    .fontSize(AppConstants.FONT_MD)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                  Text(`${this.selectedSku.availableStock}件`)
                    .fontSize(AppConstants.FONT_MD)
                    .fontColor(ThemeManager.TEXT_PRIMARY)
                    .margin({ left: 8 })
                }
                .width('100%')
                .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
              }

              Divider().color(ThemeManager.DIVIDER).margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

              Row({ space: AppConstants.SPACING_MD }) {
                Image(this.spu.sellerAvatar !== '' ? this.spu.sellerAvatar : $r('sys.symbol.person_crop_circle_fill'))
                  .width(44)
                  .height(44)
                  .borderRadius(22)
                  .objectFit(ImageFit.Cover)

                Column({ space: 2 }) {
                  Text(this.spu.sellerName)
                    .fontSize(AppConstants.FONT_LG)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(ThemeManager.TEXT_PRIMARY)
                  Text(`信用良好 · ${this.spu.location}`)
                    .fontSize(AppConstants.FONT_XS)
                    .fontColor(ThemeManager.TEXT_HINT)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Image($r('sys.symbol.chevron_right'))
                  .width(16)
                  .height(16)
                  .fillColor(ThemeManager.TEXT_HINT)
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

              Divider().color(ThemeManager.DIVIDER).margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

              Column({ space: AppConstants.SPACING_SM }) {
                Text('商品描述')
                  .fontSize(AppConstants.FONT_LG)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                Text(this.spu.description)
                  .fontSize(AppConstants.FONT_MD)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
                  .lineHeight(22)
                  .width('100%')
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
              .alignItems(HorizontalAlign.Start)

              if (this.attributes.length > 0) {
                Divider().color(ThemeManager.DIVIDER).margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

                Column() {
                  AttributeList({ attributes: this.attributes })
                }
                .width('100%')
                .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
              }

              Divider().color(ThemeManager.DIVIDER).margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

              Row({ space: AppConstants.SPACING_SM }) {
                Image($r('app.media.startIcon'))
                  .width(16)
                  .height(16)
                  .fillColor(ThemeManager.TEXT_HINT)
                Text(`${this.spu.location} · ${this.spu.distance}`)
                  .fontSize(AppConstants.FONT_SM)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
                Blank()
                Text(`浏览 ${this.spu.viewCount} · 收藏 ${this.likeCount}`)
                  .fontSize(AppConstants.FONT_XS)
                  .fontColor(ThemeManager.TEXT_HINT)
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

              Blank().height(80)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)

          Row() {
            Column({ space: 2 }) {
              SymbolGlyph(this.isFavorited ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
                .fontSize(24)
                .fontColor([this.isFavorited ? '#FAAD14' : '#999999'])
                .scale({ x: this.favScale, y: this.favScale })
                .animation({ duration: 200, curve: Curve.EaseInOut })
                .onClick(async () => {
                  const result = await productRepository.toggleFavorite(this.spuId);
                  if (result !== null) {
                    this.isFavorited = result.isFavorited;
                    this.favCount = result.favoriteCount;
                  } else {
                    this.isFavorited = !this.isFavorited;
                    if (this.isFavorited) {
                      this.favCount += 1;
                    } else {
                      this.favCount = Math.max(0, this.favCount - 1);
                    }
                  }
                  this.favScale = 1.3;
                  setTimeout(() => { this.favScale = 1; }, 200);
                })
              Text(`${this.favCount}`)
                .fontSize(10)
                .fontColor('#666666')
            }
            .width(56)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column({ space: 2 }) {
              SymbolGlyph(this.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                .fontSize(24)
                .fontColor([this.isLiked ? '#FF4D4F' : '#999999'])
                .scale({ x: this.likeScale, y: this.likeScale })
                .animation({ duration: 200, curve: Curve.EaseInOut })
                .onClick(() => {
                  this.handleLike();
                })
              Text(`${this.likeCount}`)
                .fontSize(10)
                .fontColor('#666666')
            }
            .width(56)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Button('联系卖家')
              .fontSize(14)
              .fontColor(ThemeManager.COLOR_PRIMARY)
              .backgroundColor('rgba(92,184,160,0.1)')
              .border({ width: 1, color: ThemeManager.COLOR_PRIMARY })
              .borderRadius(22)
              .height(44)
              .layoutWeight(1)
              .type(ButtonType.Normal)
              .onClick(() => {
                if (this.spu !== null) {
                  const convId = messageRepository.findOrCreateConversation(
                    this.spu.sellerId, this.spu.sellerName,
                    this.spu.id, this.spu.title
                  );
                  RouterManager.toChat(convId, this.spu.sellerName, this.spu.sellerId);
                }
              })

            Button('立即购买')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor(ThemeManager.COLOR_PRIMARY)
              .borderRadius(22)
              .height(44)
              .layoutWeight(1)
              .type(ButtonType.Normal)
              .onClick(() => {
                if (this.skus.length > 1 && this.selectedSku === null) {
                  this.showSpecSelector = true;
                  return;
                }
                promptAction.showToast({ message: '已加入待发货订单' });
              })
          }
          .width('100%')
          .height(68)
          .padding({ left: 12, right: 16, bottom: 4 })
          .alignItems(VerticalAlign.Center)
          .backgroundColor(Color.White)
        }
        .width('100%')
        .height('100%')
      }

      if (this.showSpecSelector && this.spu !== null) {
        Blank()
          .layoutWeight(1)
          .backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => {
            this.showSpecSelector = false;
          })

        SpecSelector({
          specTree: this.specTree,
          skus: this.skus,
          selectedSpecNameIds: $selectedSpecNameIds,
          selectedSpecValueIds: $selectedSpecValueIds,
          selectedSku: $selectedSku,
          isVisible: this.showSpecSelector,
          onClose: () => {
            this.showSpecSelector = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }
}

@Component
struct TagBadge {
  @Prop text: string;

  build() {
    Text(this.text)
      .fontSize(AppConstants.FONT_XS)
      .fontColor(ThemeManager.COLOR_PRIMARY)
      .backgroundColor('rgba(92,184,160,0.08)')
      .borderRadius(AppConstants.RADIUS_SM)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
  }
}
