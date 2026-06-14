import svgCaptcha from 'svg-captcha';
import db from '../businessDatabase';

const { v4: uuidv4 } = require('uuid');

const CAPTCHA_EXPIRES_MS = 5 * 60 * 1000;
const MAX_CAPTCHA_PER_PHONE_PER_HOUR = 10;

export class CaptchaService {
  static generate(): { captchaKey: string; captchaImage: string; captchaText: string } {
    const captcha = svgCaptcha.create({
      size: 4,
      noise: 3,
      color: true,
      background: '#f0f0f0',
      width: 100,
      height: 40
    });

    const captchaKey = uuidv4();
    const now = Date.now();

    db.prepare(`
      INSERT INTO captcha_records (id, captcha_key, captcha_value, type, expires_at, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
    `).run(uuidv4(), captchaKey, captcha.text.toLowerCase(), 'image', now + CAPTCHA_EXPIRES_MS, now);

    CaptchaService.cleanExpired();

    return {
      captchaKey,
      captchaImage: 'data:image/svg+xml;base64,' + Buffer.from(captcha.data).toString('base64'),
      captchaText: captcha.text
    };
  }

  static verify(captchaKey: string, captchaValue: string): { valid: boolean; message: string } {
    if (!captchaKey || !captchaValue) {
      return { valid: false, message: '验证码不能为空' };
    }

    const record = db.prepare(`
      SELECT captcha_value, expires_at, used FROM captcha_records WHERE captcha_key = ?
    `).get(captchaKey) as { captcha_value: string; expires_at: number; used: number } | undefined;

    if (!record) {
      return { valid: false, message: '验证码不存在' };
    }

    if (record.used === 1) {
      return { valid: false, message: '验证码已使用' };
    }

    if (Date.now() > record.expires_at) {
      return { valid: false, message: '验证码已过期' };
    }

    if (record.captcha_value !== captchaValue.toLowerCase()) {
      return { valid: false, message: '验证码错误' };
    }

    db.prepare('UPDATE captcha_records SET used = 1 WHERE captcha_key = ?').run(captchaKey);

    return { valid: true, message: '验证成功' };
  }

  static checkRateLimit(phone: string): boolean {
    const oneHourAgo = Date.now() - 60 * 60 * 1000;
    const count = db.prepare(`
      SELECT COUNT(*) as c FROM captcha_records
      WHERE phone = ? AND created_at > ?
    `).get(phone, oneHourAgo) as { c: number };

    return count.c < MAX_CAPTCHA_PER_PHONE_PER_HOUR;
  }

  private static cleanExpired(): void {
    const now = Date.now();
    try {
      db.prepare('DELETE FROM captcha_records WHERE expires_at < ?').run(now);
    } catch {}
  }
}