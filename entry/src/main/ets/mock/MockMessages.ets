import { Conversation, Message, MessageType } from '../models/Message';

export class MockMessages {
  private static conversations: Conversation[] = [];
  private static messagesMap: Map<string, Message[]> = new Map();
  private static initialized: boolean = false;

  private static init(): void {
    if (MockMessages.initialized) return;

    const c1 = new Conversation();
    c1.id = 'conv001'; c1.targetUserId = 'u001'; c1.targetUserName = '小明同学';
    c1.targetUserAvatar = ''; c1.lastMessage = '好的，明天下午可以面交';
    c1.lastMessageTime = Date.now() - 1800000; c1.unreadCount = 2;
    c1.productTitle = 'iPhone 15 Pro'; c1.productImage = '/product_placeholder.png';
    MockMessages.conversations.push(c1);

    const c2 = new Conversation();
    c2.id = 'conv002'; c2.targetUserId = 'u006'; c2.targetUserName = '数码玩家老张';
    c2.targetUserAvatar = ''; c2.lastMessage = '还在的，包装配件都齐全';
    c2.lastMessageTime = Date.now() - 86400000; c2.unreadCount = 0;
    c2.productTitle = 'Sony WH-1000XM5'; c2.productImage = '/product_placeholder.png';
    MockMessages.conversations.push(c2);

    const c3 = new Conversation();
    c3.id = 'conv003'; c3.targetUserId = 'u009'; c3.targetUserName = '摄影爱好者';
    c3.targetUserAvatar = ''; c3.lastMessage = '快门数不到2000，可以过来测试';
    c3.lastMessageTime = Date.now() - 86400000 * 2; c3.unreadCount = 1;
    c3.productTitle = '富士 X-T5 微单'; c3.productImage = '/product_placeholder.png';
    MockMessages.conversations.push(c3);

    const c4 = new Conversation();
    c4.id = 'conv004'; c4.targetUserId = 'u004'; c4.targetUserName = '广州潮人';
    c4.targetUserAvatar = ''; c4.lastMessage = '已发货，注意查收~';
    c4.lastMessageTime = Date.now() - 86400000 * 3; c4.unreadCount = 0;
    c4.productTitle = 'Nike Air Force 1'; c4.productImage = '/product_placeholder.png';
    MockMessages.conversations.push(c4);

    MockMessages.messagesMap.set('conv001', [
      MockMessages.makeMsg('m001', 'conv001', 'u000', '碳易用户', '你好，请问iPhone还在吗？', MessageType.TEXT, Date.now() - 7200000, true),
      MockMessages.makeMsg('m002', 'conv001', 'u001', '小明同学', '在的，可以小刀', MessageType.TEXT, Date.now() - 5400000, true),
      MockMessages.makeMsg('m003', 'conv001', 'u000', '碳易用户', '6500可以吗？我自取', MessageType.TEXT, Date.now() - 3600000, true),
      MockMessages.makeMsg('m004', 'conv001', 'u001', '小明同学', '好的，明天下午可以面交', MessageType.TEXT, Date.now() - 1800000, false),
    ]);
    MockMessages.messagesMap.set('conv002', [
      MockMessages.makeMsg('m005', 'conv002', 'u000', '碳易用户', '耳机还在吗？成色怎么样？', MessageType.TEXT, Date.now() - 172800000, true),
      MockMessages.makeMsg('m006', 'conv002', 'u006', '数码玩家老张', '还在的，包装配件都齐全', MessageType.TEXT, Date.now() - 86400000, true),
    ]);
    MockMessages.messagesMap.set('conv003', [
      MockMessages.makeMsg('m007', 'conv003', 'u000', '碳易用户', '请问XT5快门数多少？', MessageType.TEXT, Date.now() - 259200000, true),
      MockMessages.makeMsg('m008', 'conv003', 'u009', '摄影爱好者', '快门数不到2000，可以过来测试', MessageType.TEXT, Date.now() - 172800000, false),
    ]);
    MockMessages.messagesMap.set('conv004', [
      MockMessages.makeMsg('m009', 'conv004', 'u000', '碳易用户', '鞋子什么时候发货？', MessageType.TEXT, Date.now() - 345600000, true),
      MockMessages.makeMsg('m010', 'conv004', 'u004', '广州潮人', '已发货，注意查收~', MessageType.TEXT, Date.now() - 259200000, true),
    ]);

    MockMessages.initialized = true;
  }

  static getConversations(): Conversation[] {
    MockMessages.init();
    return JSON.parse(JSON.stringify(MockMessages.conversations)) as Conversation[];
  }

  static getMessages(conversationId: string): Message[] {
    MockMessages.init();
    const msgs = MockMessages.messagesMap.get(conversationId);
    return msgs ? (JSON.parse(JSON.stringify(msgs)) as Message[]) : [];
  }

  static addMessage(message: Message): void {
    MockMessages.init();
    const convId = message.conversationId;
    let msgs = MockMessages.messagesMap.get(convId);
    if (!msgs) {
      msgs = [];
      MockMessages.messagesMap.set(convId, msgs);
    }
    msgs.push(message);
    const conv = MockMessages.conversations.find(c => c.id === convId);
    if (conv) {
      conv.lastMessage = message.content;
      conv.lastMessageTime = message.timestamp;
    }
  }

  static markConversationAsRead(conversationId: string): void {
    MockMessages.init();
    const conv = MockMessages.conversations.find(c => c.id === conversationId);
    if (conv) {
      conv.unreadCount = 0;
    }
  }

  static findOrCreateConversation(targetUserId: string, targetUserName: string,
    productId: string, productTitle: string): string {
    MockMessages.init();
    const existing = MockMessages.conversations.find(c => c.targetUserId === targetUserId);
    if (existing) return existing.id;
    const newId = 'conv' + (MockMessages.conversations.length + 1).toString().padStart(3, '0');
    const conv = new Conversation();
    conv.id = newId;
    conv.targetUserId = targetUserId;
    conv.targetUserName = targetUserName;
    conv.targetUserAvatar = '';
    conv.lastMessage = '';
    conv.lastMessageTime = Date.now();
    conv.unreadCount = 0;
    conv.productTitle = productTitle;
    conv.productImage = '/product_placeholder.png';
    MockMessages.conversations.push(conv);
    MockMessages.messagesMap.set(newId, []);
    return newId;
  }

  private static makeMsg(id: string, convId: string, senderId: string, senderName: string,
                          content: string, msgType: MessageType, timestamp: number, isRead: boolean): Message {
    const m = new Message();
    m.id = id;
    m.conversationId = convId;
    m.senderId = senderId;
    m.senderName = senderName;
    m.senderAvatar = '';
    m.content = content;
    m.msgType = msgType;
    m.timestamp = timestamp;
    m.isRead = isRead;
    return m;
  }
}
