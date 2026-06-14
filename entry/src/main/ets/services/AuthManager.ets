import { HttpService, ApiResponse } from './HttpService';
import { TokenManager } from './TokenManager';
import { User } from '../models/User';
import { router } from '@kit.ArkUI';

export class AuthManager {
  static async login(phone: string, password: string, captchaKey: string,
    captchaValue: string): Promise<ApiResponse> {
    const reqBody: Record<string, string> = {
      'phone': phone,
      'password': password,
      'captchaKey': captchaKey,
      'captchaValue': captchaValue
    };
    const response: ApiResponse = await HttpService.POST('/login', reqBody);

    if (response.code === 0 && response.data !== null) {
      await AuthManager.handleAuthSuccess(response.data);
    }
    return response;
  }

  static async register(phone: string, password: string, captchaKey: string,
    captchaValue: string): Promise<ApiResponse> {
    const reqBody: Record<string, string> = {
      'phone': phone,
      'password': password,
      'captchaKey': captchaKey,
      'captchaValue': captchaValue
    };
    const response: ApiResponse = await HttpService.POST('/register', reqBody);

    if (response.code === 0 && response.data !== null) {
      await AuthManager.handleAuthSuccess(response.data);
    }
    return response;
  }

  static async logout(): Promise<void> {
    try {
      await HttpService.POST('/logout');
    } catch (err) {
      console.error(`[AuthManager] logout API failed: ${(err as Error).message}`);
    }
    await TokenManager.clearTokens();
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('currentUser', '');
    router.replaceUrl({ url: 'pages/LoginPage' }).catch(() => {});
  }

  static async checkAuthOnStartup(): Promise<boolean> {
    const isValid: boolean = await TokenManager.isTokenValid();
    if (isValid) {
      const accessToken: string = await TokenManager.getAccessToken();
      if (accessToken.length > 0) {
        AppStorage.setOrCreate('isLoggedIn', true);
        const cachedUser: string = await TokenManager.getUserInfo();
        if (cachedUser.length > 0) {
          AppStorage.setOrCreate('currentUser', cachedUser);
        }
        await AuthManager.fetchUserProfile();
        return true;
      }
    }

    const refreshToken: string = await TokenManager.getRefreshToken();
    if (refreshToken.length > 0) {
      const refreshed: boolean = await TokenManager.refreshToken();
      if (refreshed) {
        AppStorage.setOrCreate('isLoggedIn', true);
        const cachedUser: string = await TokenManager.getUserInfo();
        if (cachedUser.length > 0) {
          AppStorage.setOrCreate('currentUser', cachedUser);
        }
        await AuthManager.fetchUserProfile();
        return true;
      }

      const cachedUser: string = await TokenManager.getUserInfo();
      if (cachedUser.length > 0) {
        AppStorage.setOrCreate('isLoggedIn', true);
        AppStorage.setOrCreate('currentUser', cachedUser);
        return true;
      }
    }

    AppStorage.setOrCreate('isLoggedIn', false);
    return false;
  }

  static async getCurrentUser(): Promise<User | null> {
    const userJson: string = AppStorage.get<string>('currentUser') || '';
    if (userJson.length === 0) {
      return null;
    }
    try {
      const userObj: Record<string, string | number> = JSON.parse(userJson) as Record<string, string | number>;
      const user: User = new User();
      user.id = userObj['id'] as string;
      user.nickname = userObj['nickname'] as string;
      user.avatar = userObj['avatar'] as string;
      user.phone = userObj['phone'] as string;
      user.gender = userObj['gender'] as string;
      user.bio = userObj['bio'] as string;
      const cs = userObj['creditScore'];
      user.creditScore = typeof cs === 'number' ? cs : 0;
      user.creditLevel = userObj['creditLevel'] as string;
      const pc = userObj['productCount'];
      user.productCount = typeof pc === 'number' ? pc : 0;
      const sc = userObj['soldCount'];
      user.soldCount = typeof sc === 'number' ? sc : 0;
      const fc = userObj['followerCount'];
      user.followerCount = typeof fc === 'number' ? fc : 0;
      const fgc = userObj['followingCount'];
      user.followingCount = typeof fgc === 'number' ? fgc : 0;
      user.joinDate = userObj['joinDate'] as string;
      user.location = userObj['location'] as string;
      return user;
    } catch (err) {
      return null;
    }
  }

  static async updateUserProfile(user: User): Promise<void> {
    const userObj: Record<string, string | number> = {
      'id': user.id,
      'nickname': user.nickname,
      'avatar': user.avatar,
      'phone': user.phone,
      'gender': user.gender,
      'bio': user.bio,
      'creditScore': user.creditScore,
      'creditLevel': user.creditLevel,
      'productCount': user.productCount,
      'soldCount': user.soldCount,
      'followerCount': user.followerCount,
      'followingCount': user.followingCount,
      'joinDate': user.joinDate,
      'location': user.location
    };
    AppStorage.setOrCreate('currentUser', JSON.stringify(userObj));
  }

  private static async handleAuthSuccess(data: Record<string, string | number | object>): Promise<void> {
    let accessToken: string = '';
    let refreshToken: string = '';
    let expiresIn: number = 7200;

    if (data['token'] !== undefined) {
      accessToken = data['token'] as string;
      refreshToken = data['refreshToken'] as string;
      const ei = data['expiresIn'];
      expiresIn = typeof ei === 'number' ? ei : 7200;
    }

    await TokenManager.saveTokens(accessToken, refreshToken, expiresIn);

    if (data['user'] !== undefined) {
      const userObj: Record<string, string | number> = data['user'] as Record<string, string | number>;
      const userJson: string = JSON.stringify(userObj);
      AppStorage.setOrCreate('currentUser', userJson);
      TokenManager.saveUserInfo(userJson);
    }

    AppStorage.setOrCreate('isLoggedIn', true);
  }

  private static async fetchUserProfile(): Promise<void> {
    try {
      const response: ApiResponse = await HttpService.GET('/profile');
      if (response.code === 0 && response.data !== null) {
        const userObj: Record<string, string | number> = response.data as Record<string, string | number>;
        const userJson: string = JSON.stringify(userObj);
        AppStorage.setOrCreate('currentUser', userJson);
        TokenManager.saveUserInfo(userJson);
      }
    } catch (err) {
      console.error(`[AuthManager] fetchUserProfile failed: ${(err as Error).message}`);
    }
  }
}
