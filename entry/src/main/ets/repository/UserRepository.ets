import { User } from '../models/User';
import { MockUsers } from '../mock/MockUsers';
import { HttpService, ApiResponse } from '../services/HttpService';
import { AuthManager } from '../services/AuthManager';

export class UserRepository {
  getCurrentUser(): User {
    return MockUsers.getCurrentUser();
  }

  updateCurrentUser(user: User): void {
    MockUsers.updateCurrentUser(user);
  }

  getFavoriteIds(): string[] {
    return MockUsers.getFavoriteIds();
  }

  toggleFavoriteId(productId: string, isFavorited: boolean): void {
    MockUsers.toggleFavoriteId(productId, isFavorited);
  }

  async login(phone: string, password: string, captchaKey: string, captchaValue: string): Promise<ApiResponse> {
    return await AuthManager.login(phone, password, captchaKey, captchaValue);
  }

  async register(phone: string, password: string, captchaKey: string, captchaValue: string): Promise<ApiResponse> {
    return await AuthManager.register(phone, password, captchaKey, captchaValue);
  }

  async logout(): Promise<void> {
    await AuthManager.logout();
  }

  async refreshToken(refreshToken: string): Promise<ApiResponse> {
    const reqBody: Record<string, string> = { 'refreshToken': refreshToken };
    return await HttpService.POST('/refresh', reqBody);
  }

  async getProfile(): Promise<ApiResponse> {
    return await HttpService.GET('/profile');
  }

  async updateProfile(data: Record<string, string | number | object>): Promise<ApiResponse> {
    return await HttpService.PUT('/profile', data);
  }

  async changePassword(oldPassword: string, newPassword: string): Promise<ApiResponse> {
    const reqBody: Record<string, string> = {
      'oldPassword': oldPassword,
      'newPassword': newPassword
    };
    return await HttpService.PUT('/password', reqBody);
  }
}

export const userRepository = new UserRepository();
