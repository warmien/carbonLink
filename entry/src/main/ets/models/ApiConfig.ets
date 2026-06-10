export class ApiConfig {
  apiUrl: string = '';
  method: string = 'POST';
  headers: string = '';
  bodyTemplate: string = '';
  authToken: string = '';
  timeout: number = 30000;
  responseNamePath: string = 'data.result.name';
  responseConditionPath: string = 'data.result.condition';
  maxCompletionTokens: number = 0;
  reasoningEffort: string = '';
}