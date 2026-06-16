import { Message, Conversation, MessageType, WsConnectionState } from '../models/Message';
import { messageRepository } from '../repository/MessageRepository';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { DateUtils } from '../utils/DateUtils';
import { WsChatService } from '../services/WsChatService';
import { ImageDisplayUtil } from '../components/ImagePickerPanel';
import { router, window } from '@kit.ArkUI';

@Entry
@Component
struct ChatPage {
  @State messages: Message[] = [];
  @State inputText: string = '';
  @State conversationId: string = '';
  @State targetUserName: string = '';
  @State targetUserId: string = '';
  @State targetUserAvatar: string = '';
  @State productTitle: string = '';
  @State productImage: string = '';
  @State productId: string = '';
  @State sendScale: number = 1;

  @State currentPage: number = 1;
  @State hasMore: boolean = true;
  @State isLoadingMore: boolean = false;
  @State isSending: boolean = false;
  @State currentUserId: string = '';
  @StorageProp('wsConnectionState') wsState: WsConnectionState = WsConnectionState.DISCONNECTED;
  @StorageProp('wsNewMessagePayload') @Watch('onNewMessage') wsNewMsgPayload: string = '';
  @StorageProp('currentUser') @Watch('onCurrentUserChanged') currentUserJson: string = '';

  private scroller: Scroller = new Scroller();

  onCurrentUserChanged(): void {
    const jsonStr: string = this.currentUserJson.length > 0 ? this.currentUserJson : (AppStorage.get<string>('currentUser') || '');
    if (jsonStr.length > 0) {
      try {
        const userObj: Record<string, string | number> = JSON.parse(jsonStr) as Record<string, string | number>;
        const uid: string = userObj['id'] as string;
        if (uid.length > 0 && uid !== this.currentUserId) {
          this.currentUserId = uid;
        }
      } catch (err) {
        console.error('[ChatPage] 解析currentUser失败');
      }
    }
  }

  async aboutToAppear(): Promise<void> {
    const params: Record<string, string | number | object> | undefined = router.getParams() as Record<string, string | number | object> | undefined;
    if (params !== undefined && params !== null) {
      this.conversationId = params['conversationId'] !== undefined ? params['conversationId'] as string : '';
      this.targetUserName = params['targetUserName'] !== undefined ? params['targetUserName'] as string : '';
      this.targetUserId = params['targetUserId'] !== undefined ? params['targetUserId'] as string : '';
      this.targetUserAvatar = params['targetUserAvatar'] !== undefined ? params['targetUserAvatar'] as string : '';
      this.productTitle = params['productTitle'] !== undefined ? params['productTitle'] as string : '';
      this.productImage = params['productImage'] !== undefined ? params['productImage'] as string : '';
      this.productId = params['productId'] !== undefined ? params['productId'] as string : '';
    }

    this.onCurrentUserChanged();

    if (this.targetUserAvatar.length === 0 && this.conversationId.length > 0) {
      await this.refreshConversationInfo();
    }

    if (this.conversationId !== '') {
      await this.loadMessages();
      await messageRepository.markAsRead(this.conversationId);
    }

    this.setupKeyboardListener();
  }

  async refreshConversationInfo(): Promise<void> {
    try {
      const convs: Conversation[] = await messageRepository.getConversations();
      for (let i = 0; i < convs.length; i++) {
        if (convs[i].id === this.conversationId) {
          if (convs[i].targetUserName.length > 0) {
            this.targetUserName = convs[i].targetUserName;
          }
          if (convs[i].targetUserAvatar.length > 0) {
            this.targetUserAvatar = convs[i].targetUserAvatar;
          }
          break;
        }
      }
    } catch (err) {
      console.error('[ChatPage] 刷新会话信息失败');
    }
  }

  onNewMessage(): void {
    if (this.wsNewMsgPayload.length === 0) return;

    try {
      const payload: Record<string, string | number | object> = JSON.parse(this.wsNewMsgPayload) as Record<string, string | number | object>;
      const dataRaw: string | number | object = payload['data'];
      if (typeof dataRaw !== 'object' || dataRaw === null) return;
      const data: Record<string, string | number | object> = dataRaw as Record<string, string | number | object>;
      const convId: string = data['conversationId'] as string;
      if (convId !== this.conversationId) return;

      const msg: Message = new Message();
      msg.id = data['id'] as string;
      msg.conversationId = convId;
      msg.senderId = data['senderId'] as string;
      msg.senderName = data['senderName'] as string;
      msg.senderAvatar = typeof data['senderAvatar'] === 'string' ? data['senderAvatar'] as string : '';
      msg.content = typeof data['content'] === 'string' ? data['content'] as string : '';
      const msgTypeStr: string = typeof data['msgType'] === 'string' ? data['msgType'] as string : 'text';
      msg.msgType = msgTypeStr === 'image' ? MessageType.IMAGE : (msgTypeStr === 'product_card' ? MessageType.PRODUCT_CARD : MessageType.TEXT);
      msg.timestamp = typeof data['timestamp'] === 'number' ? data['timestamp'] as number : Date.now();
      msg.isRead = typeof data['isRead'] === 'number' ? (data['isRead'] as number) === 1 : false;

      this.messages = [...this.messages, msg];
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 50);

      if (msg.senderId !== this.currentUserId) {
        messageRepository.markAsRead(this.conversationId);
        WsChatService.sendMarkRead(this.conversationId);
      }
    } catch (err) {
      console.error('[ChatPage] 解析新消息失败:', (err as Error).message);
    }
  }

  async loadMessages(): Promise<void> {
    const result = await messageRepository.getMessages(this.conversationId, 1, AppConstants.CHAT_PAGE_SIZE);
    this.messages = result.messages;
    this.currentPage = result.page;
    this.hasMore = result.messages.length < result.total;
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }

  async loadMoreMessages(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore) return;
    this.isLoadingMore = true;
    const nextPage: number = this.currentPage + 1;
    const result = await messageRepository.getMessages(this.conversationId, nextPage, AppConstants.CHAT_PAGE_SIZE);
    const olderMessages: Message[] = result.messages;
    if (olderMessages.length > 0) {
      this.messages = [...olderMessages, ...this.messages];
      this.currentPage = nextPage;
      this.hasMore = this.messages.length < result.total;
    } else {
      this.hasMore = false;
    }
    this.isLoadingMore = false;
  }

  async sendMessage(): Promise<void> {
    if (this.inputText.trim() === '' || this.isSending) return;
    this.isSending = true;

    const content: string = this.inputText.trim();
    this.inputText = '';

    const myId: string = this.currentUserId;
    const optimisticMsg: Message = new Message();
    optimisticMsg.id = 'temp_' + Date.now();
    optimisticMsg.conversationId = this.conversationId;
    optimisticMsg.senderId = myId;
    optimisticMsg.content = content;
    optimisticMsg.msgType = MessageType.TEXT;
    optimisticMsg.timestamp = Date.now();
    optimisticMsg.isRead = false;
    this.messages = [...this.messages, optimisticMsg];

    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 50);

    const result: Message | null = await messageRepository.sendMessage(this.conversationId, content);
    if (result !== null) {
      if (result.senderId.length === 0) {
        result.senderId = myId;
      }
      const idx: number = this.findMessageIndex(optimisticMsg.id);
      if (idx >= 0) {
        const updated: Message[] = [...this.messages];
        updated[idx] = result;
        this.messages = updated;
      }
    }

    this.isSending = false;
  }

  findMessageIndex(msgId: string): number {
    for (let i = 0; i < this.messages.length; i++) {
      if (this.messages[i].id === msgId) {
        return i;
      }
    }
    return -1;
  }

  setupKeyboardListener(): void {
    try {
      window.getLastWindow(getContext(this)).then((win: window.Window) => {
        win.on('keyboardHeightChange', (height: number) => {
          if (height > 0) {
            setTimeout(() => {
              this.scroller.scrollEdge(Edge.Bottom);
            }, 250);
          }
        });
      }).catch((err: Error) => {
        console.error('[ChatPage] 获取窗口失败:', err.message);
      });
    } catch (err) {
      console.error('[ChatPage] 键盘监听失败:', (err as Error).message);
    }
  }


  isMyMessage(msg: Message): boolean {
    return msg.senderId === this.currentUserId;
  }

  build() {
    Column() {
      Column() {
        Row({ space: AppConstants.SPACING_SM }) {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor(ThemeManager.TEXT_PRIMARY)
            .onClick(() => RouterManager.back())

          Image(ImageDisplayUtil.getDisplaySrc(this.targetUserAvatar))
            .width(36)
            .height(36)
            .borderRadius(18)

          Column({ space: 1 }) {
            Text(this.targetUserName)
              .fontSize(AppConstants.FONT_LG)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            if (this.wsState === WsConnectionState.CONNECTED) {
              Text('在线')
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.COLOR_PRIMARY)
            } else if (this.wsState === WsConnectionState.RECONNECTING) {
              Text('重连中...')
                .fontSize(AppConstants.FONT_XS)
                .fontColor('#FF9800')
            } else {
              Text('离线')
                .fontSize(AppConstants.FONT_XS)
                .fontColor(ThemeManager.TEXT_HINT)
            }
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
      }
      .padding({ top: AppConstants.STATUS_BAR_HEIGHT })

      if (this.wsState === WsConnectionState.RECONNECTING) {
        Row() {
          Text('连接中断，正在重连...')
            .fontSize(AppConstants.FONT_XS)
            .fontColor('#FF9800')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .backgroundColor('#FFF3E0')
      }

      if (this.productTitle.length > 0) {
        Row({ space: 8 }) {
          if (this.productImage.length > 0) {
            Image(ImageDisplayUtil.getDisplaySrc(this.productImage))
              .width(32)
              .height(32)
              .borderRadius(6)
              .objectFit(ImageFit.Cover)
          }
          Text(this.productTitle)
            .fontSize(AppConstants.FONT_SM)
            .fontColor(ThemeManager.TEXT_SECONDARY)
            .maxLines(1)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: 8, bottom: 8 })
        .backgroundColor('#F5F7FA')
      }

      Scroll(this.scroller) {
        List({ space: AppConstants.SPACING_MD }) {
          if (this.hasMore) {
            ListItem() {
              Row() {
                if (this.isLoadingMore) {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .color(ThemeManager.TEXT_HINT)
                } else {
                  Text('加载更多')
                    .fontSize(AppConstants.FONT_XS)
                    .fontColor(ThemeManager.TEXT_HINT)
                    .onClick(() => {
                      this.loadMoreMessages();
                    })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ top: 8, bottom: 8 })
            }
          }

          ForEach(this.messages, (msg: Message) => {
            ListItem() {
              Row() {
                if (this.isMyMessage(msg)) {
                  Blank()
                }
                Column({ space: 2 }) {
                  if (msg.msgType === MessageType.TEXT) {
                    Text(msg.content)
                      .fontSize(AppConstants.FONT_MD)
                      .fontColor(this.isMyMessage(msg) ? Color.White : ThemeManager.TEXT_PRIMARY)
                      .backgroundColor(this.isMyMessage(msg) ? ThemeManager.COLOR_PRIMARY : ThemeManager.BG_CARD)
                      .borderRadius(this.isMyMessage(msg)
                        ? { topLeft: 16, topRight: 16, bottomLeft: 16 }
                        : { topLeft: 16, topRight: 16, bottomRight: 16 })
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .constraintSize({ maxWidth: '75%' })
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
                .alignItems(this.isMyMessage(msg) ? HorizontalAlign.End : HorizontalAlign.Start)

                if (!this.isMyMessage(msg)) {
                  Blank()
                }
              }
              .width('100%')
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
            }
            .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
          })
        }
        .width('100%')
        .padding({ top: AppConstants.SPACING_SM })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(ThemeManager.BG_PRIMARY)

      Column() {
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
            .enabled(this.inputText.trim() !== '' && !this.isSending)
            .scale({ x: this.sendScale, y: this.sendScale })
            .animation({ duration: 100, curve: Curve.EaseOut })
            .onClick(() => {
              this.sendScale = 0.95;
              setTimeout(() => { this.sendScale = 1; }, 100);
              this.sendMessage();
            })
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: AppConstants.SPACING_SM })
        .backgroundColor(ThemeManager.BG_CARD)
      }
      .padding({ bottom: AppConstants.HOME_INDICATOR_HEIGHT })
    }
    .width('100%')
    .height('100%')

    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }
}
