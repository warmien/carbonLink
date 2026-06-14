import { http } from '@kit.NetworkKit';
import { ApiServiceEndpoint } from '../models/AiServiceConfig';
import { SemanticSearchResult } from '../models/SemanticSearchResult';
import { JsonPathResolver } from '../utils/JsonPathResolver';
import { productRepository } from '../repository/ProductRepository';

export class AISearchService {
  private static currentRequest: http.HttpRequest | null = null;

  static async semanticSearch(keyword: string, config: ApiServiceEndpoint): Promise<SemanticSearchResult> {
    const result: SemanticSearchResult = new SemanticSearchResult();
    if (!config.apiUrl) {
      return AISearchService.doFallbackSearch(keyword, result);
    }
    try {
      let bodyStr: string = config.bodyTemplate;
      bodyStr = bodyStr.replace(/\{\{keyword\}\}/g, keyword);

      const headers: Record<string, string> = { 'Content-Type': 'application/json' };
      if (config.authToken) headers['Authorization'] = 'Bearer ' + config.authToken;

      const httpRequest: http.HttpRequest = http.createHttp();
      AISearchService.currentRequest = httpRequest;

      const response: http.HttpResponse = await httpRequest.request(config.apiUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: bodyStr,
        connectTimeout: config.timeout,
        readTimeout: config.timeout,
      });
      AISearchService.currentRequest = null;

      if (response.responseCode !== 200) {
        return AISearchService.doFallbackSearch(keyword, result);
      }

      let responseData: Record<string, string | number | boolean | object>;
      if (response.result !== null && response.result !== undefined) {
        const resultStr: string = response.result as string;
        try {
          responseData = JSON.parse(resultStr) as Record<string, string | number | boolean | object>;
        } catch (parseErr) {
          responseData = response.result as Record<string, string | number | boolean | object>;
        }
      } else {
        return AISearchService.doFallbackSearch(keyword, result);
      }

      const contentStr: string | null = JsonPathResolver.resolve(responseData, 'choices.0.message.content');
      let resolvedData: Record<string, string | number | boolean | object> = responseData;
      if (contentStr !== null && contentStr.length > 0) {
        try {
          resolvedData = JSON.parse(contentStr) as Record<string, string | number | boolean | object>;
        } catch (parseErr) {
        }
      }

      const suggestionsObj: string | number | boolean | object = resolvedData['suggestions'];
      const productIdsObj: string | number | boolean | object = resolvedData['productIds'];

      if (suggestionsObj !== null && suggestionsObj !== undefined && typeof suggestionsObj !== 'string' && typeof suggestionsObj !== 'number' && typeof suggestionsObj !== 'boolean') {
        const arr: (string | number | boolean | object)[] = suggestionsObj as (string | number | boolean | object)[];
        result.totalMatches = arr.length;
      }
      if (productIdsObj !== null && productIdsObj !== undefined && typeof productIdsObj !== 'string' && typeof productIdsObj !== 'number' && typeof productIdsObj !== 'boolean') {
        const idsArr: (string | number | boolean | object)[] = productIdsObj as (string | number | boolean | object)[];
        result.productIds = idsArr.map((item: string | number | boolean | object): string => String(item));
        result.totalMatches = idsArr.length;
        result.relevanceScores = idsArr.map((): number => 1.0);
      }
      result.success = true;
      return result;
    } catch (e) {
      AISearchService.currentRequest = null;
      return AISearchService.doFallbackSearch(keyword, result);
    }
  }

  static async searchSuggest(keyword: string, config: ApiServiceEndpoint): Promise<string[]> {
    if (!config.apiUrl) return [];
    try {
      let bodyStr: string = config.bodyTemplate.replace(/\{\{keyword\}\}/g, keyword);
      bodyStr = bodyStr.replace(/\{\{mode\}\}/g, 'suggest');

      const headers: Record<string, string> = { 'Content-Type': 'application/json' };
      if (config.authToken) headers['Authorization'] = 'Bearer ' + config.authToken;

      const httpRequest: http.HttpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(config.apiUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: bodyStr,
        connectTimeout: 5000,
        readTimeout: 5000,
      });
      httpRequest.destroy();

      if (response.responseCode !== 200) return [];
      let responseData: Record<string, string | number | boolean | object>;
      if (response.result !== null && response.result !== undefined) {
        const resultStr: string = response.result as string;
        try {
          responseData = JSON.parse(resultStr) as Record<string, string | number | boolean | object>;
        } catch (parseErr2) {
          responseData = response.result as Record<string, string | number | boolean | object>;
        }
      } else {
        return [];
      }
      const contentStr: string | null = JsonPathResolver.resolve(responseData, 'choices.0.message.content');
      if (contentStr !== null && contentStr.length > 0) {
        try {
          const contentObj: Record<string, string | number | boolean | object> = JSON.parse(contentStr) as Record<string, string | number | boolean | object>;
          const suggestionsObj: string | number | boolean | object = contentObj['suggestions'];
          if (suggestionsObj !== null && suggestionsObj !== undefined && typeof suggestionsObj !== 'string' && typeof suggestionsObj !== 'number' && typeof suggestionsObj !== 'boolean') {
            const arr: (string | number | boolean | object)[] = suggestionsObj as (string | number | boolean | object)[];
            return arr.map((item: string | number | boolean | object): string => String(item));
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
    if (AISearchService.currentRequest !== null) {
      AISearchService.currentRequest.destroy();
      AISearchService.currentRequest = null;
    }
  }

  private static async doFallbackSearch(keyword: string, result: SemanticSearchResult): Promise<SemanticSearchResult> {
    try {
      const fetchResult = await productRepository.fetchProducts('keyword=' + encodeURIComponent(keyword));
      result.productIds = fetchResult.list.map((spu): string => spu.id);
      result.relevanceScores = fetchResult.list.map((): number => 1.0);
      result.totalMatches = fetchResult.total;
      result.success = true;
      result.errorMessage = '已使用关键词搜索';
    } catch (err) {
      result.success = false;
      result.errorMessage = '搜索失败';
    }
    return result;
  }
}
