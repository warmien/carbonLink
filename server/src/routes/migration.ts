import { Router, Request, Response } from 'express';
import { MigrationService } from '../services/MigrationService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.post('/execute', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    const result = MigrationService.migrate();
    res.json({ code: 0, message: '迁移完成', data: result });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '迁移失败', data: null });
  }
});

router.post('/rollback', userAuthMiddleware, (req: Request, res: Response): void => {
  try {
    MigrationService.rollback();
    res.json({ code: 0, message: '回滚完成', data: null });
  } catch (err) {
    res.status(400).json({ code: 40001, message: err instanceof Error ? err.message : '回滚失败', data: null });
  }
});

router.get('/status', (_req: Request, res: Response): void => {
  const result = MigrationService.getStatus();
  res.json({ code: 0, message: 'success', data: result });
});

export default router;