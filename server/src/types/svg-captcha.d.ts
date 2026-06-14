declare module 'svg-captcha' {
  interface CaptchaObj {
    data: string;
    text: string;
  }
  interface CaptchaOptions {
    size?: number;
    noise?: number;
    color?: boolean;
    background?: string;
    width?: number;
    height?: number;
  }
  export function create(options?: CaptchaOptions): CaptchaObj;
}