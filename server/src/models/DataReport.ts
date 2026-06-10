export enum ReportType {
  USER_GROWTH = 'USER_GROWTH',
  TRANSACTION = 'TRANSACTION',
  CREDIT = 'CREDIT',
  PRODUCT = 'PRODUCT'
}

export enum DataGranularity {
  HOURLY = 'HOURLY',
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY'
}

export interface DataReport {
  reportType: ReportType;
  timeRange: string;
  granularity: DataGranularity;
  data: Record<string, unknown>[];
  generatedAt: number;
}