import { Router, Request, Response } from 'express';
import { SpecService } from '../services/SpecService';

const router = Router();

router.post('/spec-names', (req: Request, res: Response): void => {
  try {
    const { name } = req.body;
    if (!name) {
      res.status(400).json({ code: 40001, message: '规格名不能为空', data: null });
      return;
    }
    const result = SpecService.createSpecName(name);
    res.json({ code: 0, message: '创建成功', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '创建失败', data: null });
  }
});

router.get('/spec-names', (_req: Request, res: Response): void => {
  const result = SpecService.listSpecNames();
  res.json({ code: 0, message: 'success', data: result });
});

router.post('/spec-values', (req: Request, res: Response): void => {
  try {
    const { specNameId, value } = req.body;
    if (!specNameId || !value) {
      res.status(400).json({ code: 40001, message: 'specNameId和value不能为空', data: null });
      return;
    }
    const result = SpecService.createSpecValue(Number(specNameId), value);
    res.json({ code: 0, message: '创建成功', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '创建失败', data: null });
  }
});

router.get('/spec-values/:specNameId', (req: Request, res: Response): void => {
  const result = SpecService.listSpecValuesBySpecName(Number(req.params.specNameId));
  res.json({ code: 0, message: 'success', data: result });
});

router.post('/category-specs', (req: Request, res: Response): void => {
  try {
    const { categoryId, specNameId } = req.body;
    if (!categoryId || !specNameId) {
      res.status(400).json({ code: 40001, message: 'categoryId和specNameId不能为空', data: null });
      return;
    }
    SpecService.bindSpecNameToCategory(Number(categoryId), Number(specNameId));
    res.json({ code: 0, message: '绑定成功', data: null });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '绑定失败', data: null });
  }
});

router.get('/category-specs/:categoryId', (req: Request, res: Response): void => {
  const result = SpecService.getCategorySpecTree(Number(req.params.categoryId));
  res.json({ code: 0, message: 'success', data: result });
});

router.post('/attribute-names', (req: Request, res: Response): void => {
  try {
    const { name, inputType } = req.body;
    if (!name) {
      res.status(400).json({ code: 40001, message: '属性名不能为空', data: null });
      return;
    }
    const result = SpecService.createAttributeName(name, inputType || 'text');
    res.json({ code: 0, message: '创建成功', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '创建失败', data: null });
  }
});

router.get('/attribute-names', (_req: Request, res: Response): void => {
  const result = SpecService.listAttributeNames();
  res.json({ code: 0, message: 'success', data: result });
});

router.post('/category-attributes', (req: Request, res: Response): void => {
  try {
    const { categoryId, attributeNameId, isRequired } = req.body;
    if (!categoryId || !attributeNameId) {
      res.status(400).json({ code: 40001, message: 'categoryId和attributeNameId不能为空', data: null });
      return;
    }
    SpecService.bindAttributeToCategory(Number(categoryId), Number(attributeNameId), !!isRequired);
    res.json({ code: 0, message: '绑定成功', data: null });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '绑定失败', data: null });
  }
});

router.get('/category-attributes/:categoryId', (req: Request, res: Response): void => {
  const result = SpecService.getAttributesByCategory(Number(req.params.categoryId));
  res.json({ code: 0, message: 'success', data: result });
});

export default router;