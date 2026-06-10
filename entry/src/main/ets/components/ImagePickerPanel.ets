import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

@Component
export struct ImagePickerPanel {
  @Link images: string[];
  @Prop maxCount: number = 9;
  @State isAddPressed: boolean = false;
  onImageAdd?: () => void;
  onImageDelete?: (index: number) => void;

  build() {
    Column() {
      Row() {
        Text('添加图片')
          .fontSize(AppConstants.FONT_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.TEXT_PRIMARY)
        Blank()
        Text(`${this.images.length}/${this.maxCount}`)
          .fontSize(AppConstants.FONT_SM)
          .fontColor(ThemeManager.TEXT_HINT)
      }
      .width('100%')
      .margin({ bottom: AppConstants.SPACING_SM })

      Scroll() {
        Row({ space: AppConstants.SPACING_SM }) {
          ForEach(this.images, (img: string, index: number) => {
            Stack() {
              Image(img.startsWith('file://') || img.startsWith('content://') || img.startsWith('internal://') ? img : $r('app.media.startIcon'))
                .width(80)
                .height(80)
                .borderRadius(AppConstants.RADIUS_MD)
                .objectFit(ImageFit.Cover)

              Stack() {
                Image($r('sys.symbol.xmark_circle_fill'))
                  .width(18)
                  .height(18)
                  .fillColor(Color.White)
              }
              .width(18)
              .height(18)
              .borderRadius(9)
              .backgroundColor('rgba(0,0,0,0.4)')
              .position({ right: -2, top: -2 })
              .onClick(() => {
                if (this.onImageDelete) {
                  this.onImageDelete(index);
                }
              })
            }
            .width(84)
            .height(84)
          })

          if (this.images.length < this.maxCount) {
            Column({ space: 4 }) {
              Text('+')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeManager.COLOR_PRIMARY)
              Text('添加图片')
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.TEXT_HINT)
            }
            .width(80)
            .height(80)
            .borderRadius(AppConstants.RADIUS_MD)
            .backgroundColor('#F5F5F5')
            .border({ width: 1, color: ThemeManager.DIVIDER, style: BorderStyle.Dashed })
            .justifyContent(FlexAlign.Center)
            .scale({ x: this.isAddPressed ? 0.95 : 1, y: this.isAddPressed ? 0.95 : 1 })
            .animation({ duration: 150, curve: Curve.EaseOut })
            .onClick(() => {
              if (this.onImageAdd) {
                this.onImageAdd();
              }
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.isAddPressed = true;
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.isAddPressed = false;
              }
            })
          }
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
