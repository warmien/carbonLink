export class Message {
  id: string = '';
  conversationId: string = '';
  senderId: string = '';
  senderName: string = '';
  senderAvatar: string = '';
  content: string = '';
  msgType: MessageType = MessageType.TEXT;
  productCard: MessageProductCard | null = null;
  imageUrl: string = '';
  timestamp: number = Date.now();
  isRead: boolean = false;
}

export class Conversation {
  id: string = '';
  targetUserId: string = '';
  targetUserName: string = '';
  targetUserAvatar: string = '';
  lastMessage: string = '';
  lastMessageTime: number = Date.now();
  unreadCount: number = 0;
  productId: string = '';
  productTitle: string = '';
  productImage: string = '';
}

export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  PRODUCT_CARD = 'product_card'
}

export class MessageProductCard {
  productId: string = '';
  title: string = '';
  price: number = 0;
  image: string = '';
}

export enum WsMessageType {
  PING = 'ping',
  PONG = 'pong',
  NEW_MESSAGE = 'new_message',
  CONVERSATION_UPDATE = 'conversation_update',
  MARK_READ = 'mark_read',
  ERROR = 'error'
}

export enum WsConnectionState {
  DISCONNECTED = 'disconnected',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  RECONNECTING = 'reconnecting'
}

export class WsMessage {
  type: WsMessageType = WsMessageType.PING;
  data: Record<string, string | number | object> | null = null;
  code: number = 0;
  message: string = '';
}

export class PagedMessages {
  messages: Message[] = [];
  total: number = 0;
  page: number = 1;
  size: number = 20;
}

export class ConversationItem {
  id: string = '';
  targetUserId: string = '';
  targetUserName: string = '';
  targetUserAvatar: string = '';
  productId: string = '';
  productTitle: string = '';
  productImage: string = '';
  lastMessage: string = '';
  lastMessageTime: number = 0;
  unreadCount: number = 0;
}
