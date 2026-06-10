import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

@Component
export struct AIRecognitionIndicator {
  @Prop status: string = 'idle';
  @Prop errorMessage: string = '';

  build() {
    if (this.status === 'loading') {
      Row({ space: 8 }) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color(ThemeManager.COLOR_PRIMARY)
        Text('AI识别中...')
          .fontSize(AppConstants.FONT_SM)
          .fontColor(ThemeManager.COLOR_PRIMARY)
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#E8F8F0')
      .borderRadius(20)
      .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
    } else if (this.status === 'success') {
      Row({ space: 6 }) {
        Image($r('sys.symbol.checkmark_circle_fill'))
          .width(16)
          .height(16)
          .fillColor(ThemeManager.COLOR_PRIMARY)
        Text('AI识别完成')
          .fontSize(AppConstants.FONT_SM)
          .fontColor(ThemeManager.COLOR_PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#E8F8F0')
      .borderRadius(20)
      .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
    } else if (this.status === 'error') {
      Row({ space: 6 }) {
        Image($r('sys.symbol.xmark_circle_fill'))
          .width(16)
          .height(16)
          .fillColor(ThemeManager.COLOR_PRICE)
        Text(this.errorMessage)
          .fontSize(AppConstants.FONT_SM)
          .fontColor(ThemeManager.COLOR_PRICE)
          .constraintSize({ maxWidth: '80%' })
          .maxLines(1)
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFF0F0')
      .borderRadius(20)
      .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
    }
  }
}
