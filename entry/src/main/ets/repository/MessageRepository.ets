import { Conversation, Message } from '../models/Message';
import { MockMessages } from '../mock/MockMessages';

export class MessageRepository {
  getConversations(): Conversation[] {
    return MockMessages.getConversations();
  }

  getMessages(conversationId: string): Message[] {
    return MockMessages.getMessages(conversationId);
  }

  sendMessage(message: Message): void {
    MockMessages.addMessage(message);
  }

  markConversationAsRead(conversationId: string): void {
    MockMessages.markConversationAsRead(conversationId);
  }

  findOrCreateConversation(targetUserId: string, targetUserName: string,
    productId: string, productTitle: string): string {
    return MockMessages.findOrCreateConversation(targetUserId, targetUserName, productId, productTitle);
  }
}

export const messageRepository = new MessageRepository();
