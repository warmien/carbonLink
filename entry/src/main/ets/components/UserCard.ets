import { User } from '../models/User';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

@Component
export struct UserCard {
  @Prop user: User;
  @State isPressed: boolean = false;
  onCardClick?: () => void;

  build() {
    Row({ space: AppConstants.SPACING_MD }) {
      Stack() {
        Image(this.user.avatar !== '' ? this.user.avatar : $r('sys.symbol.person_crop_circle_fill'))
          .width(56)
          .height(56)
          .borderRadius(28)
          .objectFit(ImageFit.Cover)
      }

      Column({ space: 4 }) {
        Row({ space: 6 }) {
          Text(this.user.nickname)
            .fontSize(AppConstants.FONT_LG)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.TEXT_PRIMARY)
            .maxLines(1)

          Text(`信用：${this.user.creditLevel}`)
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .backgroundColor('#E8F8F0')
            .borderRadius(AppConstants.RADIUS_SM)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        }

        Row({ space: AppConstants.SPACING_LG }) {
          Text(`发布 ${this.user.productCount}`)
            .fontSize(AppConstants.FONT_SM)
            .fontColor(ThemeManager.TEXT_SECONDARY)
          Text(`售出 ${this.user.soldCount}`)
            .fontSize(AppConstants.FONT_SM)
            .fontColor(ThemeManager.TEXT_SECONDARY)
          Text(`粉丝 ${this.user.followerCount}`)
            .fontSize(AppConstants.FONT_SM)
            .fontColor(ThemeManager.TEXT_SECONDARY)
        }

        Text(this.user.bio)
          .fontSize(AppConstants.FONT_SM)
          .fontColor(ThemeManager.TEXT_HINT)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('sys.symbol.chevron_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeManager.TEXT_HINT)
    }
    .width('100%')
    .padding(AppConstants.SPACING_LG)
    .backgroundColor(ThemeManager.BG_CARD)
    .borderRadius(AppConstants.RADIUS_LG)
    .scale({ x: this.isPressed ? 0.98 : 1, y: this.isPressed ? 0.98 : 1 })
    .animation({ duration: 150, curve: Curve.EaseOut })
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
