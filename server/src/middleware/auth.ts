import { Request, Response, NextFunction } from 'express';
import { AdminAuthService } from '../services/AdminAuthService';

export function authMiddleware(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ error: '未提供认证Token' });
    return;
  }
  const token = authHeader.substring(7);
  const decoded = AdminAuthService.verifyToken(token);
  if (!decoded) {
    res.status(401).json({ error: 'Token无效或已过期' });
    return;
  }
  (req as any).admin = decoded;
  next();
}