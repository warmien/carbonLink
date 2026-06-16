import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

export class ImageDisplayUtil {
  static getDisplaySrc(url: string): string | Resource {
    if (url.length === 0) {
      return $r('app.media.startIcon');
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('file://') || url.startsWith('content://') || url.startsWith('internal://')) {
      return url;
    }
    if (url.endsWith('.svg')) {
      return $r('app.media.startIcon');
    }
    return $r('app.media.startIcon');
  }
}

@Component
export struct ImagePickerPanel {
  @Link images: string[];
  @Prop maxCount: number = 9;
  @State isAddPressed: boolean = false;
  onImageAdd?: () => void;
  onImageDelete?: (index: number) => void;

  build() {
    Column() {
      Scroll() {
        Row({ space: AppConstants.SPACING_SM }) {
          ForEach(this.images, (img: string, index: number) => {
            Stack() {
              Image(ImageDisplayUtil.getDisplaySrc(img))
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
            Column() {
              Image($r('sys.symbol.plus_circle_fill'))
                .width(28)
                .height(28)
                .fillColor(ThemeManager.COLOR_PRIMARY)
              Text('添加图片')
                .fontSize(10)
                .fontColor(ThemeManager.TEXT_HINT)
                .margin({ top: 2 })
            }
            .width(84)
            .height(84)
            .borderRadius(AppConstants.RADIUS_MD)
            .border({ width: 1.5, color: ThemeManager.COLOR_PRIMARY, style: BorderStyle.Dashed })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .scale({ x: this.isAddPressed ? 0.95 : 1, y: this.isAddPressed ? 0.95 : 1 })
            .animation({ duration: 100, curve: Curve.EaseOut })
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
