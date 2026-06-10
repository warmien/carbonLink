import { CreditAccount, UserLevel } from '../models/CreditAccount';
import { CreditRules } from '../config/CreditRules';

export class CreditAccountRepository {
  private accounts: Map<string, CreditAccount> = new Map();

  getOrCreate(userId: string): CreditAccount {
    let account = this.accounts.get(userId);
    if (!account) {
      account = new CreditAccount();
      account.userId = userId;
      account.balance = 0;
      account.totalEarned = 0;
      account.totalSpent = 0;
      account.level = UserLevel.BEGINNER;
      account.createdAt = Date.now();
      this.accounts.set(userId, account);
    }
    return account;
  }

  updateBalance(userId: string, delta: number): CreditAccount {
    const account = this.getOrCreate(userId);
    if (delta > 0) {
      account.balance += delta;
      account.totalEarned += delta;
    } else {
      const deductAmount = Math.abs(delta);
      if (account.balance < deductAmount) {
        return account;
      }
      account.balance -= deductAmount;
      account.totalSpent += deductAmount;
    }
    this.accounts.set(userId, account);
    return account;
  }

  updateLevel(userId: string, totalEarned: number): UserLevel {
    const account = this.getOrCreate(userId);
    const newLevel = CreditRules.getLevelByTotalEarned(totalEarned);
    const oldLevel = account.level;
    const oldIndex = this.findLevelIndex(oldLevel);
    const newIndex = this.findLevelIndex(newLevel);
    if (newIndex > oldIndex) {
      account.level = newLevel;
      this.accounts.set(userId, account);
    }
    return account.level;
  }

  getBalance(userId: string): number {
    const account = this.accounts.get(userId);
    return account ? account.balance : 0;
  }

  private findLevelIndex(level: UserLevel): number {
    const thresholds = CreditRules.LEVEL_THRESHOLDS;
    for (let i = 0; i < thresholds.length; i++) {
      if (thresholds[i].level === level) {
        return i;
      }
    }
    return 0;
  }
}

export const creditAccountRepository = new CreditAccountRepository();
