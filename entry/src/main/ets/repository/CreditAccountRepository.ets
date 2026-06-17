import { CreditAccount, UserLevel } from '../models/CreditAccount';
import { HttpService } from '../services/HttpService';

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

function toLevel(val: string | number | boolean | object | undefined): UserLevel {
  if (typeof val === 'string') {
    if (val === '环保新手') return UserLevel.BEGINNER;
    if (val === '环保达人') return UserLevel.MASTER;
    if (val === '环保先锋') return UserLevel.PIONEER;
    if (val === '环保卫士') return UserLevel.GUARDIAN;
    if (val === '环保英雄') return UserLevel.HERO;
  }
  return UserLevel.BEGINNER;
}

export class CreditAccountRepository {
  async getAccount(userId: string): Promise<CreditAccount> {
    try {
      const resp = await HttpService.GET('/credits/account');
      if (resp.code === 0 && resp.data !== null) {
        const account = new CreditAccount();
        account.userId = userId;
        account.balance = toNum(resp.data['balance']);
        account.totalEarned = toNum(resp.data['totalEarned']);
        account.totalSpent = toNum(resp.data['totalSpent']);
        account.level = toLevel(resp.data['level']);
        return account;
      }
    } catch (err) {
    }
    const account = new CreditAccount();
    account.userId = userId;
    return account;
  }

  async getBalance(userId: string): Promise<number> {
    const account = await this.getAccount(userId);
    return account.balance;
  }

  async getStats(userId: string): Promise<Record<string, string | number | object>> {
    try {
      const resp = await HttpService.GET('/credits/stats');
      if (resp.code === 0 && resp.data !== null) {
        return resp.data;
      }
    } catch (err) {
    }
    const empty: Record<string, string | number | object> = {};
    return empty;
  }
}

export const creditAccountRepository = new CreditAccountRepository();
