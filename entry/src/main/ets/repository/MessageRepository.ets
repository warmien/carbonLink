import { Conversation, ConversationItem, Message, PagedMessages, MessageType } from '../models/Message';
import { HttpService, ApiResponse } from '../services/HttpService';
import { AppConstants } from '../constants/AppConstants';

export class MessageRepository {
  async getConversations(): Promise<Conversation[]> {
    const response: ApiResponse = await HttpService.GET('/chat/conversations');
    if (response.code !== 0 || response.data === null) {
      return [];
    }

    const data: Record<string, string | number | object> = response.data;
    const convsRaw: string | number | object = data['conversations'];
    const totalUnread: number = typeof data['totalUnread'] === 'number' ? data['totalUnread'] as number : 0;
    AppStorage.setOrCreate('totalUnread', totalUnread);

    if (typeof convsRaw !== 'object' || convsRaw === null) {
      return [];
    }
    const convsArr: Record<string, string | number | object>[] = convsRaw as Record<string, string | number | object>[];
    const result: Conversation[] = [];
    for (let i = 0; i < convsArr.length; i++) {
      const item: Record<string, string | number | object> = convsArr[i];
      const conv: Conversation = new Conversation();
      conv.id = item['id'] as string;
      conv.targetUserId = item['targetUserId'] as string;
      conv.targetUserName = item['targetUserName'] as string;
      conv.targetUserAvatar = typeof item['targetUserAvatar'] === 'string' ? item['targetUserAvatar'] as string : '';
      conv.productId = typeof item['productId'] === 'string' ? item['productId'] as string : '';
      conv.productTitle = typeof item['productTitle'] === 'string' ? item['productTitle'] as string : '';
      conv.productImage = typeof item['productImage'] === 'string' ? item['productImage'] as string : '';
      conv.lastMessage = typeof item['lastMessage'] === 'string' ? item['lastMessage'] as string : '';
      conv.lastMessageTime = typeof item['lastMessageTime'] === 'number' ? item['lastMessageTime'] as number : 0;
      conv.unreadCount = typeof item['unreadCount'] === 'number' ? item['unreadCount'] as number : 0;
      result.push(conv);
    }
    return result;
  }

  async getMessages(conversationId: string, page: number = 1, size: number = AppConstants.CHAT_PAGE_SIZE): Promise<PagedMessages> {
    const response: ApiResponse = await HttpService.GET(`/chat/messages/${conversationId}?page=${page}&size=${size}`);
    if (response.code !== 0 || response.data === null) {
      const empty: PagedMessages = new PagedMessages();
      return empty;
    }

    const data: Record<string, string | number | object> = response.data;
    const msgsRaw: string | number | object = data['messages'];
    if (typeof msgsRaw !== 'object' || msgsRaw === null) {
      const empty: PagedMessages = new PagedMessages();
      return empty;
    }
    const msgsArr: Record<string, string | number | object>[] = msgsRaw as Record<string, string | number | object>[];
    const messages: Message[] = [];
    for (let i = 0; i < msgsArr.length; i++) {
      const item: Record<string, string | number | object> = msgsArr[i];
      const msg: Message = new Message();
      msg.id = item['id'] as string;
      msg.conversationId = item['conversationId'] as string;
      msg.senderId = item['senderId'] as string;
      msg.senderName = item['senderName'] as string;
      msg.senderAvatar = typeof item['senderAvatar'] === 'string' ? item['senderAvatar'] as string : '';
      msg.content = typeof item['content'] === 'string' ? item['content'] as string : '';
      const msgTypeStr: string = typeof item['msgType'] === 'string' ? item['msgType'] as string : 'text';
      msg.msgType = msgTypeStr === 'image' ? MessageType.IMAGE : (msgTypeStr === 'product_card' ? MessageType.PRODUCT_CARD : MessageType.TEXT);
      msg.imageUrl = typeof item['imageUrl'] === 'string' ? item['imageUrl'] as string : '';
      msg.timestamp = typeof item['timestamp'] === 'number' ? item['timestamp'] as number : 0;
      msg.isRead = typeof item['isRead'] === 'number' ? (item['isRead'] as number) === 1 : false;
      messages.push(msg);
    }

    const result: PagedMessages = new PagedMessages();
    result.messages = messages;
    result.total = typeof data['total'] === 'number' ? data['total'] as number : 0;
    result.page = typeof data['page'] === 'number' ? data['page'] as number : page;
    result.size = typeof data['size'] === 'number' ? data['size'] as number : size;
    return result;
  }

  async sendMessage(conversationId: string, content: string, msgType: string = 'text'): Promise<Message | null> {
    const reqBody: Record<string, string | number | object> = {};
    reqBody['conversationId'] = conversationId;
    reqBody['content'] = content;
    reqBody['msgType'] = msgType;
    const response: ApiResponse = await HttpService.POST('/chat/messages', reqBody);
    if (response.code !== 0 || response.data === null) {
      return null;
    }

    const data: Record<string, string | number | object> = response.data;
    const msg: Message = new Message();
    msg.id = data['id'] as string;
    msg.conversationId = conversationId;
    msg.senderId = typeof data['senderId'] === 'string' ? data['senderId'] as string : '';
    msg.content = content;
    msg.timestamp = typeof data['timestamp'] === 'number' ? data['timestamp'] as number : Date.now();
    msg.isRead = typeof data['isRead'] === 'number' ? (data['isRead'] as number) === 1 : false;
    return msg;
  }

  async markAsRead(conversationId: string): Promise<number> {
    const response: ApiResponse = await HttpService.PUT(`/chat/conversations/${conversationId}/read`);
    if (response.code !== 0 || response.data === null) {
      return 0;
    }
    const data: Record<string, string | number | object> = response.data;
    return typeof data['markedCount'] === 'number' ? data['markedCount'] as number : 0;
  }

  async findOrCreateConversation(sellerId: string, productId: string): Promise<Conversation | null> {
    const reqBody: Record<string, string | number | object> = {};
    reqBody['sellerId'] = sellerId;
    reqBody['productId'] = productId;
    const response: ApiResponse = await HttpService.POST('/chat/conversations', reqBody);
    if (response.code !== 0 || response.data === null) {
      return null;
    }

    const data: Record<string, string | number | object> = response.data;
    const conv: Conversation = new Conversation();
    conv.id = data['id'] as string;
    conv.targetUserId = data['targetUserId'] as string;
    conv.targetUserName = data['targetUserName'] as string;
    conv.targetUserAvatar = typeof data['targetUserAvatar'] === 'string' ? data['targetUserAvatar'] as string : '';
    conv.productId = typeof data['productId'] === 'string' ? data['productId'] as string : '';
    conv.productTitle = typeof data['productTitle'] === 'string' ? data['productTitle'] as string : '';
    conv.productImage = typeof data['productImage'] === 'string' ? data['productImage'] as string : '';
    conv.lastMessage = typeof data['lastMessage'] === 'string' ? data['lastMessage'] as string : '';
    conv.lastMessageTime = typeof data['lastMessageTime'] === 'number' ? data['lastMessageTime'] as number : 0;
    conv.unreadCount = typeof data['unreadCount'] === 'number' ? data['unreadCount'] as number : 0;
    return conv;
  }
}

export const messageRepository = new MessageRepository();
