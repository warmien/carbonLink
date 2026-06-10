import { PricingResult } from '../models/PricingResult';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

@Component
export struct AIPricingResultCard {
  @Prop result: PricingResult;
  onAdopt?: (price: number) => void;

  build() {
    Column({ space: AppConstants.SPACING_SM }) {
      Row() {
        Row({ space: 6 }) {
          Image($r('sys.symbol.checkmark_circle_fill'))
            .width(16)
            .height(16)
            .fillColor(ThemeManager.COLOR_PRIMARY)
          Text('AI估价结果')
            .fontSize(AppConstants.FONT_MD)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.COLOR_PRIMARY)
        }
        Blank()
        Text('¥' + this.result.suggestedPrice.toString())
          .fontSize(AppConstants.FONT_XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.COLOR_PRICE)
      }
      .width('100%')

      Row({ space: AppConstants.SPACING_MD }) {
        Column() {
          Text('最低价')
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.TEXT_HINT)
          Text('¥' + this.result.minPrice.toString())
            .fontSize(AppConstants.FONT_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .padding(AppConstants.SPACING_SM)
        .backgroundColor(ThemeManager.BG_PRIMARY)
        .borderRadius(AppConstants.RADIUS_SM)

        Column() {
          Text('建议价')
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.TEXT_HINT)
          Text('¥' + this.result.suggestedPrice.toString())
            .fontSize(AppConstants.FONT_MD)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.COLOR_PRIMARY)
        }
        .layoutWeight(1)
        .padding(AppConstants.SPACING_SM)
        .backgroundColor('#E8F8F0')
        .borderRadius(AppConstants.RADIUS_SM)

        Column() {
          Text('最高价')
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.TEXT_HINT)
          Text('¥' + this.result.maxPrice.toString())
            .fontSize(AppConstants.FONT_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .padding(AppConstants.SPACING_SM)
        .backgroundColor(ThemeManager.BG_PRIMARY)
        .borderRadius(AppConstants.RADIUS_SM)
      }
      .width('100%')

      if (this.result.reasoning) {
        Text(this.result.reasoning)
          .fontSize(AppConstants.FONT_SM)
          .fontColor(ThemeManager.TEXT_SECONDARY)
          .width('100%')
          .maxLines(3)
          .padding({ top: AppConstants.SPACING_XS })
      }

      Button('采纳建议价格')
        .fontSize(AppConstants.FONT_SM)
        .fontColor(Color.White)
        .backgroundColor(ThemeManager.COLOR_PRIMARY)
        .borderRadius(20)
        .height(36)
        .width('100%')
        .onClick(() => {
          if (this.onAdopt) this.onAdopt(this.result.suggestedPrice);
        })
    }
    .width('100%')
    .padding(AppConstants.SPACING_MD)
    .backgroundColor('#F0FBF5')
    .borderRadius(AppConstants.RADIUS_LG)
    .border({ width: 1, color: '#D0F0E0' })
  }
}
