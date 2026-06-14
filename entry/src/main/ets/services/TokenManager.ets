import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { HttpService, ApiResponse } from './HttpService';

const PREF_NAME: string = 'carbonlink_tokens';
const KEY_ACCESS_TOKEN: string = 'access_token';
const KEY_REFRESH_TOKEN: string = 'refresh_token';
const KEY_EXPIRES_IN: string = 'expires_in';
const KEY_SAVED_AT: string = 'token_saved_at';
const KEY_USER_INFO: string = 'user_info';

export class TokenManager {
  private static context: common.UIAbilityContext | null = null;
  private static pref: preferences.Preferences | null = null;

  static async init(context: common.UIAbilityContext): Promise<void> {
    TokenManager.context = context;
    try {
      TokenManager.pref = await preferences.getPreferences(context, PREF_NAME);
    } catch (err) {
      console.error(`[TokenManager] init failed: ${(err as Error).message}`);
    }
  }

  static async saveTokens(accessToken: string, refreshToken: string, expiresIn: number): Promise<void> {
    if (TokenManager.pref === null) {
      return;
    }
    await TokenManager.pref.put(KEY_ACCESS_TOKEN, accessToken);
    await TokenManager.pref.put(KEY_REFRESH_TOKEN, refreshToken);
    await TokenManager.pref.put(KEY_EXPIRES_IN, expiresIn.toString());
    await TokenManager.pref.put(KEY_SAVED_AT, Date.now().toString());
    await TokenManager.pref.flush();
  }

  static async getAccessToken(): Promise<string> {
    if (TokenManager.pref === null) {
      return '';
    }
    const token: string = (await TokenManager.pref.get(KEY_ACCESS_TOKEN, '')) as string;
    return token;
  }

  static async getRefreshToken(): Promise<string> {
    if (TokenManager.pref === null) {
      return '';
    }
    const token: string = (await TokenManager.pref.get(KEY_REFRESH_TOKEN, '')) as string;
    return token;
  }

  static async isTokenValid(): Promise<boolean> {
    if (TokenManager.pref === null) {
      return false;
    }
    const accessToken: string = (await TokenManager.pref.get(KEY_ACCESS_TOKEN, '')) as string;
    if (accessToken.length === 0) {
      return false;
    }
    const expiresInStr: string = (await TokenManager.pref.get(KEY_EXPIRES_IN, '0')) as string;
    const savedAtStr: string = (await TokenManager.pref.get(KEY_SAVED_AT, '0')) as string;
    const expiresIn: number = parseInt(expiresInStr, 10);
    const savedAt: number = parseInt(savedAtStr, 10);
    if (isNaN(expiresIn) || isNaN(savedAt)) {
      return false;
    }
    const expireTime: number = savedAt + expiresIn * 1000;
    const bufferMs: number = 60 * 1000;
    return Date.now() < expireTime - bufferMs;
  }

  static async refreshToken(): Promise<boolean> {
    const refreshToken: string = await TokenManager.getRefreshToken();
    if (refreshToken.length === 0) {
      return false;
    }

    const refreshTokenSavedAtStr: string = TokenManager.pref !== null
      ? (await TokenManager.pref.get(KEY_SAVED_AT, '0')) as string : '0';
    const refreshTokenSavedAt: number = parseInt(refreshTokenSavedAtStr, 10);
    const refreshExpireTime: number = refreshTokenSavedAt + 7 * 24 * 60 * 60 * 1000;
    if (Date.now() >= refreshExpireTime) {
      return false;
    }

    try {
      const reqBody: Record<string, string> = { 'refreshToken': refreshToken };
      const response: ApiResponse = await HttpService.POST('/refresh', reqBody);
      if (response.code === 0 && response.data !== null) {
        const tokenData: Record<string, string | number | object> = response.data;
        const token: string = tokenData['token'] as string;
        const newRefreshToken: string = tokenData['refreshToken'] as string;
        const eiVal = tokenData['expiresIn'];
        const expiresIn: number = typeof eiVal === 'number' ? eiVal : 7200;
        await TokenManager.saveTokens(token, newRefreshToken, expiresIn);
        return true;
      }
      return false;
    } catch (err) {
      console.error(`[TokenManager] refreshToken failed: ${(err as Error).message}`);
      return false;
    }
  }

  static async clearTokens(): Promise<void> {
    if (TokenManager.pref === null) {
      return;
    }
    await TokenManager.pref.delete(KEY_ACCESS_TOKEN);
    await TokenManager.pref.delete(KEY_REFRESH_TOKEN);
    await TokenManager.pref.delete(KEY_EXPIRES_IN);
    await TokenManager.pref.delete(KEY_SAVED_AT);
    await TokenManager.pref.delete(KEY_USER_INFO);
    await TokenManager.pref.flush();
  }

  static async saveUserInfo(userInfo: string): Promise<void> {
    if (TokenManager.pref === null) {
      return;
    }
    await TokenManager.pref.put(KEY_USER_INFO, userInfo);
    await TokenManager.pref.flush();
  }

  static async getUserInfo(): Promise<string> {
    if (TokenManager.pref === null) {
      return '';
    }
    const info: string = (await TokenManager.pref.get(KEY_USER_INFO, '')) as string;
    return info;
  }
}
