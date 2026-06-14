import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

@Component
export struct EmptyState {
  @Prop icon: ResourceStr = $r('sys.symbol.xmark_circle_fill');
  @Prop message: string = '暂无数据';
  @Prop actionText: string = '';
  onAction?: () => void;

  build() {
    Column({ space: AppConstants.SPACING_MD }) {
      Image(this.icon)
        .width(64)
        .height(64)
        .fillColor(ThemeManager.TEXT_HINT)
        .opacity(0.5)

      Text(this.message)
        .fontSize(AppConstants.FONT_MD)
        .fontColor(ThemeManager.TEXT_HINT)

      if (this.actionText !== '') {
        Button(this.actionText)
          .fontSize(AppConstants.FONT_MD)
          .backgroundColor(ThemeManager.COLOR_PRIMARY)
          .borderRadius(20)
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
