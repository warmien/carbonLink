import { Product, ProductStatus } from '../models/Product';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';

@Component
export struct ProductCard {
  @Prop product: Product;
  @State isPressed: boolean = false;
  onCardClick?: () => void;

  build() {
    Column() {
      Stack() {
        Image(this.product.images && this.product.images.length > 0 && this.product.images[0] !== '' ? this.product.images[0] : $r('app.media.startIcon'))
          .width('100%')
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: AppConstants.RADIUS_MD, topRight: AppConstants.RADIUS_MD })

        if (this.product.status === ProductStatus.SOLD) {
          Text('已售出')
            .fontSize(AppConstants.FONT_SM)
            .fontColor(Color.White)
            .backgroundColor('rgba(0,0,0,0.5)')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(AppConstants.RADIUS_SM)
            .position({ right: 8, bottom: 8 })
        }
        if (this.product.originalPrice > this.product.price) {
          Text(`${Math.round((1 - this.product.price / this.product.originalPrice) * 100)}% off`)
            .fontSize(AppConstants.FONT_XS)
            .fontColor(Color.White)
            .backgroundColor(ThemeManager.COLOR_PRICE)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(AppConstants.RADIUS_SM)
            .position({ left: 8, top: 8 })
        }
      }
      .width('100%')

      Column() {
        Text(this.product.title)
          .fontSize(AppConstants.FONT_MD)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row({ space: 4 }) {
          Text('¥')
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.COLOR_PRICE)
          Text(this.product.price.toString())
            .fontSize(AppConstants.FONT_XL)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.COLOR_PRICE)
          if (this.product.originalPrice > 0 && this.product.originalPrice > this.product.price) {
            Text(`¥${this.product.originalPrice}`)
              .fontSize(AppConstants.FONT_XS)
              .fontColor(ThemeManager.TEXT_HINT)
              .decoration({ type: TextDecorationType.LineThrough })
          }
          Blank()
          Text(this.product.distance)
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.TEXT_HINT)
        }
        .width('100%')
        .margin({ top: 4, bottom: 2 })

        Row({ space: 4 }) {
          Image($r('sys.symbol.person_fill'))
            .width(12)
            .height(12)
            .fillColor(ThemeManager.TEXT_HINT)
          Text(this.product.sellerName)
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.TEXT_HINT)
            .maxLines(1)
          Blank()
          Text(`${this.product.viewCount}浏览`)
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.TEXT_HINT)
        }
        .width('100%')
      }
      .width('100%')
      .padding(AppConstants.SPACING_SM)
    }
    .width('100%')
    .backgroundColor(ThemeManager.BG_CARD)
    .borderRadius(AppConstants.RADIUS_MD)
    .scale({ x: this.isPressed ? 0.96 : 1, y: this.isPressed ? 0.96 : 1 })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
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
