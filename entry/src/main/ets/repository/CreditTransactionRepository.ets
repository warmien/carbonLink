import { CreditTransaction, CreditTransactionType } from '../models/CreditTransaction';
import { HttpService } from '../services/HttpService';

class TransactionListResult {
  list: CreditTransaction[] = [];
  total: number = 0;
}

function toNum(val: string | number | boolean | object | undefined): number {
  if (typeof val === 'number') return val;
  if (typeof val === 'string') {
    const n = parseFloat(val);
    return isNaN(n) ? 0 : n;
  }
  return 0;
}

function toStr(val: string | number | boolean | object | undefined): string {
  if (typeof val === 'string') return val;
  if (typeof val === 'number') return val.toString();
  return '';
}

function toTxType(val: string | number | boolean | object | undefined): CreditTransactionType {
  if (typeof val === 'string') {
    if (val === 'TRADE_REWARD') return CreditTransactionType.TRADE_REWARD;
    if (val === 'PUBLISH_REWARD') return CreditTransactionType.PUBLISH_REWARD;
    if (val === 'ACHIEVEMENT_REWARD') return CreditTransactionType.ACHIEVEMENT_REWARD;
    if (val === 'DONATION_REWARD') return CreditTransactionType.DONATION_REWARD;
    if (val === 'REFORM_REWARD') return CreditTransactionType.REFORM_REWARD;
    if (val === 'TRANSFER_IN') return CreditTransactionType.TRANSFER_IN;
    if (val === 'TRANSFER_OUT') return CreditTransactionType.TRANSFER_OUT;
    if (val === 'TRANSFER_FEE') return CreditTransactionType.TRANSFER_FEE;
    if (val === 'EXCHANGE_DEDUCT') return CreditTransactionType.EXCHANGE_DEDUCT;
    if (val === 'EXPIRE_CLEAR') return CreditTransactionType.EXPIRE_CLEAR;
    if (val === 'VIOLATION_DEDUCT') return CreditTransactionType.VIOLATION_DEDUCT;
  }
  return CreditTransactionType.PUBLISH_REWARD;
}

function toObjArr(val: string | number | object | undefined): Record<string, string | number | object>[] {
  if (typeof val !== 'object' || val === null) {
    return [];
  }
  const arr: Record<string, string | number | object>[] = [];
  try {
    const candidate = val as Record<string, string | number | object>[];
    if (typeof candidate.length === 'number') {
      return candidate;
    }
  } catch (e) {
  }
  return arr;
}

export class CreditTransactionRepository {
  async getByUserId(userId: string, page: number, pageSize: number, typeFilter?: string): Promise<TransactionListResult> {
    try {
      let path: string = `/credits/transactions?page=${page.toString()}&pageSize=${pageSize.toString()}`;
      if (typeFilter && typeFilter !== 'all') {
        path += `&type=${typeFilter}`;
      }
      const resp = await HttpService.GET(path);
      if (resp.code === 0 && resp.data !== null) {
        const total: number = toNum(resp.data['total']);
        const listData = toObjArr(resp.data['list']);
        const list: CreditTransaction[] = [];
        for (let i = 0; i < listData.length; i++) {
          const item = listData[i];
          const tx = new CreditTransaction();
          tx.id = toStr(item['id']);
          tx.userId = toStr(item['user_id']);
          tx.type = toTxType(item['type']);
          tx.amount = toNum(item['amount']);
          tx.balanceAfter = toNum(item['balance_after']);
          tx.relatedId = toStr(item['related_id']);
          tx.carbonReduction = toNum(item['carbon_reduction']);
          tx.timestamp = toNum(item['timestamp']);
          list.push(tx);
        }
        const result = new TransactionListResult();
        result.list = list;
        result.total = total;
        return result;
      }
    } catch (err) {
    }
    const empty = new TransactionListResult();
    return empty;
  }
}

export const creditTransactionRepository = new CreditTransactionRepository();
