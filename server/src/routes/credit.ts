import { Router, Request, Response } from 'express';
import { CreditService } from '../services/CreditService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.get('/account', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const account = CreditService.getAccount(userId);
    res.json({ code: 0, message: 'success', data: { balance: account.balance, totalEarned: account.totalEarned, totalSpent: account.totalSpent, level: account.level } });
  } catch (err) {
    console.error('[Credit] /account error:', err);
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.get('/transactions', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const page = parseInt(req.query.page as string) || 1;
    const pageSize = parseInt(req.query.pageSize as string) || 20;
    const typeFilter = req.query.type as string | undefined;
    const result = CreditService.getTransactions(userId, page, pageSize, typeFilter);
    res.json({ code: 0, message: 'success', data: { list: result.list, total: result.total } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.post('/publish-reward', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { productId } = req.body;
    if (!productId) { res.status(400).json({ code: 40001, message: '缺少productId', data: null }); return; }
    CreditService.onProductPublished(productId, userId);
    const account = CreditService.getAccount(userId);
    res.json({ code: 0, message: 'success', data: { balance: account.balance, totalEarned: account.totalEarned, level: account.level } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '操作失败', data: null });
  }
});

router.post('/trade-reward', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { orderId, counterpartyId, sellerCredits, carbonReduction, isBuyer } = req.body;
    if (!orderId || !counterpartyId) { res.status(400).json({ code: 40001, message: '缺少参数', data: null }); return; }
    const credits = sellerCredits || 0;
    const reduction = carbonReduction || 0;
    if (isBuyer) {
      CreditService.onTradeCompleted(orderId, userId, counterpartyId, credits, reduction);
    } else {
      CreditService.onTradeCompleted(orderId, counterpartyId, userId, credits, reduction);
    }
    const account = CreditService.getAccount(userId);
    res.json({ code: 0, message: 'success', data: { balance: account.balance, totalEarned: account.totalEarned, level: account.level } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '操作失败', data: null });
  }
});

router.post('/achievement-reward', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { rewardCredits, relatedId } = req.body;
    if (!rewardCredits || !relatedId) { res.status(400).json({ code: 40001, message: '缺少参数', data: null }); return; }
    CreditService.onAchievementReward(userId, rewardCredits, relatedId);
    const account = CreditService.getAccount(userId);
    res.json({ code: 0, message: 'success', data: { balance: account.balance, totalEarned: account.totalEarned, level: account.level } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '操作失败', data: null });
  }
});

router.post('/donation-reward', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { productId, baseCredits, carbonReduction } = req.body;
    if (!productId || !baseCredits) { res.status(400).json({ code: 40001, message: '缺少参数', data: null }); return; }
    CreditService.onDonation(productId, userId, baseCredits, carbonReduction || 0);
    const account = CreditService.getAccount(userId);
    res.json({ code: 0, message: 'success', data: { balance: account.balance, totalEarned: account.totalEarned, level: account.level } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '操作失败', data: null });
  }
});

router.post('/reform-reward', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { productId, baseCredits, carbonReduction } = req.body;
    if (!productId || !baseCredits) { res.status(400).json({ code: 40001, message: '缺少参数', data: null }); return; }
    CreditService.onReform(productId, userId, baseCredits, carbonReduction || 0);
    const account = CreditService.getAccount(userId);
    res.json({ code: 0, message: 'success', data: { balance: account.balance, totalEarned: account.totalEarned, level: account.level } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '操作失败', data: null });
  }
});

router.post('/transfer', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { toUserId, amount } = req.body;
    if (!toUserId || !amount) { res.status(400).json({ code: 40001, message: '缺少参数', data: null }); return; }
    const result = CreditService.transferCredits(userId, toUserId, amount);
    res.json({ code: result.success ? 0 : 40001, message: result.message, data: result.success ? { balance: CreditService.getAccount(userId).balance } : null });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '操作失败', data: null });
  }
});

router.post('/exchange', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { productId, requiredCredits } = req.body;
    if (!productId || !requiredCredits) { res.status(400).json({ code: 40001, message: '缺少参数', data: null }); return; }
    const result = CreditService.exchangeCredits(userId, requiredCredits, productId);
    res.json({ code: result.success ? 0 : 40001, message: result.message, data: result.success ? { balance: CreditService.getAccount(userId).balance } : null });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '操作失败', data: null });
  }
});

router.get('/stats', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const account = CreditService.getAccount(userId);
    const todayEarned = CreditService.getTodayEarned(userId);
    const totalReduction = CreditService.getTotalReduction(userId);
    const tradeCount = CreditService.getTradeCount(userId);
    res.json({ code: 0, message: 'success', data: { balance: account.balance, totalEarned: account.totalEarned, totalSpent: account.totalSpent, level: account.level, todayEarned, totalReduction, tradeCount } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

export default router;