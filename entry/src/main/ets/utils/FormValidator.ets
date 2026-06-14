export interface ValidationResult {
  valid: boolean;
  message: string;
}

export class FormValidator {
  static validatePhone(phone: string): ValidationResult {
    if (phone.length === 0) {
      return { valid: false, message: '请输入手机号' };
    }
    const pattern: RegExp = /^1[3-9]\d{9}$/;
    if (!pattern.test(phone)) {
      return { valid: false, message: '请输入正确的11位手机号' };
    }
    return { valid: true, message: '' };
  }

  static validatePassword(password: string): ValidationResult {
    if (password.length === 0) {
      return { valid: false, message: '请输入密码' };
    }
    if (password.length < 6) {
      return { valid: false, message: '密码至少6位' };
    }
    return { valid: true, message: '' };
  }

  static validateConfirmPassword(password: string, confirm: string): ValidationResult {
    if (confirm.length === 0) {
      return { valid: false, message: '请确认密码' };
    }
    if (password !== confirm) {
      return { valid: false, message: '两次密码不一致' };
    }
    return { valid: true, message: '' };
  }

  static validateCaptcha(captcha: string): ValidationResult {
    if (captcha.length === 0) {
      return { valid: false, message: '请输入验证码' };
    }
    if (captcha.length < 4) {
      return { valid: false, message: '验证码至少4位' };
    }
    return { valid: true, message: '' };
  }

  static validateNickname(nickname: string): ValidationResult {
    if (nickname.length === 0) {
      return { valid: false, message: '请输入昵称' };
    }
    if (nickname.length < 2) {
      return { valid: false, message: '昵称至少2个字符' };
    }
    if (nickname.length > 20) {
      return { valid: false, message: '昵称最多20个字符' };
    }
    return { valid: true, message: '' };
  }
}