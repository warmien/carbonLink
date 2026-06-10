import { Product } from '../models/Product';
import { User } from '../models/User';
import { Recommendation } from '../models/Recommendation';
import { productRepository } from '../repository/ProductRepository';
import { messageRepository } from '../repository/MessageRepository';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { EmptyState } from '../components/EmptyState';
import { RecommendSection } from '../components/RecommendSection';
import { RecommendationEngine } from '../engine/RecommendationEngine';
import { BehaviorCollector } from '../services/BehaviorCollector';
import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ProductDetailPage {
  @State product: Product | null = null;
  @State seller: User | null = null;
  @State similarRecommendations: Recommendation[] = [];
  @State isFavorited: boolean = false;
  @State currentImageIndex: number = 0;
  @State favScale: number = 1;
  private productId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['productId']) {
      this.productId = params['productId'] as string;
      const p = productRepository.getProductById(this.productId);
      this.product = p !== undefined ? p : null;
      if (this.product) {
        this.isFavorited = this.product.isFavorited;
        this.similarRecommendations = RecommendationEngine.getSimilarRecommendations(this.productId, 'user_1', 6);
        BehaviorCollector.recordView('user_1', this.productId, this.product.category, this.product.price);
      }
    }
  }

  build() {
    if (this.product === null) {
      Column() {
        EmptyState({ message: '商品不存在', actionText: '返回首页', onAction: () => RouterManager.back() })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeManager.BG_PRIMARY)
    } else {
      Column() {
        Row() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor(ThemeManager.TEXT_PRIMARY)
            .onClick(() => RouterManager.back())
          Blank()
          Image(this.isFavorited ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
            .width(24)
            .height(24)
            .fillColor(this.isFavorited ? ThemeManager.COLOR_PRICE : ThemeManager.TEXT_PRIMARY)
            .scale({ x: this.favScale, y: this.favScale })
            .animation({ duration: 200, curve: Curve.EaseInOut })
            .onClick(() => {
              this.isFavorited = productRepository.toggleFavorite(this.productId);
              this.favScale = 1.3;
              setTimeout(() => { this.favScale = 1; }, 200);
            })
          Image($r('sys.symbol.share'))
            .width(24)
            .height(24)
            .fillColor(ThemeManager.TEXT_PRIMARY)
            .margin({ left: 16 })
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })

        Scroll() {
          Column({ space: AppConstants.SPACING_LG }) {
            Swiper() {
              ForEach(this.product.images, (img: string) => {
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
                Text(this.product.price.toString())
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeManager.COLOR_PRICE)
                if (this.product.originalPrice > this.product.price) {
                  Text(`¥${this.product.originalPrice}`)
                    .fontSize(AppConstants.FONT_SM)
                    .fontColor(ThemeManager.TEXT_HINT)
                    .decoration({ type: TextDecorationType.LineThrough })
                }
              }
              .alignItems(VerticalAlign.Bottom)

              Text(this.product.title)
                .fontSize(AppConstants.FONT_XXL)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeManager.TEXT_PRIMARY)
                .width('100%')
                .maxLines(3)

              Row({ space: AppConstants.SPACING_LG }) {
                TagBadge({ text: this.product.condition })
                TagBadge({ text: this.product.category })
                if (this.product.brand !== '') {
                  TagBadge({ text: this.product.brand })
                }
              }
            }
            .width('100%')
            .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
            .alignItems(HorizontalAlign.Start)

            Divider().color(ThemeManager.DIVIDER).margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

            Row({ space: AppConstants.SPACING_MD }) {
              Image(this.product.sellerAvatar !== '' ? this.product.sellerAvatar : $r('sys.symbol.person_crop_circle_fill'))
                .width(44)
                .height(44)
                .borderRadius(22)
                .objectFit(ImageFit.Cover)

              Column({ space: 2 }) {
                Text(this.product.sellerName)
                  .fontSize(AppConstants.FONT_LG)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                Text(`信用良好 · ${this.product.location}`)
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
              Text(this.product.description)
                .fontSize(AppConstants.FONT_MD)
                .fontColor(ThemeManager.TEXT_SECONDARY)
                .lineHeight(22)
                .width('100%')
            }
            .width('100%')
            .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
            .alignItems(HorizontalAlign.Start)

            Divider().color(ThemeManager.DIVIDER).margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

            Row({ space: AppConstants.SPACING_SM }) {
              Image($r('app.media.startIcon'))
                .width(16)
                .height(16)
                .fillColor(ThemeManager.TEXT_HINT)
              Text(`${this.product.location} · ${this.product.distance}`)
                .fontSize(AppConstants.FONT_SM)
                .fontColor(ThemeManager.TEXT_SECONDARY)
              Blank()
              Text(`浏览 ${this.product.viewCount} · 收藏 ${this.product.favoriteCount}`)
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.TEXT_HINT)
            }
            .width('100%')
            .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })

            if (this.similarRecommendations.length > 0) {
              RecommendSection({ title: '猜你喜欢', recommendations: this.similarRecommendations, isHorizontal: true })
                .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 16 })
            }

            Blank().height(80)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        Row({ space: AppConstants.SPACING_SM }) {
          Button('联系卖家')
            .fontSize(AppConstants.FONT_LG)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .backgroundColor('rgba(0,185,107,0.1)')
            .border({ width: 1, color: ThemeManager.COLOR_PRIMARY })
            .borderRadius(20)
            .height(44)
            .layoutWeight(1)
            .animation({ duration: 200 })
            .onClick(() => {
              if (this.product !== null) {
                const convId = messageRepository.findOrCreateConversation(
                  this.product.sellerId, this.product.sellerName,
                  this.product.id, this.product.title
                );
                RouterManager.toChat(convId, this.product.sellerName, this.product.sellerId);
              }
            })

          Button('立即购买')
            .fontSize(AppConstants.FONT_LG)
            .fontColor(Color.White)
            .backgroundColor(ThemeManager.COLOR_PRIMARY)
            .borderRadius(20)
            .height(44)
            .layoutWeight(1)
            .animation({ duration: 200 })
            .onClick(() => {
              promptAction.showToast({ message: '已加入待发货订单' });
            })
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })
        .backgroundColor(ThemeManager.BG_CARD)
      }
      .width('100%')
      .height('100%')
    }
  }
}

@Component
struct TagBadge {
  @Prop text: string;

  build() {
    Text(this.text)
      .fontSize(AppConstants.FONT_XS)
      .fontColor(ThemeManager.COLOR_PRIMARY)
      .backgroundColor('rgba(0,185,107,0.08)')
      .borderRadius(AppConstants.RADIUS_SM)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
  }
}
