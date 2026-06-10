import { http } from '@kit.NetworkKit';
import { ApiConfig } from '../models/ApiConfig';
import { RecognitionResult } from '../models/RecognitionResult';
import { ConditionMapper } from '../utils/ConditionMapper';
import { JsonPathResolver } from '../utils/JsonPathResolver';
import { ImageUtils } from '../utils/ImageUtils';

export class AIRecognitionService {
  private static currentRequest: http.HttpRequest | null = null;

  static async recognize(imageUri: string, config: ApiConfig): Promise<RecognitionResult> {
    const result = new RecognitionResult();
    if (!config.apiUrl) {
      result.errorMessage = '未配置API地址';
      return result;
    }
    try {
      let bodyStr = config.bodyTemplate;
      if (bodyStr.includes('{{image_base64}}')) {
        const base64 = await ImageUtils.imageToBase64(imageUri);
        if (base64 === '') {
          result.errorMessage = '图片编码失败';
          return result;
        }
        bodyStr = bodyStr.replace(/\{\{image_base64\}\}/g, base64);
      }
      if (bodyStr.includes('{{image_url}}')) {
        bodyStr = bodyStr.replace(/\{\{image_url\}\}/g, imageUri);
      }

      const headers: Record<string, string> = { 'Content-Type': 'application/json' };

      if (config.authToken) {
        headers['Authorization'] = 'Bearer ' + config.authToken;
      }

      const httpRequest = http.createHttp();
      AIRecognitionService.currentRequest = httpRequest;

      const response = await httpRequest.request(config.apiUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: bodyStr,
        connectTimeout: config.timeout,
        readTimeout: config.timeout,
      });

      AIRecognitionService.currentRequest = null;

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

      const contentStr = JsonPathResolver.resolve(responseData as object, 'choices.0.message.content');
      if (contentStr) {
        try {
          const contentObj = JSON.parse(contentStr) as Record<string, Object>;
          const nameVal = contentObj['name'];
          const condVal = contentObj['condition'];
          const descVal = contentObj['description'];
          const catVal = contentObj['category'];
          const subCatVal = contentObj['subCategory'];
          const priceVal = contentObj['suggestedPrice'];
          const origPriceVal = contentObj['originalPrice'];
          if (nameVal !== null && nameVal !== undefined) result.itemName = String(nameVal);
          if (condVal !== null && condVal !== undefined) {
            result.condition = String(condVal);
            const mapped = ConditionMapper.mapCondition(String(condVal));
            if (mapped) result.mappedCondition = mapped;
          }
          if (descVal !== null && descVal !== undefined) result.description = String(descVal);
          if (catVal !== null && catVal !== undefined) result.category = String(catVal);
          if (subCatVal !== null && subCatVal !== undefined) result.subCategory = String(subCatVal);
          if (priceVal !== null && priceVal !== undefined) {
            const p = parseFloat(String(priceVal));
            if (!isNaN(p)) result.suggestedPrice = p;
          }
          if (origPriceVal !== null && origPriceVal !== undefined) {
            const op = parseFloat(String(origPriceVal));
            if (!isNaN(op)) result.originalPrice = op;
          }
        } catch (parseErr) {
          if (contentStr) result.itemName = contentStr;
        }
      } else {
        const itemName = JsonPathResolver.resolve(responseData as object, config.responseNamePath);
        const conditionDesc = JsonPathResolver.resolve(responseData as object, config.responseConditionPath);
        if (itemName) result.itemName = itemName;
        if (conditionDesc) {
          result.condition = conditionDesc;
          const mapped = ConditionMapper.mapCondition(conditionDesc);
          if (mapped) result.mappedCondition = mapped;
        }
      }
      result.success = true;
      return result;
    } catch (e) {
      AIRecognitionService.currentRequest = null;
      result.errorMessage = `识别异常: ${(e as Error).message}`;
      return result;
    }
  }

  static cancelRecognition(): void {
    if (AIRecognitionService.currentRequest) {
      AIRecognitionService.currentRequest.destroy();
      AIRecognitionService.currentRequest = null;
    }
  }
}