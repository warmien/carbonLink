import { SPU } from '../models/SPU';
import { Recommendation } from '../models/Recommendation';
import { productRepository } from '../repository/ProductRepository';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';
import { RouterManager } from '../router/RouterManager';

@Component
export struct RecommendProductCard {
  @Prop recommendation: Recommendation = new Recommendation();
  @Prop spu: SPU | null = null;
  @Prop isViewed: boolean = false;
  onDislike?: (productId: string) => void;

  build() {
    Column() {
      Stack() {
        Image(this.spu !== null && this.spu.images.length > 0 && this.spu.images[0] !== '' ? this.spu.images[0] : $r('app.media.startIcon'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 8, topRight: 8 })

        if (this.isViewed) {
          Text('已浏览')
            .fontSize(9)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(0,0,0,0.5)')
            .borderRadius(4)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .position({ x: 4, y: 4 })
        }

        Text('×')
          .fontSize(12)
          .fontColor('#999999')
          .position({ x: '85%', y: 4 })
          .onClick(() => {
            if (this.onDislike) {
              this.onDislike(this.recommendation.productId);
            }
          })
      }
      .width('100%')
      .height(120)

      Column() {
        Text(this.spu !== null ? this.spu.title : '')
          .fontSize(12)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .maxLines(1)
          .margin({ top: 6 })

        Row() {
          Text('¥' + (this.spu !== null ? this.spu.minPrice.toString() : '0'))
            .fontSize(13)
            .fontColor(ThemeManager.COLOR_PRICE)
            .fontWeight(FontWeight.Medium)

          Blank()

          Text(this.recommendation.reason)
            .fontSize(9)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .backgroundColor('#E8F8F0')
            .borderRadius(8)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .maxLines(1)
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .padding({ left: 6, right: 6, bottom: 8 })
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor(ThemeManager.BG_CARD)
    .onClick(() => {
      RouterManager.toProductDetail(this.recommendation.productId);
    })
  }
}