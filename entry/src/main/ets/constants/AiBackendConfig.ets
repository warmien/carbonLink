import { ApiConfig } from '../models/ApiConfig';
import { AiServiceConfig, ApiServiceEndpoint } from '../models/AiServiceConfig';

export enum AiProvider {
  DASHSCOPE = 'DASHSCOPE',
  DOUBAO = 'DOUBAO'
}

export class AiBackendConfig {
  static readonly DASHSCOPE_API_URL: string = 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions';
  static readonly DASHSCOPE_API_KEY: string = 'sk-17a83917208a4911b6acfedf00102d6c';
  static readonly DASHSCOPE_MODEL: string = 'qwen-plus';

  static readonly DOUBAO_API_URL: string = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';
  static readonly DOUBAO_API_KEY: string = 'ark-47c6de9a-e87a-431c-b312-4f67403c68eb-7f3d8';
  static readonly DOUBAO_MODEL: string = 'doubao-seed-2-0-mini-260428';

  static currentProvider: AiProvider = AiProvider.DOUBAO;

  static getApiUrl(): string {
    if (AiBackendConfig.currentProvider === AiProvider.DOUBAO) {
      return AiBackendConfig.DOUBAO_API_URL;
    }
    return AiBackendConfig.DASHSCOPE_API_URL;
  }

  static getApiKey(): string {
    if (AiBackendConfig.currentProvider === AiProvider.DOUBAO) {
      return AiBackendConfig.DOUBAO_API_KEY;
    }
    return AiBackendConfig.DASHSCOPE_API_KEY;
  }

  static getModel(): string {
    if (AiBackendConfig.currentProvider === AiProvider.DOUBAO) {
      return AiBackendConfig.DOUBAO_MODEL;
    }
    return AiBackendConfig.DASHSCOPE_MODEL;
  }


  static getRecognitionConfig(): ApiConfig {
    const config = new ApiConfig();
    config.apiUrl = AiBackendConfig.getApiUrl();
    config.authToken = AiBackendConfig.getApiKey();
    config.timeout = 30000;
    config.headers = '{}';
    config.bodyTemplate = '{"model":"' + AiBackendConfig.getModel() + '","messages":[{"role":"system","content":"你是二手商品识别专家。根据图片识别商品，返回JSON格式，包含name和condition两个字段。name为具体商品名称（如iPhone 15 Pro、戴森吹风机、宜家书架），condition为成色描述（如全新、9成新、8成新、轻微使用痕迹、明显使用痕迹）。请尽量准确识别品牌和型号。"},{"role":"user","content":[{"type":"text","text":"请识别这张图片中的二手商品"},{"type":"image_url","image_url":{"url":"data:image/jpeg;base64,{{image_base64}}"}}]}],"response_format":{"type":"json_object"}}';
    config.responseNamePath = 'choices.0.message.content';
    config.responseConditionPath = 'choices.0.message.content';
    return config;
  }

  static getPricingConfig(): ApiServiceEndpoint {
    const config = new ApiServiceEndpoint();
    config.apiUrl = AiBackendConfig.getApiUrl();
    config.authToken = AiBackendConfig.getApiKey();
    config.timeout = 30000;
    config.headers = '{}';
    config.bodyTemplate = '{"model":"' + AiBackendConfig.getModel() + '","messages":[{"role":"system","content":"你是二手商品估价专家。根据商品名称、分类和成色给出合理估价，返回JSON格式，包含suggestedPrice(建议价，数字)、minPrice(最低价，数字)、maxPrice(最高价，数字)、reasoning(估价理由，简短说明)四个字段。价格单位为人民币元。"},{"role":"user","content":"请对以下二手商品估价：商品名称：{{title}}，分类：{{category}}，成色：{{condition}}"}],"response_format":{"type":"json_object"}}';
    config.responsePaths = 'suggestedPrice,minPrice,maxPrice,reasoning';
    return config;
  }

  static getDescriptionConfig(): ApiServiceEndpoint {
    const config = new ApiServiceEndpoint();
    config.apiUrl = AiBackendConfig.getApiUrl();
    config.authToken = AiBackendConfig.getApiKey();
    config.timeout = 30000;
    config.headers = '{}';
    config.bodyTemplate = '{"model":"' + AiBackendConfig.getModel() + '","messages":[{"role":"system","content":"你是二手商品描述撰写专家。生成吸引人且真实的商品描述，突出商品亮点和使用情况，返回JSON格式，包含description(商品描述文本)和confidence(置信度0-1)两个字段。描述200字以内。"},{"role":"user","content":"请为以下二手商品生成描述：商品名称：{{title}}，分类：{{category}}，成色：{{condition}}"}],"response_format":{"type":"json_object"}}';
    config.responsePaths = 'description,confidence';
    return config;
  }

  static getSearchConfig(): ApiServiceEndpoint {
    const config = new ApiServiceEndpoint();
    config.apiUrl = AiBackendConfig.getApiUrl();
    config.authToken = AiBackendConfig.getApiKey();
    config.timeout = 30000;
    config.headers = '{}';
    config.bodyTemplate = '{"model":"' + AiBackendConfig.getModel() + '","messages":[{"role":"system","content":"你是二手商品搜索助手。根据用户搜索词推荐5个相关搜索关键词，返回JSON格式，包含suggestions(字符串数组，最多5个相关关键词)和productIds(空数组)两个字段。"},{"role":"user","content":"用户搜索：{{keyword}}"}],"response_format":{"type":"json_object"}}';
    config.responsePaths = 'suggestions,productIds';
    return config;
  }
}
