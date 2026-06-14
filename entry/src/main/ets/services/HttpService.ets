import { http } from '@kit.NetworkKit';
import { router } from '@kit.ArkUI';
import { TokenManager } from './TokenManager';

export interface ApiResponse {
  code: number;
  message: string;
  data: Record<string, string | number | object> | null;
}

export class HttpService {
  private static readonly BASE_URL: string = 'http://192.168.10.55:3001/api/v1';
  private static readonly CONNECT_TIMEOUT: number = 10000;
  private static readonly READ_TIMEOUT: number = 30000;
  private static isRefreshing: boolean = false;

  static async request(method: http.RequestMethod, path: string,
    data?: Record<string, string | number | object>,
    extraHeaders?: Record<string, string>): Promise<ApiResponse> {
    const httpRequest = http.createHttp();
    const url: string = `${HttpService.BASE_URL}${path}`;

    const header: Record<string, string> = {
      'Content-Type': 'application/json'
    };

    const accessToken: string = await TokenManager.getAccessToken();
    if (accessToken.length > 0) {
      header['Authorization'] = `Bearer ${accessToken}`;
    }



    const options: http.HttpRequestOptions = {
      method: method,
      header: header,
      connectTimeout: HttpService.CONNECT_TIMEOUT,
      readTimeout: HttpService.READ_TIMEOUT
    };

    if (data !== undefined) {
      options.extraData = JSON.stringify(data);
    }

    try {
      const response: http.HttpResponse = await httpRequest.request(url, options);
      const responseCode: number = response.responseCode;

      if (responseCode === 401) {
        const refreshed: boolean = await HttpService.handleTokenExpired();
        if (refreshed) {
          httpRequest.destroy();
          return HttpService.request(method, path, data, extraHeaders);
        }
        await TokenManager.clearTokens();
        AppStorage.setOrCreate('isLoggedIn', false);
        router.replaceUrl({ url: 'pages/LoginPage' }).catch(() => {});
        httpRequest.destroy();
        const errResp: ApiResponse = { code: 40101, message: '登录已过期，请重新登录', data: null };
        return errResp;
      }

      const result: string = response.result as string;
      const parsed: ApiResponse = JSON.parse(result) as ApiResponse;
      httpRequest.destroy();
      return parsed;
    } catch (err) {
      httpRequest.destroy();
      const errMsg: string = (err as Error).message;
      const errResp: ApiResponse = { code: 50001, message: `网络请求失败: ${errMsg}`, data: null };
      return errResp;
    }
  }

  static async GET(path: string, extraHeaders?: Record<string, string>): Promise<ApiResponse> {
    return HttpService.request(http.RequestMethod.GET, path, undefined, extraHeaders);
  }

  static async POST(path: string, data?: Record<string, string | number | object>,
    extraHeaders?: Record<string, string>): Promise<ApiResponse> {
    return HttpService.request(http.RequestMethod.POST, path, data, extraHeaders);
  }

  static async PUT(path: string, data?: Record<string, string | number | object>,
    extraHeaders?: Record<string, string>): Promise<ApiResponse> {
    return HttpService.request(http.RequestMethod.PUT, path, data, extraHeaders);
  }

  static async DELETE(path: string, extraHeaders?: Record<string, string>): Promise<ApiResponse> {
    return HttpService.request(http.RequestMethod.DELETE, path, undefined, extraHeaders);
  }

  private static async handleTokenExpired(): Promise<boolean> {
    if (HttpService.isRefreshing) {
      return false;
    }
    HttpService.isRefreshing = true;
    try {
      const refreshed: boolean = await TokenManager.refreshToken();
      HttpService.isRefreshing = false;
      return refreshed;
    } catch (err) {
      HttpService.isRefreshing = false;
      return false;
    }
  }
}
