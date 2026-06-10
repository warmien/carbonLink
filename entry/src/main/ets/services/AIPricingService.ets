import { http } from '@kit.NetworkKit';
import { ApiServiceEndpoint } from '../models/AiServiceConfig';
import { PricingResult } from '../models/PricingResult';
import { JsonPathResolver } from '../utils/JsonPathResolver';

export class AIPricingService {
  private static currentRequest: http.HttpRequest | null = null;

  static async pricing(title: string, category: string, condition: string, brand: string,
    config: ApiServiceEndpoint): Promise<PricingResult> {
    const result = new PricingResult();
    if (!config.apiUrl) {
      result.errorMessage = '未配置AI估价服务';
      return result;
    }
    try {
      let bodyStr = config.bodyTemplate;
      bodyStr = bodyStr.replace(/\{\{title\}\}/g, title);
      bodyStr = bodyStr.replace(/\{\{category\}\}/g, category);
      bodyStr = bodyStr.replace(/\{\{condition\}\}/g, condition);
      bodyStr = bodyStr.replace(/\{\{brand\}\}/g, brand);

      const headers = AIPricingService.buildHeaders(config);
      const httpRequest = http.createHttp();
      AIPricingService.currentRequest = httpRequest;

      const response = await httpRequest.request(config.apiUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: bodyStr,
        connectTimeout: config.timeout,
        readTimeout: config.timeout,
      });
      AIPricingService.currentRequest = null;

      if (response.responseCode !== 200) {
        result.errorMessage = `请求失败: ${response.responseCode}`;
        return result;
      }

      let responseData: object;
      if (response.result !== null && response.result !== undefined) {
        const resultStr = response.result as string;
        try {
          responseData = JSON.parse(resultStr) as object;
        } catch (parseErr) {
          responseData = response.result as object;
        }
      } else {
        result.errorMessage = '响应内容为空';
        return result;
      }

      const contentStr = JsonPathResolver.resolve(responseData, 'choices.0.message.content');
      let resolvedData: object = responseData;
      if (contentStr) {
        try {
          resolvedData = JSON.parse(contentStr) as object;
        } catch (parseErr) {
        }
      }

      const paths = config.responsePaths ? config.responsePaths.split(',') : [];
      const suggestedPrice = JsonPathResolver.resolve(resolvedData, paths[0] || 'suggestedPrice');
      const minPrice = JsonPathResolver.resolve(resolvedData, paths[1] || 'minPrice');
      const maxPrice = JsonPathResolver.resolve(resolvedData, paths[2] || 'maxPrice');
      const reasoning = JsonPathResolver.resolve(resolvedData, paths[3] || 'reasoning');

      if (suggestedPrice) result.suggestedPrice = parseFloat(suggestedPrice);
      if (minPrice) result.minPrice = parseFloat(minPrice);
      if (maxPrice) result.maxPrice = parseFloat(maxPrice);
      if (reasoning) result.reasoning = reasoning;
      result.success = true;
      return result;
    } catch (e) {
      AIPricingService.currentRequest = null;
      result.errorMessage = `估价异常: ${(e as Error).message}`;
      return result;
    }
  }

  static cancelPricing(): void {
    if (AIPricingService.currentRequest) {
      AIPricingService.currentRequest.destroy();
      AIPricingService.currentRequest = null;
    }
  }

  private static buildHeaders(config: ApiServiceEndpoint): Record<string, string> {
    const headers: Record<string, string> = { 'Content-Type': 'application/json' };

    if (config.authToken) headers['Authorization'] = 'Bearer ' + config.authToken;
    return headers;
  }
}