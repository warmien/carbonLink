import { Router, Request, Response } from 'express';
import { UserAuthService } from '../services/UserAuthService';
import { CaptchaService } from '../services/CaptchaService';
import { userAuthMiddleware } from '../middleware/userAuth';

const router = Router();

router.get('/captcha', (_req: Request, res: Response): void => {
  const result = CaptchaService.generate();
  res.json({
    code: 0,
    message: 'success',
    data: {
      captchaKey: result.captchaKey,
      captchaImage: result.captchaImage,
      captchaText: result.captchaText
    }
  });
});

router.post('/register', (req: Request, res: Response): void => {
  const { phone, password, captchaKey, captchaValue } = req.body;

  const captchaResult = CaptchaService.verify(captchaKey, captchaValue);
  if (!captchaResult.valid) {
    res.status(400).json({ code: 40001, message: captchaResult.message, data: null });
    return;
  }

  const result = UserAuthService.register(phone, password);
  if (result.success) {
    res.json({ code: 0, message: result.message, data: result.data });
  } else {
    res.status(400).json({ code: 40001, message: result.message, data: null });
  }
});

router.post('/login', (req: Request, res: Response): void => {
  const { phone, password, captchaKey, captchaValue } = req.body;

  const captchaResult = CaptchaService.verify(captchaKey, captchaValue);
  if (!captchaResult.valid) {
    res.status(400).json({ code: 40001, message: captchaResult.message, data: null });
    return;
  }

  const result = UserAuthService.login(phone, password);
  if (result.success) {
    res.json({ code: 0, message: result.message, data: result.data });
  } else {
    res.status(401).json({ code: 40101, message: result.message, data: null });
  }
});

router.post('/refresh', (req: Request, res: Response): void => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    res.status(400).json({ code: 40001, message: '缺少refreshToken', data: null });
    return;
  }

  const result = UserAuthService.refreshToken(refreshToken);
  if (result.success) {
    res.json({ code: 0, message: result.message, data: result.data });
  } else {
    res.status(401).json({ code: 40101, message: result.message, data: null });
  }
});

router.post('/logout', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  const authHeader = req.headers.authorization || '';
  const token = authHeader.substring(7);

  UserAuthService.logout(userId, token);

  res.json({ code: 0, message: '登出成功', data: null });
});

router.get('/profile', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  const profile = UserAuthService.getPublicProfile(userId);

  if (!profile) {
    res.status(404).json({ code: 40401, message: '用户不存在', data: null });
    return;
  }

  res.json({ code: 0, message: 'success', data: profile });
});

router.put('/profile', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  const { nickname, avatar, gender, bio, location } = req.body;

  const result = UserAuthService.updateProfile(userId, { nickname, avatar, gender, bio, location });
  if (result.success) {
    const profile = UserAuthService.getPublicProfile(userId);
    res.json({ code: 0, message: result.message, data: profile });
  } else {
    res.status(400).json({ code: 40001, message: result.message, data: null });
  }
});

router.put('/password', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword) {
    res.status(400).json({ code: 40001, message: '原密码和新密码不能为空', data: null });
    return;
  }

  const result = UserAuthService.changePassword(userId, oldPassword, newPassword);
  if (result.success) {
    res.json({ code: 0, message: result.message, data: null });
  } else {
    res.status(400).json({ code: 40001, message: result.message, data: null });
  }
});

export default router;