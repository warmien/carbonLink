export class ApiServiceEndpoint {
  apiUrl: string = '';
  headers: string = '';
  bodyTemplate: string = '';
  authToken: string = '';
  timeout: number = 30000;
  responsePaths: string = '';
  maxCompletionTokens: number = 0;
  reasoningEffort: string = '';
}

export class AiServiceConfig {
  pricingConfig: ApiServiceEndpoint = new ApiServiceEndpoint();
  descriptionConfig: ApiServiceEndpoint = new ApiServiceEndpoint();
  searchConfig: ApiServiceEndpoint = new ApiServiceEndpoint();
  sharedConfig: boolean = true;
}