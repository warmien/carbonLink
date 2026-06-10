import { Router, Request, Response } from 'express';
import { AdminAuthService } from '../services/AdminAuthService';
import { authMiddleware } from '../middleware/auth';

const router = Router();

router.post('/login', (req: Request, res: Response): void => {
  const { username, password } = req.body;
  if (!username || !password) {
    res.status(400).json({ error: '用户名和密码不能为空' });
    return;
  }
  const result = AdminAuthService.login(username, password);
  if (result.success) {
    res.json({ token: result.token, message: result.message });
  } else {
    res.status(401).json({ error: result.message });
  }
});

router.post('/logout', authMiddleware, (req: Request, res: Response): void => {
  res.json({ message: '登出成功' });
});

router.get('/profile', authMiddleware, (req: Request, res: Response): void => {
  const admin = (req as any).admin;
  const profile = AdminAuthService.getProfile(admin.id);
  if (!profile) {
    res.status(404).json({ error: '用户不存在' });
    return;
  }
  res.json({
    id: profile.id,
    username: profile.username,
    role: profile.role,
    status: profile.status,
    lastLoginTime: profile.lastLoginTime
  });
});

export default router;