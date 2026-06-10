import { Request, Response, NextFunction } from 'express';
import db from '../database';
import { AuditAction } from '../models/AuditLog';

export function auditMiddleware(req: Request, res: Response, next: NextFunction): void {
  const originalEnd = res.end;
  const admin = (req as any).admin;
  res.end = function (...args: any[]) {
    if (admin) {
      try {
        db.prepare('INSERT INTO audit_logs (adminId, action, target, timestamp, detail) VALUES (?, ?, ?, ?, ?)')
          .run(admin.id, req.method, req.originalUrl, Date.now(), `${req.method} ${req.originalUrl}`);
      } catch (e) {}
    }
    return originalEnd.apply(res, args);
  };
  next();
}