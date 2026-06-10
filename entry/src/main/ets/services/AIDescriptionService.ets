import { http } from '@kit.NetworkKit';
import { ApiServiceEndpoint } from '../models/AiServiceConfig';
import { DescriptionResult } from '../models/DescriptionResult';
import { JsonPathResolver } from '../utils/JsonPathResolver';
import { ImageUtils } from '../utils/ImageUtils';

export class AIDescriptionService {
  private static currentRequest: http.HttpRequest | null = null;

  static async generate(title: string, category: string, condition: string,
    images: string[], config: ApiServiceEndpoint): Promise<DescriptionResult> {
    const result = new DescriptionResult();
    if (!config.apiUrl) {
      result.errorMessage = '未配置AI描述生成服务';
      return result;
    }
    try {
      let bodyStr = config.bodyTemplate;
      bodyStr = bodyStr.replace(/\{\{title\}\}/g, title);
      bodyStr = bodyStr.replace(/\{\{category\}\}/g, category);
      bodyStr = bodyStr.replace(/\{\{condition\}\}/g, condition);

      if (bodyStr.includes('{{image_base64}}') && images.length > 0) {
        const base64 = await ImageUtils.imageToBase64(images[0]);
        bodyStr = bodyStr.replace(/\{\{image_base64\}\}/g, base64);
      }

      const headers: Record<string, string> = { 'Content-Type': 'application/json' };

      if (config.authToken) headers['Authorization'] = 'Bearer ' + config.authToken;

      const httpRequest = http.createHttp();
      AIDescriptionService.currentRequest = httpRequest;

      const response = await httpRequest.request(config.apiUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: bodyStr,
        connectTimeout: config.timeout,
        readTimeout: config.timeout,
      });
      AIDescriptionService.currentRequest = null;

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
      const desc = JsonPathResolver.resolve(resolvedData, paths[0] || 'description');
      const conf = JsonPathResolver.resolve(resolvedData, paths[1] || 'confidence');

      if (desc) result.description = desc.length > 500 ? desc.substring(0, 500) : desc;
      if (conf) result.confidence = Math.min(1.0, Math.max(0.0, parseFloat(conf)));
      result.success = true;
      return result;
    } catch (e) {
      AIDescriptionService.currentRequest = null;
      result.errorMessage = `描述生成异常: ${(e as Error).message}`;
      return result;
    }
  }

  static cancelGeneration(): void {
    if (AIDescriptionService.currentRequest) {
      AIDescriptionService.currentRequest.destroy();
      AIDescriptionService.currentRequest = null;
    }
  }
}