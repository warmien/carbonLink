import { ExchangeRecord } from '../models/ExchangeRecord';

export class ExchangeRecordRepository {
  private records: ExchangeRecord[] = [];

  add(record: ExchangeRecord): void {
    this.records.push(record);
  }

  getByUserId(userId: string): ExchangeRecord[] {
    return this.records
      .filter((r: ExchangeRecord): boolean => r.userId === userId)
      .sort((a: ExchangeRecord, b: ExchangeRecord): number => b.timestamp - a.timestamp);
  }
}

export const exchangeRecordRepository = new ExchangeRecordRepository();