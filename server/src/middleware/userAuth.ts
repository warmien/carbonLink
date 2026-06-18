import { Request, Response, NextFunction } from 'express';
import { UserAuthService } from '../services/UserAuthService';

// JWT双Token认证中间件：验证AccessToken签名 + 检查Token黑名单
// AccessToken有效期2小时，RefreshToken有效期7天（见UserAuthService）
export function userAuthMiddleware(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ code: 40101, message: '未提供认证Token' });
    return;
  }

  const token = authHeader.substring(7);
  const decoded = UserAuthService.verifyAccessToken(token);
  if (!decoded) {
    res.status(401).json({ code: 40101, message: 'Token无效或已过期' });
    return;
  }

  (req as any).userId = decoded.userId;
  next();
}