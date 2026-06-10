import { http } from '@kit.NetworkKit';
import { ApiServiceEndpoint } from '../models/AiServiceConfig';
import { SemanticSearchResult } from '../models/SemanticSearchResult';
import { JsonPathResolver } from '../utils/JsonPathResolver';
import { productRepository } from '../repository/ProductRepository';

export class AISearchService {
  private static currentRequest: http.HttpRequest | null = null;

  static async semanticSearch(keyword: string, config: ApiServiceEndpoint): Promise<SemanticSearchResult> {
    const result = new SemanticSearchResult();
    if (!config.apiUrl) {
      return AISearchService.fallbackSearch(keyword, result);
    }
    try {
      let bodyStr = config.bodyTemplate;
      bodyStr = bodyStr.replace(/\{\{keyword\}\}/g, keyword);

      const headers: Record<string, string> = { 'Content-Type': 'application/json' };

      if (config.authToken) headers['Authorization'] = 'Bearer ' + config.authToken;

      const httpRequest = http.createHttp();
      AISearchService.currentRequest = httpRequest;

      const response = await httpRequest.request(config.apiUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: bodyStr,
        connectTimeout: config.timeout,
        readTimeout: config.timeout,
      });
      AISearchService.currentRequest = null;

      if (response.responseCode !== 200) {
        return AISearchService.fallbackSearch(keyword, result);
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
        return AISearchService.fallbackSearch(keyword, result);
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
      const suggestionsObj = (resolvedData as Record<string, Object>)['suggestions'];
      const productIdsObj = (resolvedData as Record<string, Object>)['productIds'];

      if (Array.isArray(suggestionsObj)) {
        result.totalMatches = (suggestionsObj as Object[]).length;
      }
      if (Array.isArray(productIdsObj)) {
        const idsArr = productIdsObj as Object[];
        result.productIds = idsArr.map((item: Object): string => String(item));
        result.totalMatches = idsArr.length;
        result.relevanceScores = idsArr.map(() => 1.0);
      }
      result.success = true;
      return result;
    } catch (e) {
      AISearchService.currentRequest = null;
      return AISearchService.fallbackSearch(keyword, result);
    }
  }

  static async searchSuggest(keyword: string, config: ApiServiceEndpoint): Promise<string[]> {
    if (!config.apiUrl) return [];
    try {
      let bodyStr = config.bodyTemplate.replace(/\{\{keyword\}\}/g, keyword);
      bodyStr = bodyStr.replace(/\{\{mode\}\}/g, 'suggest');

      const headers: Record<string, string> = { 'Content-Type': 'application/json' };
      if (config.authToken) headers['Authorization'] = 'Bearer ' + config.authToken;

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(config.apiUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: bodyStr,
        connectTimeout: 5000,
        readTimeout: 5000,
      });
      httpRequest.destroy();

      if (response.responseCode !== 200) return [];
      let responseData: object;
      if (response.result !== null && response.result !== undefined) {
        const resultStr = response.result as string;
        try {
          responseData = JSON.parse(resultStr) as object;
        } catch (parseErr2) {
          responseData = response.result as object;
        }
      } else {
        return [];
      }
      const contentStr = JsonPathResolver.resolve(responseData, 'choices.0.message.content');
      if (contentStr) {
        try {
          const contentObj = JSON.parse(contentStr) as Record<string, Object>;
          const suggestionsObj = contentObj['suggestions'];
          if (Array.isArray(suggestionsObj)) {
            return suggestionsObj as string[];
          }
        } catch (parseErr) {
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static cancelSearch(): void {
    if (AISearchService.currentRequest) {
      AISearchService.currentRequest.destroy();
      AISearchService.currentRequest = null;
    }
  }

  private static fallbackSearch(keyword: string, result: SemanticSearchResult): SemanticSearchResult {
    const products = productRepository.searchProducts(keyword);
    result.productIds = products.map(p => p.id);
    result.relevanceScores = products.map(() => 1.0);
    result.totalMatches = products.length;
    result.success = true;
    result.errorMessage = '已使用关键词搜索';
    return result;
  }
}