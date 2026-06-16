import { Conversation } from '../../models/Message';
import { ImageDisplayUtil } from '../../components/ImagePickerPanel';
import { ThemeManager } from '../../theme/ThemeManager';
import { AppConstants } from '../../constants/AppConstants';
import { RouterManager } from '../../router/RouterManager';

@Component
export struct ConversationItem {
  @Prop conversation: Conversation = new Conversation();
  @State itemScale: number = 1;

  build() {
    Row() {
      Image(ImageDisplayUtil.getDisplaySrc(this.conversation.targetUserAvatar))
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .align(Alignment.Center)

      Column() {
        Row() {
          Text(this.conversation.targetUserName)
            .fontSize(AppConstants.FONT_MD)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (this.conversation.unreadCount > 0) {
            Text(this.conversation.unreadCount > 99 ? '99+' : `${this.conversation.unreadCount}`)
              .fontSize(AppConstants.FONT_XS)
              .fontColor(Color.White)
              .backgroundColor('#FF4D4F')
              .borderRadius(10)
              .padding({ left: 5, right: 5, top: 1, bottom: 1 })
              .constraintSize({ minWidth: 20 })
              .textAlign(TextAlign.Center)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.conversation.productTitle.length > 0) {
          Text(`📦 ${this.conversation.productTitle}`)
            .fontSize(AppConstants.FONT_SM)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }

        Text(this.conversation.lastMessage.length > 0 ? this.conversation.lastMessage : '暂无消息')
          .fontSize(AppConstants.FONT_SM)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .onClick(() => {
      this.itemScale = 0.95;
      setTimeout(() => { this.itemScale = 1; }, 100);
      RouterManager.toChat(
        this.conversation.id,
        this.conversation.targetUserName,
        this.conversation.targetUserId,
        this.conversation.productTitle,
        this.conversation.productImage,
        this.conversation.targetUserAvatar,
        this.conversation.productId
      );
    })
    .scale({ x: this.itemScale, y: this.itemScale })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .gesture(
      LongPressGesture()
        .onAction(() => {
        })
    )
  }
}