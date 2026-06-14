import { Request, Response, NextFunction } from 'express';
import db from '../database';

export function auditMiddleware(req: Request, _res: Response, next: NextFunction): void {
  const originalEnd = _res.end.bind(_res);
  const admin = (req as any).admin;
  _res.end = function (chunk?: any, encodingOrCb?: any, cb?: any): any {
    if (admin) {
      try {
        db.prepare('INSERT INTO audit_logs (adminId, action, target, timestamp, detail) VALUES (?, ?, ?, ?, ?)')
          .run(admin.id, req.method, req.originalUrl, Date.now(), `${req.method} ${req.originalUrl}`);
      } catch (e) {}
    }
    if (cb) {
      return originalEnd(chunk, encodingOrCb, cb);
    } else if (encodingOrCb) {
      return originalEnd(chunk, encodingOrCb);
    } else if (chunk !== undefined) {
      return originalEnd(chunk);
    } else {
      return originalEnd();
    }
  } as any;
  next();
}
