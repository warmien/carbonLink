import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

class BannerItem {
  title: string = '';
  gradientColors: Array<[string, number]> = [];
  link: string = '';
  constructor(title: string, gradientColors: Array<[string, number]>, link: string) {
    this.title = title;
    this.gradientColors = gradientColors;
    this.link = link;
  }
}

@Component
export struct BannerView {
  @State currentIndex: number = 0;
  private banners: BannerItem[] = [
    new BannerItem('绿色循环，碳享未来', [['#2D8B75', 0], ['#5CB8A0', 1]], ''),
    new BannerItem('发布闲置，赚取碳积分', [['#4A9A84', 0], ['#8ED4C2', 1]], ''),
    new BannerItem('二手也能很高品质', [['#3A7D6A', 0], ['#6BC4A8', 1]], ''),
  ];
  private controller: SwiperController = new SwiperController();

  build() {
    Stack() {
      Swiper(this.controller) {
        ForEach(this.banners, (banner: BannerItem, index: number) => {
          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .linearGradient({
                direction: GradientDirection.BottomRight,
                colors: banner.gradientColors
              })

            Column() {
              Text(banner.title)
                .fontSize(AppConstants.FONT_XL)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .textShadow({ radius: 2, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 1 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.End)
            .alignItems(HorizontalAlign.Start)
            .padding(AppConstants.SPACING_LG)
          }
        })
      }
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .autoPlay(true)
      .interval(3000)
      .indicator(false)
      .loop(true)
      .width('100%')
      .height(160)
      .borderRadius(AppConstants.RADIUS_LG)
      .duration(400)
      .curve(Curve.EaseInOut)

      Row({ space: 6 }) {
        ForEach(this.banners, (_: BannerItem, index: number) => {
          Column()
            .width(index === this.currentIndex ? 18 : 6)
            .height(6)
            .borderRadius(3)
            .backgroundColor(index === this.currentIndex ? Color.White : 'rgba(255,255,255,0.5)')
            .animation({ duration: 300, curve: Curve.EaseInOut })
        })
      }
      .position({ bottom: 12, right: AppConstants.SPACING_LG })
    }
    .width('100%')
    .height(160)
    .margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
  }
}
