import { HttpService, ApiResponse } from './HttpService';

export interface CaptchaData {
  captchaKey: string;
  captchaImage: string;
  captchaText: string;
}

export class CaptchaService {
  static async getCaptcha(): Promise<CaptchaData | null> {
    try {
      const response: ApiResponse = await HttpService.GET('/captcha');
      if (response.code === 0 && response.data !== null) {
        const data: Record<string, string | number | object> = response.data;
        const result: CaptchaData = {
          captchaKey: data['captchaKey'] as string,
          captchaImage: data['captchaImage'] as string,
          captchaText: data['captchaText'] as string
        };
        return result;
      }
      return null;
    } catch (err) {
      console.error(`[CaptchaService] getCaptcha failed: ${(err as Error).message}`);
      return null;
    }
  }
}
