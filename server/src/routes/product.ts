import { Router, Request, Response } from 'express';
import { ProductService } from '../services/ProductService';
import { InventoryService } from '../services/InventoryService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.post('/', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const userId = (req as any).userId;
    const result = ProductService.createProduct({
      ...req.body,
      sellerId: req.body.sellerId || userId
    });
    res.json({ code: 0, message: '发布成功', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '发布失败', data: null });
  }
});

router.get('/', (req: Request, res: Response): void => {
  try {
    const { categoryId, subCategoryId, status, sellerId, keyword, minPrice, maxPrice, condition, page, pageSize } = req.query;
    const result = ProductService.listSPUs({
      categoryId: categoryId ? Number(categoryId) : undefined,
      subCategoryId: subCategoryId ? Number(subCategoryId) : undefined,
      status: status as string | undefined,
      sellerId: sellerId as string | undefined,
      keyword: keyword as string | undefined,
      minPrice: minPrice ? Number(minPrice) : undefined,
      maxPrice: maxPrice ? Number(maxPrice) : undefined,
      condition: condition as string | undefined,
      page: page ? Number(page) : 1,
      pageSize: pageSize ? Number(pageSize) : 20
    });
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '查询失败', data: null });
  }
});

router.get('/:spuId', (req: Request, res: Response): void => {
  try {
    const result = ProductService.getSPUDetail(req.params.spuId);
    if (!result) {
      res.status(404).json({ code: 40401, message: '商品不存在', data: null });
      return;
    }
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '查询失败', data: null });
  }
});

router.put('/:spuId', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const result = ProductService.updateSPU(req.params.spuId, req.body);
    if (!result) {
      res.status(404).json({ code: 40401, message: '商品不存在', data: null });
      return;
    }
    res.json({ code: 0, message: '更新成功', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '更新失败', data: null });
  }
});

router.delete('/:spuId', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    ProductService.deleteSPU(req.params.spuId);
    res.json({ code: 0, message: '删除成功', data: null });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '删除失败', data: null });
  }
});

router.put('/:spuId/status', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const { status } = req.body;
    ProductService.toggleSPUStatus(req.params.spuId, status);
    res.json({ code: 0, message: '状态更新成功', data: null });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '状态更新失败', data: null });
  }
});

export default router;

export const skuRouter = Router();

skuRouter.put('/:skuId', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const result = ProductService.updateSKU(req.params.skuId, req.body);
    if (!result) {
      res.status(404).json({ code: 40401, message: 'SKU不存在', data: null });
      return;
    }
    res.json({ code: 0, message: '更新成功', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '更新失败', data: null });
  }
});

skuRouter.get('/:skuId', (req: Request, res: Response): void => {
  try {
    const skuId = req.params.skuId;
    const skuDetail = ProductService.getSPUDetail(skuId);
    if (!skuDetail) {
      res.status(404).json({ code: 40401, message: 'SKU不存在', data: null });
      return;
    }
    const inventory = InventoryService.getInventory(skuId);
    res.json({ code: 0, message: 'success', data: { ...skuDetail, inventory } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: err instanceof Error ? err.message : '查询失败', data: null });
  }
});