import { SPU, SPUStatus } from '../models/SPU';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';

@Component
export struct ProductCard {
  @Prop product: SPU;
  @Prop skuCount: number = 1;
  @State isPressed: boolean = false;
  onCardClick?: () => void;

  private getDisplayImage(): string | Resource {
    if (this.product.images && this.product.images.length > 0) {
      for (let i = 0; i < this.product.images.length; i++) {
        const url: string = this.product.images[i];
        if (url.length > 0 && !url.endsWith('.svg')) {
          return url;
        }
      }

    }
    return $r('app.media.startIcon');
  }

  build() {
    Column() {
      Stack() {
        Image(this.getDisplayImage())
          .width('100%')
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: AppConstants.RADIUS_MD, topRight: AppConstants.RADIUS_MD })

        if (this.product.status === SPUStatus.SOLD_OUT) {
          Text('已售出')
            .fontSize(AppConstants.FONT_SM)
            .fontColor(Color.White)
            .backgroundColor('rgba(0,0,0,0.5)')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(AppConstants.RADIUS_SM)
            .position({ right: 8, bottom: 8 })
        }
        if (this.skuCount > 1) {
          Text('多规格')
            .fontSize(AppConstants.FONT_XS)
            .fontColor(Color.White)
            .backgroundColor(ThemeManager.COLOR_PRIMARY)
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
          Text(this.product.minPrice.toString())
            .fontSize(AppConstants.FONT_XL)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.COLOR_PRICE)
          if (this.skuCount > 1) {
            Text('起')
              .fontSize(AppConstants.FONT_XS)
              .fontColor(ThemeManager.COLOR_PRICE)
          }
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
        }
        .width('100%')
      }
      .width('100%')
      .padding(AppConstants.SPACING_SM)
    }
    .width('100%')
    .backgroundColor(ThemeManager.BG_CARD)
    .borderRadius(AppConstants.RADIUS_MD)
    .scale({ x: this.isPressed ? 0.95 : 1, y: this.isPressed ? 0.95 : 1 })
    .animation({ duration: 100, curve: Curve.EaseOut })
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
