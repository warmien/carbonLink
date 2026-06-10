import { Message, Conversation, MessageType } from '../models/Message';
import { messageRepository } from '../repository/MessageRepository';
import { userRepository } from '../repository/UserRepository';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { DateUtils } from '../utils/DateUtils';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ChatPage {
  @State messages: Message[] = [];
  @State inputText: string = '';
  @State conversationId: string = '';
  @State targetUserName: string = '';
  @State targetUserId: string = '';
  @State sendScale: number = 1;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params !== undefined && params !== null) {
      this.conversationId = params['conversationId'] !== undefined ? params['conversationId'] as string : '';
      this.targetUserName = params['targetUserName'] !== undefined ? params['targetUserName'] as string : '';
      this.targetUserId = params['targetUserId'] !== undefined ? params['targetUserId'] as string : '';
    }
    if (this.conversationId !== '') {
      this.messages = messageRepository.getMessages(this.conversationId);
      messageRepository.markConversationAsRead(this.conversationId);
    }
  }

  sendMessage(): void {
    if (this.inputText.trim() === '') return;

    const user = userRepository.getCurrentUser();
    const newMsg = new Message();
    newMsg.id = 'm' + Date.now();
    newMsg.conversationId = this.conversationId;
    newMsg.senderId = user.id;
    newMsg.senderName = user.nickname;
    newMsg.senderAvatar = '';
    newMsg.content = this.inputText.trim();
    newMsg.msgType = MessageType.TEXT;
    newMsg.timestamp = Date.now();
    newMsg.isRead = true;

    messageRepository.sendMessage(newMsg);
    this.messages = [...this.messages, newMsg];
    this.inputText = '';
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }

  build() {
    Column() {
      // 顶部导航
      Row({ space: AppConstants.SPACING_SM }) {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor(ThemeManager.TEXT_PRIMARY)
          .onClick(() => RouterManager.back())

        Image($r('sys.symbol.person_crop_circle_fill'))
          .width(36)
          .height(36)
          .borderRadius(18)

        Column({ space: 1 }) {
          Text(this.targetUserName)
            .fontSize(AppConstants.FONT_LG)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.TEXT_PRIMARY)
          Text('在线')
            .fontSize(AppConstants.FONT_XS)
            .fontColor(ThemeManager.COLOR_PRIMARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r('sys.symbol.ellipsis_circle'))
          .width(24)
          .height(24)
          .fillColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })
      .backgroundColor(ThemeManager.BG_CARD)

      // 聊天消息列表
      Scroll(this.scroller) {
        List({ space: AppConstants.SPACING_MD }) {
          ForEach(this.messages, (msg: Message) => {
            ListItem() {
              Row() {
                if (msg.senderId === 'u000') {
                  Blank()
                }
                Column({ space: 2 }) {
                  if (msg.msgType === MessageType.TEXT) {
                    Text(msg.content)
                      .fontSize(AppConstants.FONT_MD)
                      .fontColor(msg.senderId === 'u000' ? Color.White : ThemeManager.TEXT_PRIMARY)
                      .backgroundColor(msg.senderId === 'u000' ? ThemeManager.COLOR_PRIMARY : ThemeManager.BG_PRIMARY)
                      .borderRadius(msg.senderId === 'u000'
                        ? { topLeft: 16, topRight: 16, bottomLeft: 16 }
                        : { topLeft: 16, topRight: 16, bottomRight: 16 })
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .constraintSize({ maxWidth: '75%' })
                      .textAlign(msg.senderId === 'u000' ? TextAlign.End : TextAlign.Start)
                  } else if (msg.msgType === MessageType.IMAGE) {
                    Image(msg.imageUrl)
                      .width(160)
                      .height(160)
                      .borderRadius(12)
                      .objectFit(ImageFit.Cover)
                  } else if (msg.msgType === MessageType.PRODUCT_CARD && msg.productCard) {
                    Row({ space: AppConstants.SPACING_SM }) {
                      Image(msg.productCard.image !== '' ? msg.productCard.image : $r('app.media.startIcon'))
                        .width(60)
                        .height(60)
                        .borderRadius(AppConstants.RADIUS_SM)
                        .objectFit(ImageFit.Cover)
                      Column({ space: 2 }) {
                        Text(msg.productCard.title)
                          .fontSize(AppConstants.FONT_SM)
                          .fontColor(ThemeManager.TEXT_PRIMARY)
                          .maxLines(1)
                        Text('¥' + msg.productCard.price.toString())
                          .fontSize(AppConstants.FONT_MD)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(ThemeManager.COLOR_PRICE)
                      }
                      .alignItems(HorizontalAlign.Start)
                    }
                    .backgroundColor(ThemeManager.BG_CARD)
                    .borderRadius(12)
                    .padding(AppConstants.SPACING_SM)
                    .border({ width: 1, color: ThemeManager.DIVIDER })
                  }
                  Text(DateUtils.formatTimeAgo(msg.timestamp))
                    .fontSize(10)
                    .fontColor(ThemeManager.TEXT_HINT)
                }
                .alignItems(msg.senderId === 'u000' ? HorizontalAlign.End : HorizontalAlign.Start)

                if (msg.senderId !== 'u000') {
                  Blank()
                }
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
            }
          })
        }
        .width('100%')
        .padding({ top: AppConstants.SPACING_SM })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(ThemeManager.BG_PRIMARY)
      .onClick(() => {
        // 点击空白区域隐藏键盘等
      })

      // 输入区域
      Row({ space: AppConstants.SPACING_SM }) {
        Image($r('sys.symbol.camera_fill'))
          .width(24)
          .height(24)
          .fillColor(ThemeManager.TEXT_HINT)

        TextInput({ text: this.inputText, placeholder: '输入消息...' })
          .fontSize(AppConstants.FONT_MD)
          .backgroundColor(ThemeManager.BG_PRIMARY)
          .borderRadius(20)
          .height(40)
          .padding({ left: 12, right: 12 })
          .layoutWeight(1)
          .onChange((text: string) => { this.inputText = text; })
          .onSubmit(() => { this.sendMessage(); })

        Button('发送')
          .fontSize(AppConstants.FONT_SM)
          .backgroundColor(ThemeManager.COLOR_PRIMARY)
          .borderRadius(16)
          .height(34)
          .padding({ left: 14, right: 14 })
          .enabled(this.inputText.trim() !== '')
          .scale({ x: this.sendScale, y: this.sendScale })
          .animation({ duration: 150, curve: Curve.EaseOut })
          .onClick(() => {
            this.sendScale = 0.9;
            setTimeout(() => { this.sendScale = 1; }, 100);
            this.sendMessage();
          })
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })
      .backgroundColor(ThemeManager.BG_CARD)
    }
    .width('100%')
    .height('100%')
  }
}
