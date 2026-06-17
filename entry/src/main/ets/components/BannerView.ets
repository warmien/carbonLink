import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { SPU } from '../models/SPU';
import { productRepository, SPUListResult } from '../repository/ProductRepository';
import { RouterManager } from '../router/RouterManager';

@Component
export struct BannerView {
  @State currentIndex: number = 0;
  @State bannerProducts: SPU[] = [];
  @State isLoading: boolean = true;
  private controller: SwiperController = new SwiperController();

  aboutToAppear(): void {
    this.loadBannerProducts();
  }

  private async loadBannerProducts(): Promise<void> {
    try {
      const result: SPUListResult = await productRepository.fetchProducts();
      const onSale: SPU[] = [];
      for (let i = 0; i < result.list.length; i++) {
        const spu: SPU = result.list[i];
        if (spu.status === 'on_sale' && spu.images.length > 0) {
          onSale.push(spu);
        }
      }
      this.bannerProducts = onSale.slice(0, 5);
    } catch (e) {
      this.bannerProducts = [];
    }
    this.isLoading = false;
  }

  private getDisplayImage(spu: SPU): string {
    for (let i = 0; i < spu.images.length; i++) {
      if (spu.images[i].length > 0 && !spu.images[i].endsWith('.svg')) {
        return spu.images[i];
      }
    }
    return '';
  }

  build() {
    Stack() {
      if (this.bannerProducts.length > 0) {
        Swiper(this.controller) {
          ForEach(this.bannerProducts, (spu: SPU, index: number) => {
            Stack() {
              Image(this.getDisplayImage(spu))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)

              Column() {
                Text(spu.title)
                  .fontSize(AppConstants.FONT_LG)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textShadow({ radius: 2, color: 'rgba(0,0,0,0.5)', offsetX: 0, offsetY: 1 })

                Row({ space: 4 }) {
                  Text('¥')
                    .fontSize(AppConstants.FONT_XS)
                    .fontColor('#FFE4B5')
                  Text(spu.minPrice.toString())
                    .fontSize(AppConstants.FONT_XL)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFE4B5')
                  Text(spu.sellerName)
                    .fontSize(AppConstants.FONT_XS)
                    .fontColor('rgba(255,255,255,0.8)')
                    .margin({ left: 8 })
                }
                .margin({ top: 4 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.End)
              .alignItems(HorizontalAlign.Start)
              .padding(AppConstants.SPACING_LG)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['rgba(0,0,0,0.5)', 0], ['rgba(0,0,0,0)', 0.6]]
              })
            }
            .onClick(() => {
              RouterManager.toProductDetail(spu.id);
            })
          }, (spu: SPU, index: number) => spu.id + '_' + index.toString())
        }
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .autoPlay(true)
        .interval(4000)
        .indicator(false)
        .loop(true)
        .width('100%')
        .height(160)
        .borderRadius(AppConstants.RADIUS_LG)
        .duration(400)
        .curve(Curve.EaseInOut)

        Row({ space: 6 }) {
          ForEach(this.bannerProducts, (_: SPU, index: number) => {
            Column()
              .width(index === this.currentIndex ? 18 : 6)
              .height(6)
              .borderRadius(3)
              .backgroundColor(index === this.currentIndex ? Color.White : 'rgba(255,255,255,0.5)')
              .animation({ duration: 300, curve: Curve.EaseInOut })
          }, (_: SPU, index: number) => 'dot_' + index.toString())
        }
        .position({ bottom: 12, right: AppConstants.SPACING_LG })
      } else {
        Column() {
          Text('发现好物')
            .fontSize(AppConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .linearGradient({
          direction: GradientDirection.RightBottom,
          colors: [['#2D8B75', 0], ['#5CB8A0', 1]]
        })
      }
    }
    .width('100%')
    .height(160)
    .margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
  }
}
