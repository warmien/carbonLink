import db from '../businessDatabase';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User, UserPublicProfile, UserStatus } from '../models/User';

const { v4: uuidv4 } = require('uuid');

const ACCESS_TOKEN_SECRET = process.env.JWT_SECRET || 'carbonlink_user_secret_2024';
const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET || 'carbonlink_refresh_secret_2024';
const ACCESS_TOKEN_EXPIRES_IN = '2h';
const REFRESH_TOKEN_EXPIRES_IN = '7d';
const MAX_LOGIN_FAILS = 5;
const LOCK_DURATION_MS = 15 * 60 * 1000;
const BCRYPT_SALT_ROUNDS = 10;

export class UserAuthService {
  static register(phone: string, password: string): { success: boolean; message: string; data?: object } {
    if (!phone || !password) {
      return { success: false, message: '手机号和密码不能为空' };
    }

    if (!/^1[3-9]\d{9}$/.test(phone)) {
      return { success: false, message: '手机号格式不正确' };
    }

    if (password.length < 6) {
      return { success: false, message: '密码至少6位' };
    }

    const existing = db.prepare('SELECT id FROM users WHERE phone = ?').get(phone);
    if (existing) {
      return { success: false, message: '该手机号已注册' };
    }

    const now = Date.now();
    const userId = uuidv4();
    const hashedPassword = bcrypt.hashSync(password, BCRYPT_SALT_ROUNDS);
    const maskedPhone = phone.substring(0, 3) + '****' + phone.substring(7);
    const nickname = '用户' + maskedPhone;
    const joinDate = new Date(now).toISOString().split('T')[0];

    const registerTx = db.transaction(() => {
      db.prepare(`
        INSERT INTO users (id, phone, password, nickname, join_date, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `).run(userId, phone, hashedPassword, nickname, joinDate, now, now);

      db.prepare(`
        INSERT INTO credit_accounts (user_id, created_at, updated_at)
        VALUES (?, ?, ?)
      `).run(userId, now, now);

      db.prepare(`
        INSERT INTO user_profiles (user_id, last_updated)
        VALUES (?, ?)
      `).run(userId, now);
    });

    try {
      registerTx();
    } catch (err) {
      return { success: false, message: '注册失败，请稍后重试' };
    }

    const tokens = UserAuthService.generateTokens(userId);
    const profile = UserAuthService.getPublicProfile(userId);

    return {
      success: true,
      message: '注册成功',
      data: {
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: 7200,
        user: profile
      }
    };
  }

  static login(phone: string, password: string): { success: boolean; message: string; data?: object } {
    if (!phone || !password) {
      return { success: false, message: '手机号和密码不能为空' };
    }

    const row = db.prepare('SELECT * FROM users WHERE phone = ?').get(phone) as User | undefined;
    if (!row) {
      return { success: false, message: '手机号或密码错误' };
    }

    if (row.lock_until > Date.now()) {
      const remainMin = Math.ceil((row.lock_until - Date.now()) / 60000);
      return { success: false, message: `账号已锁定，请${remainMin}分钟后重试` };
    }

    if (row.lock_until > 0 && row.lock_until <= Date.now()) {
      db.prepare('UPDATE users SET login_fail_count = 0, lock_until = 0, status = ? WHERE id = ?')
        .run(UserStatus.ACTIVE, row.id);
      row.login_fail_count = 0;
      row.lock_until = 0;
    }

    const valid = bcrypt.compareSync(password, row.password);
    if (!valid) {
      const newFailCount = row.login_fail_count + 1;
      if (newFailCount >= MAX_LOGIN_FAILS) {
        db.prepare('UPDATE users SET login_fail_count = ?, lock_until = ?, status = ? WHERE id = ?')
          .run(newFailCount, Date.now() + LOCK_DURATION_MS, UserStatus.LOCKED, row.id);
        return { success: false, message: `连续${MAX_LOGIN_FAILS}次错误，账号已锁定15分钟` };
      }
      db.prepare('UPDATE users SET login_fail_count = ? WHERE id = ?')
        .run(newFailCount, row.id);
      return { success: false, message: '手机号或密码错误' };
    }

    db.prepare('UPDATE users SET login_fail_count = 0, lock_until = 0, status = ?, updated_at = ? WHERE id = ?')
      .run(UserStatus.ACTIVE, Date.now(), row.id);

    const tokens = UserAuthService.generateTokens(row.id);
    const profile = UserAuthService.getPublicProfile(row.id);

    return {
      success: true,
      message: '登录成功',
      data: {
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: 7200,
        user: profile
      }
    };
  }

  static refreshToken(refreshToken: string): { success: boolean; message: string; data?: object } {
    try {
      const decoded = jwt.verify(refreshToken, REFRESH_TOKEN_SECRET) as { userId: string; type: string };
      if (decoded.type !== 'refresh') {
        return { success: false, message: '无效的刷新Token' };
      }

      const user = db.prepare('SELECT id, status FROM users WHERE id = ?').get(decoded.userId) as { id: string; status: string } | undefined;
      if (!user || user.status !== UserStatus.ACTIVE) {
        return { success: false, message: '用户不存在或已被锁定' };
      }

      const tokens = UserAuthService.generateTokens(user.id);
      return {
        success: true,
        message: '刷新成功',
        data: {
          token: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresIn: 7200
        }
      };
    } catch {
      return { success: false, message: '刷新Token已过期，请重新登录' };
    }
  }

  static logout(userId: string, tokenJti: string): void {
    try {
      const decoded = jwt.verify(tokenJti.split('.')[0], ACCESS_TOKEN_SECRET) as object;
    } catch {}

    const now = Date.now();
    try {
      const decoded = jwt.decode(tokenJti) as { exp: number } | null;
      if (decoded && decoded.exp) {
        db.prepare('INSERT OR IGNORE INTO token_blacklist (token_jti, expires_at, created_at) VALUES (?, ?, ?)')
          .run(tokenJti, decoded.exp * 1000, now);
      }
    } catch {}
  }

  static verifyAccessToken(token: string): { userId: string } | null {
    try {
      const decoded = jwt.verify(token, ACCESS_TOKEN_SECRET) as { userId: string; type: string; jti: string };
      if (decoded.type !== 'access') {
        return null;
      }

      const blacklisted = db.prepare('SELECT id FROM token_blacklist WHERE token_jti = ?').get(decoded.jti);
      if (blacklisted) {
        return null;
      }

      return { userId: decoded.userId };
    } catch {
      return null;
    }
  }

  static getPublicProfile(userId: string): UserPublicProfile | null {
    const row = db.prepare(`
      SELECT id, nickname, avatar, phone, gender, bio,
             credit_score, credit_level, product_count, sold_count,
             follower_count, following_count, join_date, location
      FROM users WHERE id = ?
    `).get(userId) as User | undefined;

    if (!row) return null;

    const favRow = db.prepare('SELECT COUNT(*) as c FROM favorites WHERE user_id = ?').get(userId) as { c: number };

    return {
      id: row.id,
      nickname: row.nickname,
      avatar: row.avatar,
      phone: row.phone,
      gender: row.gender,
      bio: row.bio,
      creditScore: row.credit_score,
      creditLevel: row.credit_level,
      productCount: row.product_count,
      soldCount: row.sold_count,
      favoriteCount: favRow.c,
      followerCount: row.follower_count,
      followingCount: row.following_count,
      joinDate: row.join_date,
      location: row.location
    };
  }

  static updateProfile(userId: string, updates: { nickname?: string; avatar?: string; gender?: string; bio?: string; location?: string }): { success: boolean; message: string } {
    const fields: string[] = [];
    const values: (string | number)[] = [];

    if (updates.nickname !== undefined) {
      if (updates.nickname.length < 2 || updates.nickname.length > 20) {
        return { success: false, message: '昵称长度2-20字符' };
      }
      fields.push('nickname = ?');
      values.push(updates.nickname);
    }
    if (updates.avatar !== undefined) {
      fields.push('avatar = ?');
      values.push(updates.avatar);
    }
    if (updates.gender !== undefined) {
      fields.push('gender = ?');
      values.push(updates.gender);
    }
    if (updates.bio !== undefined) {
      if (updates.bio.length > 200) {
        return { success: false, message: '简介最多200字符' };
      }
      fields.push('bio = ?');
      values.push(updates.bio);
    }
    if (updates.location !== undefined) {
      fields.push('location = ?');
      values.push(updates.location);
    }

    if (fields.length === 0) {
      return { success: false, message: '没有需要更新的字段' };
    }

    fields.push('updated_at = ?');
    values.push(Date.now());
    values.push(userId);

    db.prepare(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`).run(...values);
    return { success: true, message: '更新成功' };
  }

  static changePassword(userId: string, oldPassword: string, newPassword: string): { success: boolean; message: string } {
    if (newPassword.length < 6) {
      return { success: false, message: '新密码至少6位' };
    }

    const row = db.prepare('SELECT password FROM users WHERE id = ?').get(userId) as { password: string } | undefined;
    if (!row) {
      return { success: false, message: '用户不存在' };
    }

    const valid = bcrypt.compareSync(oldPassword, row.password);
    if (!valid) {
      return { success: false, message: '原密码错误' };
    }

    const hashedPassword = bcrypt.hashSync(newPassword, BCRYPT_SALT_ROUNDS);
    db.prepare('UPDATE users SET password = ?, updated_at = ? WHERE id = ?')
      .run(hashedPassword, Date.now(), userId);

    return { success: true, message: '密码修改成功' };
  }

  private static generateTokens(userId: string): { accessToken: string; refreshToken: string } {
    const accessJti = uuidv4();
    const refreshJti = uuidv4();

    const accessToken = jwt.sign(
      { userId, type: 'access', jti: accessJti },
      ACCESS_TOKEN_SECRET,
      { expiresIn: ACCESS_TOKEN_EXPIRES_IN }
    );

    const refreshToken = jwt.sign(
      { userId, type: 'refresh', jti: refreshJti },
      REFRESH_TOKEN_SECRET,
      { expiresIn: REFRESH_TOKEN_EXPIRES_IN }
    );

    return { accessToken, refreshToken };
  }
}