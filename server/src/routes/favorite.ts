import { Router, Request, Response } from 'express';
import { FavoriteService } from '../services/FavoriteService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.post('/toggle', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const { spuId } = req.body;
    if (!spuId) {
      res.status(400).json({ code: 40001, message: '缺少spuId', data: null });
      return;
    }
    const result = FavoriteService.toggleFavorite(userId, spuId);
    res.json({ code: 0, message: result.isFavorited ? '已收藏' : '已取消收藏', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.get('/', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const page = req.query.page ? Number(req.query.page) : 1;
    const pageSize = req.query.pageSize ? Number(req.query.pageSize) : 20;
    const result = FavoriteService.getUserFavorites(userId, page, pageSize);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '查询失败', data: null });
  }
});

router.get('/count', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const count = FavoriteService.getFavoriteCount(userId);
    res.json({ code: 0, message: 'success', data: { count } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '查询失败', data: null });
  }
});

router.get('/check/:spuId', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const isFavorited = FavoriteService.isFavorited(userId, req.params.spuId);
    res.json({ code: 0, message: 'success', data: { isFavorited } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '查询失败', data: null });
  }
});

export default router;