import { Router, Request, Response } from 'express';
import { OrderService } from '../services/OrderService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.post('/', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const buyerId = (req as any).userId;
    const { spuId, skuId, paymentMethod } = req.body;

    if (!spuId) {
      res.status(400).json({ code: 40001, message: '商品ID不能为空', data: null });
      return;
    }

    const order = OrderService.createOrder({
      spuId,
      skuId: skuId || undefined,
      buyerId,
      paymentMethod: paymentMethod || 'wechat'
    });

    res.json({ code: 0, message: '购买成功', data: order });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '购买失败', data: null });
  }
});

router.get('/buyer', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const buyerId = (req as any).userId;
    const status = req.query.status as string | undefined;
    const orders = OrderService.getBuyerOrders(buyerId, status);
    res.json({ code: 0, message: 'success', data: orders });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.get('/seller', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const sellerId = (req as any).userId;
    const status = req.query.status as string | undefined;
    const orders = OrderService.getSellerOrders(sellerId, status);
    res.json({ code: 0, message: 'success', data: orders });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.put('/:orderId/confirm', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const order = OrderService.confirmReceive(req.params.orderId, userId);
    res.json({ code: 0, message: '确认收货成功', data: order });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.put('/:orderId/ship', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const sellerId = (req as any).userId;
    const { trackingNumber } = req.body;
    const order = OrderService.shipOrder(req.params.orderId, sellerId, trackingNumber);
    res.json({ code: 0, message: '发货成功', data: order });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.put('/:orderId/cancel', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const order = OrderService.cancelOrder(req.params.orderId, userId);
    res.json({ code: 0, message: '取消成功', data: order });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

router.put('/:orderId/pay', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const order = OrderService.payOrder(req.params.orderId, userId);
    res.json({ code: 0, message: '付款成功', data: order });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '操作失败', data: null });
  }
});

export default router;