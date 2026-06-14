import { Router, Request, Response } from 'express';
import { InventoryService } from '../services/InventoryService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.post('/deduct', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const { skuId, quantity } = req.body;
    if (!skuId || !quantity) {
      res.status(400).json({ code: 40001, message: 'skuId和quantity不能为空', data: null });
      return;
    }
    const result = InventoryService.deductStock(skuId, Number(quantity));
    if (result.success) {
      res.json({ code: 0, message: result.message, data: null });
    } else {
      res.status(400).json({ code: 40001, message: result.message, data: null });
    }
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.post('/rollback', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const { skuId, quantity } = req.body;
    if (!skuId || !quantity) {
      res.status(400).json({ code: 40001, message: 'skuId和quantity不能为空', data: null });
      return;
    }
    InventoryService.rollbackStock(skuId, Number(quantity));
    res.json({ code: 0, message: '回滚成功', data: null });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.post('/lock', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const { skuId, quantity } = req.body;
    if (!skuId || !quantity) {
      res.status(400).json({ code: 40001, message: 'skuId和quantity不能为空', data: null });
      return;
    }
    const result = InventoryService.lockStock(skuId, Number(quantity));
    if (result.success) {
      res.json({ code: 0, message: result.message, data: null });
    } else {
      res.status(400).json({ code: 40001, message: result.message, data: null });
    }
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.post('/unlock', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const { skuId, quantity } = req.body;
    if (!skuId || !quantity) {
      res.status(400).json({ code: 40001, message: 'skuId和quantity不能为空', data: null });
      return;
    }
    InventoryService.unlockStock(skuId, Number(quantity));
    res.json({ code: 0, message: '解锁成功', data: null });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.get('/:skuId', (req: Request, res: Response): void => {
  const result = InventoryService.getInventory(req.params.skuId);
  if (!result) {
    res.status(404).json({ code: 40401, message: '库存记录不存在', data: null });
    return;
  }
  res.json({ code: 0, message: 'success', data: result });
});

export default router;