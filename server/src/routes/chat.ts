import { Router, Request, Response } from 'express';
import { ChatService } from '../services/ChatService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.post('/conversations', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const buyerId = (req as any).userId;
    const { sellerId, productId } = req.body;

    if (!sellerId || !productId) {
      res.status(400).json({ code: 40001, message: 'sellerId和productId不能为空', data: null });
      return;
    }

    const conversation = ChatService.findOrCreateConversation(buyerId, sellerId, productId);
    res.json({ code: 0, message: 'success', data: conversation });
  } catch (err) {
    const msg = err instanceof Error ? err.message : '操作失败';
    const errorMap: Record<string, { code: number; status: number; message: string }> = {
      'CANNOT_CHAT_WITH_SELF': { code: 40001, status: 400, message: '不能与自己聊天' },
      'SELLER_UNAVAILABLE': { code: 40301, status: 403, message: '卖家账号异常' },
      'PRODUCT_NOT_FOUND': { code: 40401, status: 404, message: '商品不存在或已下架' },
    };
    const mapped = errorMap[msg];
    if (mapped) {
      res.status(mapped.status).json({ code: mapped.code, message: mapped.message, data: null });
    } else {
      res.status(500).json({ code: 50001, message: msg, data: null });
    }
  }
});

router.get('/conversations', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const result = ChatService.getConversations(userId);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.get('/messages/:conversationId', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { conversationId } = req.params;
    const page = parseInt(req.query.page as string) || 1;
    const size = parseInt(req.query.size as string) || 20;

    const result = ChatService.getMessages(conversationId, userId, page, size);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    const msg = err instanceof Error ? err.message : '查询失败';
    const errorMap: Record<string, { code: number; status: number; message: string }> = {
      'CONVERSATION_NOT_FOUND': { code: 40401, status: 404, message: '会话不存在' },
      'NO_PERMISSION': { code: 40301, status: 403, message: '无权访问该会话' },
    };
    const mapped = errorMap[msg];
    if (mapped) {
      res.status(mapped.status).json({ code: mapped.code, message: mapped.message, data: null });
    } else {
      res.status(500).json({ code: 50001, message: msg, data: null });
    }
  }
});

router.post('/messages', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const senderId = (req as any).userId;
    const { conversationId, content, msgType } = req.body;

    if (!conversationId) {
      res.status(400).json({ code: 40001, message: 'conversationId不能为空', data: null });
      return;
    }

    if (!content || content.trim().length === 0) {
      res.status(400).json({ code: 40002, message: '消息内容不能为空', data: null });
      return;
    }

    if (content.length > 500) {
      res.status(400).json({ code: 40003, message: '消息内容不能超过500字符', data: null });
      return;
    }

    const result = ChatService.sendMessage(conversationId, senderId, content.trim(), msgType || 'text');
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    const msg = err instanceof Error ? err.message : '发送失败';
    const errorMap: Record<string, { code: number; status: number; message: string }> = {
      'CONVERSATION_NOT_FOUND': { code: 40401, status: 404, message: '会话不存在' },
      'NO_PERMISSION': { code: 40301, status: 403, message: '无权在该会话发言' },
    };
    const mapped = errorMap[msg];
    if (mapped) {
      res.status(mapped.status).json({ code: mapped.code, message: mapped.message, data: null });
    } else {
      res.status(500).json({ code: 50001, message: msg, data: null });
    }
  }
});

router.put('/conversations/:conversationId/read', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { conversationId } = req.params;

    const result = ChatService.markAsRead(conversationId, userId);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    const msg = err instanceof Error ? err.message : '操作失败';
    const errorMap: Record<string, { code: number; status: number; message: string }> = {
      'CONVERSATION_NOT_FOUND': { code: 40401, status: 404, message: '会话不存在' },
    };
    const mapped = errorMap[msg];
    if (mapped) {
      res.status(mapped.status).json({ code: mapped.code, message: mapped.message, data: null });
    } else {
      res.status(500).json({ code: 50001, message: msg, data: null });
    }
  }
});

export default router;