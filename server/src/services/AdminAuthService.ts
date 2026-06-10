import db from '../database';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AdminAccount, AdminStatus } from '../models/AdminAccount';
import { AuditAction } from '../models/AuditLog';

const JWT_SECRET = 'carbonlink_admin_secret_2024';
const JWT_EXPIRES_IN = '24h';
const MAX_LOGIN_FAILS = 3;
const LOCK_DURATION_MS = 15 * 60 * 1000;

export class AdminAuthService {
  static login(username: string, password: string): { success: boolean; token?: string; message: string } {
    const row = db.prepare('SELECT * FROM admin_accounts WHERE username = ?').get(username) as AdminAccount | undefined;
    if (!row) return { success: false, message: '账号或密码错误' };

    if (row.lockedUntil && row.lockedUntil > Date.now()) {
      const remainMin = Math.ceil((row.lockedUntil - Date.now()) / 60000);
      return { success: false, message: `账号已锁定，请${remainMin}分钟后重试` };
    }

    if (row.lockedUntil && row.lockedUntil <= Date.now()) {
      db.prepare('UPDATE admin_accounts SET loginFailCount = 0, lockedUntil = NULL, status = ? WHERE id = ?')
        .run(AdminStatus.ACTIVE, row.id);
      row.loginFailCount = 0;
      row.lockedUntil = null;
    }

    const valid = bcrypt.compareSync(password, row.password);
    if (!valid) {
      const newFailCount = row.loginFailCount + 1;
      if (newFailCount >= MAX_LOGIN_FAILS) {
        db.prepare('UPDATE admin_accounts SET loginFailCount = ?, lockedUntil = ?, status = ? WHERE id =')
          .run(newFailCount, Date.now() + LOCK_DURATION_MS, AdminStatus.LOCKED, row.id);
        return { success: false, message: '连续3次错误，账号已锁定15分钟' };
      }
      db.prepare('UPDATE admin_accounts SET loginFailCount = ? WHERE id = ?').run(newFailCount, row.id);
      return { success: false, message: '账号或密码错误' };
    }

    db.prepare('UPDATE admin_accounts SET loginFailCount = 0, lastLoginTime = ? WHERE id = ?')
      .run(Date.now(), row.id);

    const token = jwt.sign({ id: row.id, username: row.username, role: row.role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
    return { success: true, token, message: '登录成功' };
  }

  static verifyToken(token: string): { id: number; username: string; role: string } | null {
    try {
      return jwt.verify(token, JWT_SECRET) as { id: number; username: string; role: string };
    } catch {
      return null;
    }
  }

  static getProfile(adminId: number): AdminAccount | null {
    const row = db.prepare('SELECT id, username, role, status, lastLoginTime FROM admin_accounts WHERE id = ?').get(adminId) as AdminAccount | undefined;
    return row || null;
  }
}