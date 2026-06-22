import db from '../businessDatabase';


export interface ConversationDTO {
  id: string;
  targetUserId: string;
  targetUserName: string;
  targetUserAvatar: string;
  productId: string;
  productTitle: string;
  productImage: string;
  lastMessage: string;
  lastMessageTime: number;
  unreadCount: number;
  createdAt: number;
}

export interface MessageDTO {
  id: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  senderAvatar: string;
  content: string;
  msgType: string;
  imageUrl: string;
  productCard: string;
  timestamp: number;
  isRead: number;
}

export interface SendMessageResult {
  id: string;
  timestamp: number;
  isRead: number;
}

export interface PagedMessagesResult {
  messages: MessageDTO[];
  total: number;
  page: number;
  size: number;
}

type WsPushCallback = (userId: string, type: string, data: Record<string, string | number | object>) => void;

let wsPushCallback: WsPushCallback | null = null;

export function setWsPushCallback(cb: WsPushCallback): void {
  wsPushCallback = cb;
}

function pushToUser(userId: string, type: string, data: Record<string, string | number | object>): void {
  if (wsPushCallback) {
    wsPushCallback(userId, type, data);
  }
}

function getConvForUser(row: Record<string, unknown>, userId: string): ConversationDTO {
  const isUser1: boolean = (row.user1_id as string) === userId;
  const targetUserId: string = isUser1 ? (row.user2_id as string) : (row.user1_id as string);
  const unreadCount: number = isUser1 ? ((row.unread_count_user1 as number) || 0) : ((row.unread_count_user2 as number) || 0);

  const targetUser = db.prepare('SELECT nickname, avatar FROM users WHERE id = ?').get(targetUserId) as Record<string, unknown> | undefined;
  const targetUserName: string = targetUser ? (targetUser.nickname as string) : (isUser1 ? (row.user2_name as string) : (row.user1_name as string));
  const targetUserAvatar: string = targetUser ? ((targetUser.avatar as string) || '') : (isUser1 ? ((row.user2_avatar as string) || '') : ((row.user1_avatar as string) || ''));

  return {
    id: row.id as string,
    targetUserId,
    targetUserName,
    targetUserAvatar,
    productId: (row.product_id as string) || '',
    productTitle: (row.product_title as string) || '',
    productImage: (row.product_image as string) || '',
    lastMessage: (row.last_message as string) || '',
    lastMessageTime: (row.last_message_time as number) || 0,
    unreadCount,
    createdAt: row.created_at as number,
  };
}

export class ChatService {
  // 会话创建：用户ID排序后按(user1_id, user2_id, product_id)去重
  // 同一对用户的不同商品 = 不同会话，因为买家可能分别咨询不同商品
  static findOrCreateConversation(buyerId: string, sellerId: string, productId: string): ConversationDTO {
    if (buyerId === sellerId) {
      throw new Error('CANNOT_CHAT_WITH_SELF');
    }

    const seller = db.prepare('SELECT id, nickname, avatar, status FROM users WHERE id = ?').get(sellerId) as Record<string, unknown> | undefined;
    if (!seller || seller.status === 'banned') {
      throw new Error('SELLER_UNAVAILABLE');
    }

    const product = db.prepare('SELECT id, title, images FROM spu WHERE id = ? AND status = ?').get(productId, 'on_sale') as Record<string, unknown> | undefined;
    if (!product) {
      throw new Error('PRODUCT_NOT_FOUND');
    }

    const productTitle = product.title as string;
    let productImage = '';
    try {
      const images = JSON.parse(product.images as string);
      if (Array.isArray(images) && images.length > 0) {
        productImage = images[0];
      }
    } catch (_e) {
      // ignore
    }

    const buyer = db.prepare('SELECT id, nickname, avatar FROM users WHERE id = ?').get(buyerId) as Record<string, unknown> | undefined;

    const [smallerId, largerId] = buyerId < sellerId ? [buyerId, sellerId] : [sellerId, buyerId];

    const existing = db.prepare(
      'SELECT * FROM conversations WHERE user1_id = ? AND user2_id = ? AND product_id = ?'
    ).get(smallerId, largerId, productId) as Record<string, unknown> | undefined;

    if (existing) {
      return getConvForUser(existing, buyerId);
    }

    const now = Date.now();
    const convId = `conv_${now}_${Math.random().toString(36).substring(2, 8)}`;

    const user1Id = smallerId;
    const user2Id = largerId;
    const user1Name: string = user1Id === buyerId ? (buyer?.nickname as string) : (seller.nickname as string);
    const user1Avatar: string = user1Id === buyerId ? ((buyer?.avatar as string) || '') : ((seller.avatar as string) || '');
    const user2Name: string = user2Id === sellerId ? (seller.nickname as string) : (buyer?.nickname as string);
    const user2Avatar: string = user2Id === sellerId ? ((seller.avatar as string) || '') : ((buyer?.avatar as string) || '');

    db.prepare(`
      INSERT INTO conversations (id, user1_id, user2_id, target_user_id, target_user_name, target_user_avatar,
        last_message, last_message_time, unread_count_user1, unread_count_user2,
        product_id, product_title, product_image, created_at, updated_at,
        user1_name, user1_avatar, user2_name, user2_avatar)
      VALUES (?, ?, ?, ?, ?, ?, '', 0, 0, 0, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      convId, user1Id, user2Id, user2Id, user2Name, user2Avatar,
      productId, productTitle, productImage, now, now,
      user1Name, user1Avatar, user2Name, user2Avatar
    );

    console.log(`[Chat] 会话已创建: ${convId}, 用户: ${user1Id} <-> ${user2Id}`);

    return {
      id: convId,
      targetUserId: sellerId,
      targetUserName: seller.nickname as string,
      targetUserAvatar: (seller.avatar as string) || '',
      productId,
      productTitle,
      productImage,
      lastMessage: '',
      lastMessageTime: 0,
      unreadCount: 0,
      createdAt: now,
    };
  }

  static getConversations(userId: string): { conversations: ConversationDTO[]; totalUnread: number } {
    const rows = db.prepare(`
      SELECT * FROM conversations
      WHERE user1_id = ? OR user2_id = ?
      ORDER BY last_message_time DESC
    `).all(userId, userId) as Record<string, unknown>[];

    let totalUnread = 0;
    const conversations: ConversationDTO[] = rows.map((row) => {
      const conv = getConvForUser(row, userId);
      totalUnread += conv.unreadCount;
      return conv;
    });

    return { conversations, totalUnread };
  }

  static getMessages(conversationId: string, userId: string, page: number = 1, size: number = 20): PagedMessagesResult {
    const conv = db.prepare(
      'SELECT * FROM conversations WHERE id = ? AND (user1_id = ? OR user2_id = ?)'
    ).get(conversationId, userId, userId) as Record<string, unknown> | undefined;

    if (!conv) {
      throw new Error('CONVERSATION_NOT_FOUND');
    }

    const totalRow = db.prepare(
      'SELECT COUNT(*) as cnt FROM messages WHERE conversation_id = ?'
    ).get(conversationId) as { cnt: number };

    const offset = (page - 1) * size;
    const rows = db.prepare(`
      SELECT * FROM messages
      WHERE conversation_id = ?
      ORDER BY timestamp ASC
      LIMIT ? OFFSET ?
    `).all(conversationId, size, offset) as Record<string, unknown>[];

    const messages: MessageDTO[] = rows.map((row) => ({
      id: row.id as string,
      conversationId: row.conversation_id as string,
      senderId: row.sender_id as string,
      senderName: row.sender_name as string,
      senderAvatar: (row.sender_avatar as string) || '',
      content: (row.content as string) || '',
      msgType: (row.msg_type as string) || 'text',
      imageUrl: (row.image_url as string) || '',
      productCard: (row.product_card as string) || '',
      timestamp: row.timestamp as number,
      isRead: row.is_read as number,
    }));

    return { messages, total: totalRow.cnt, page, size };
  }

  // 消息发送：事务写入DB + 更新会话 + 对方unread+1 + WebSocket推送new_message和conversation_update
  static sendMessage(conversationId: string, senderId: string, content: string, msgType: string = 'text'): SendMessageResult {
    const conv = db.prepare(
      'SELECT * FROM conversations WHERE id = ? AND (user1_id = ? OR user2_id = ?)'
    ).get(conversationId, senderId, senderId) as Record<string, unknown> | undefined;

    if (!conv) {
      throw new Error('CONVERSATION_NOT_FOUND');
    }

    const isUser1: boolean = (conv.user1_id as string) === senderId;
    const receiverId: string = isUser1 ? (conv.user2_id as string) : (conv.user1_id as string);

    const sender = db.prepare('SELECT id, nickname, avatar FROM users WHERE id = ?').get(senderId) as Record<string, unknown> | undefined;
    if (!sender) {
      throw new Error('USER_NOT_FOUND');
    }

    const now = Date.now();
    const msgId = `msg_${now}_${Math.random().toString(36).substring(2, 8)}`;

    const result = db.transaction(() => {
      db.prepare(`
        INSERT INTO messages (id, conversation_id, sender_id, sender_name, sender_avatar,
          content, msg_type, image_url, product_card, timestamp, is_read)
        VALUES (?, ?, ?, ?, ?, ?, ?, '', '', ?, 0)
      `).run(msgId, conversationId, senderId, sender.nickname as string, (sender.avatar as string) || '',
        content, msgType, now);

      db.prepare(`
        UPDATE conversations
        SET last_message = ?, last_message_time = ?, updated_at = ?
        WHERE id = ?
      `).run(content.substring(0, 100), now, now, conversationId);

      if (isUser1) {
        db.prepare(`
          UPDATE conversations SET unread_count_user2 = unread_count_user2 + 1, updated_at = ? WHERE id = ?
        `).run(now, conversationId);
      } else {
        db.prepare(`
          UPDATE conversations SET unread_count_user1 = unread_count_user1 + 1, updated_at = ? WHERE id = ?
        `).run(now, conversationId);
      }

      return { receiverId };
    })();

    console.log(`[Chat] 消息已发送: ${msgId}, 会话: ${conversationId}, 发送者: ${senderId}`);

    const messageDTO: MessageDTO = {
      id: msgId,
      conversationId,
      senderId,
      senderName: sender.nickname as string,
      senderAvatar: (sender.avatar as string) || '',
      content,
      msgType,
      imageUrl: '',
      productCard: '',
      timestamp: now,
      isRead: 0,
    };

    pushToUser(result.receiverId, 'new_message', {
      id: msgId,
      conversationId,
      senderId,
      senderName: sender.nickname as string,
      senderAvatar: (sender.avatar as string) || '',
      content,
      msgType,
      imageUrl: '',
      productCard: '',
      timestamp: now,
      isRead: 0,
    });

    const senderConv = getConvForUser(
      db.prepare('SELECT * FROM conversations WHERE id = ?').get(conversationId) as Record<string, unknown>,
      senderId
    );
    pushToUser(senderId, 'conversation_update', senderConv as unknown as Record<string, string | number | object>);

    const receiverConv = getConvForUser(
      db.prepare('SELECT * FROM conversations WHERE id = ?').get(conversationId) as Record<string, unknown>,
      result.receiverId
    );
    pushToUser(result.receiverId, 'conversation_update', receiverConv as unknown as Record<string, string | number | object>);

    return { id: msgId, senderId, timestamp: now, isRead: 0 };
  }

  static markAsRead(conversationId: string, userId: string): { markedCount: number } {
    const conv = db.prepare(
      'SELECT * FROM conversations WHERE id = ? AND (user1_id = ? OR user2_id = ?)'
    ).get(conversationId, userId, userId) as Record<string, unknown> | undefined;

    if (!conv) {
      throw new Error('CONVERSATION_NOT_FOUND');
    }

    const isUser1: boolean = (conv.user1_id as string) === userId;

    const result = db.transaction(() => {
      const updateResult = db.prepare(`
        UPDATE messages
        SET is_read = 1
        WHERE conversation_id = ? AND sender_id != ? AND is_read = 0
      `).run(conversationId, userId);

      if (isUser1) {
        db.prepare(`
          UPDATE conversations SET unread_count_user1 = 0, updated_at = ? WHERE id = ?
        `).run(Date.now(), conversationId);
      } else {
        db.prepare(`
          UPDATE conversations SET unread_count_user2 = 0, updated_at = ? WHERE id = ?
        `).run(Date.now(), conversationId);
      }

      return { markedCount: updateResult.changes };
    })();

    console.log(`[Chat] 已标记已读: 会话 ${conversationId}, 用户 ${userId}, ${result.markedCount}条消息`);

    const updatedConv = getConvForUser(
      db.prepare('SELECT * FROM conversations WHERE id = ?').get(conversationId) as Record<string, unknown>,
      userId
    );
    pushToUser(userId, 'conversation_update', updatedConv as unknown as Record<string, string | number | object>);

    return result;
  }

  static getUnreadCount(userId: string): number {
    const asUser1 = db.prepare(`
      SELECT COALESCE(SUM(unread_count_user1), 0) as total FROM conversations WHERE user1_id = ?
    `).get(userId) as { total: number };

    const asUser2 = db.prepare(`
      SELECT COALESCE(SUM(unread_count_user2), 0) as total FROM conversations WHERE user2_id = ?
    `).get(userId) as { total: number };

    return asUser1.total + asUser2.total;
  }
}
