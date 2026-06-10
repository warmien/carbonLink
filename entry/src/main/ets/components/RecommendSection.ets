import { Recommendation } from '../models/Recommendation';
import { RecommendProductCard } from './RecommendProductCard';
import { ThemeManager } from '../theme/ThemeManager';

@Component
export struct RecommendSection {
  @Prop title: string = '为你推荐';
  @Prop recommendations: Recommendation[] = [];
  @Prop isHorizontal: boolean = false;
  onDislike?: (productId: string) => void;

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.recommendations.length === 0) {
        Text('暂无推荐，去逛逛吧')
          .fontSize(13)
          .fontColor(ThemeManager.TEXT_HINT)
          .padding(20)
      } else if (this.isHorizontal) {
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.recommendations, (rec: Recommendation) => {
              RecommendProductCard({
                recommendation: rec
              })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      } else {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignContent: FlexAlign.Start }) {
          ForEach(this.recommendations, (rec: Recommendation) => {
            Column() {
              RecommendProductCard({
                recommendation: rec
              })
            }
            .margin(5)
          })
        }
      }
    }
    .width('100%')
  }
}