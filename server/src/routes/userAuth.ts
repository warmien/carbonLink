import { Router, Request, Response } from 'express';
import { UserAuthService } from '../services/UserAuthService';
import { CaptchaService } from '../services/CaptchaService';
import { userAuthMiddleware } from '../middleware/userAuth';
import db from '../businessDatabase';

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

router.post('/browse', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  const { targetId, targetCategory } = req.body;
  if (!targetId) {
    res.status(400).json({ code: 40001, message: 'targetId不能为空', data: null });
    return;
  }
  try {
    db.prepare('INSERT INTO user_behaviors (user_id, behavior_type, target_id, target_category, timestamp) VALUES (?, ?, ?, ?, ?)')
      .run(userId, 'view', targetId, targetCategory || '', Date.now());
    res.json({ code: 0, message: 'success', data: null });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '记录失败', data: null });
  }
});

router.get('/browse-history', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  const page = Number(req.query.page) || 1;
  const pageSize = Number(req.query.pageSize) || 20;
  const offset = (page - 1) * pageSize;
  try {
    const totalRow = db.prepare('SELECT COUNT(DISTINCT target_id) as c FROM user_behaviors WHERE user_id = ? AND behavior_type = ?').get(userId, 'view') as { c: number };
    const rows = db.prepare(`
      SELECT ub.target_id, ub.target_category, ub.timestamp,
             s.title, s.images, MIN(k.price) as min_price
      FROM user_behaviors ub
      LEFT JOIN spu s ON s.id = ub.target_id
      LEFT JOIN sku k ON k.spu_id = s.id AND k.status = 'on_sale'
      WHERE ub.user_id = ? AND ub.behavior_type = ?
      GROUP BY ub.target_id
      ORDER BY MAX(ub.timestamp) DESC
      LIMIT ? OFFSET ?
    `).all(userId, 'view', pageSize, offset) as Record<string, unknown>[];
    const list = rows.map(r => ({
      targetId: r.target_id,
      targetCategory: r.target_category,
      timestamp: r.timestamp,
      title: r.title || '',
      images: r.images ? JSON.parse(r.images as string) : [],
      minPrice: r.min_price || 0
    }));
    res.json({ code: 0, message: 'success', data: { list, total: totalRow.c } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.get('/browse-count', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  try {
    const row = db.prepare('SELECT COUNT(DISTINCT target_id) as c FROM user_behaviors WHERE user_id = ? AND behavior_type = ?').get(userId, 'view') as { c: number };
    res.json({ code: 0, message: 'success', data: { count: row.c } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.get('/stats', userAuthMiddleware, (req: Request, res: Response): void => {
  const userId = (req as any).userId;
  try {
    const prodRow = db.prepare('SELECT COUNT(*) as c FROM spu WHERE seller_id = ?').get(userId) as { c: number };
    const productCount = prodRow.c;

    const soldRow = db.prepare("SELECT COUNT(*) as c FROM spu WHERE seller_id = ? AND status = 'sold_out'").get(userId) as { c: number };
    const soldCount = soldRow.c;

    const favRow = db.prepare('SELECT COUNT(*) as c FROM favorites WHERE user_id = ?').get(userId) as { c: number };
    const favoriteCount = favRow.c;

    const browseRow = db.prepare('SELECT COUNT(DISTINCT target_id) as c FROM user_behaviors WHERE user_id = ? AND behavior_type = ?').get(userId, 'view') as { c: number };
    const browseCount = browseRow.c;

    const creditRow = db.prepare('SELECT balance, total_earned, level FROM credit_accounts WHERE user_id = ?').get(userId) as { balance: number; total_earned: number; level: string } | undefined;
    const creditBalance = creditRow ? creditRow.balance : 0;
    const totalEarned = creditRow ? creditRow.total_earned : 0;
    const creditLevel = creditRow ? creditRow.level : '环保新手';

    res.json({ code: 0, message: 'success', data: { productCount, soldCount, favoriteCount, browseCount, creditBalance, totalEarned, creditLevel } });
  } catch (err) {
    res.status(500).json({ code: 50001, message: '查询失败', data: null });
  }
});

router.get('/phone-avatar', (req: Request, res: Response): void => {
  const phone = req.query.phone as string;
  if (!phone || phone.length < 11) {
    res.json({ code: 0, message: 'success', data: { avatar: '', nickname: '' } });
    return;
  }
  try {
    const row = db.prepare('SELECT avatar, nickname FROM users WHERE phone = ?').get(phone) as { avatar: string; nickname: string } | undefined;
    if (row) {
      res.json({ code: 0, message: 'success', data: { avatar: row.avatar || '', nickname: row.nickname || '' } });
    } else {
      res.json({ code: 0, message: 'success', data: { avatar: '', nickname: '' } });
    }
  } catch (err) {
    res.json({ code: 0, message: 'success', data: { avatar: '', nickname: '' } });
  }
});

export default router;