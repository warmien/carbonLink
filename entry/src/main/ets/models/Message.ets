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
