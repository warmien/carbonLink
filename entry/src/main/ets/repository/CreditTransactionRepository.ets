import { CreditTransaction, CreditTransactionType } from '../models/CreditTransaction';

export class CreditTransactionRepository {
  private transactions: CreditTransaction[] = [];

  add(transaction: CreditTransaction): void {
    this.transactions.push(transaction);
  }

  getByUserId(userId: string, page: number, pageSize: number, typeFilter?: string): CreditTransaction[] {
    let filtered = this.transactions.filter((t: CreditTransaction): boolean => t.userId === userId);
    if (typeFilter && typeFilter !== 'all') {
      if (typeFilter === 'income') {
        filtered = filtered.filter((t: CreditTransaction): boolean =>
          t.type === CreditTransactionType.TRADE_REWARD ||
          t.type === CreditTransactionType.PUBLISH_REWARD ||
          t.type === CreditTransactionType.ACHIEVEMENT_REWARD ||
          t.type === CreditTransactionType.DONATION_REWARD ||
          t.type === CreditTransactionType.REFORM_REWARD ||
          t.type === CreditTransactionType.TRANSFER_IN
        );
      } else if (typeFilter === 'expense') {
        filtered = filtered.filter((t: CreditTransaction): boolean =>
          t.type === CreditTransactionType.EXCHANGE_DEDUCT ||
          t.type === CreditTransactionType.EXPIRE_CLEAR ||
          t.type === CreditTransactionType.TRANSFER_OUT ||
          t.type === CreditTransactionType.TRANSFER_FEE ||
          t.type === CreditTransactionType.VIOLATION_DEDUCT
        );
      }
    }
    filtered.sort((a: CreditTransaction, b: CreditTransaction): number => b.timestamp - a.timestamp);
    const start = (page - 1) * pageSize;
    return filtered.slice(start, start + pageSize);
  }

  existsByRelatedId(relatedId: string): boolean {
    return this.transactions.some((t: CreditTransaction): boolean => t.relatedId === relatedId);
  }

  countByType(userId: string, type: CreditTransactionType): number {
    return this.transactions.filter((t: CreditTransaction): boolean =>
      t.userId === userId && t.type === type
    ).length;
  }

  getTodayEarned(userId: string): number {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const startTs = todayStart.getTime();
    return this.transactions
      .filter((t: CreditTransaction): boolean =>
        t.userId === userId && t.timestamp >= startTs && t.amount > 0
      )
      .reduce((sum: number, t: CreditTransaction): number => sum + t.amount, 0);
  }

  getTotalReduction(userId: string): number {
    return this.transactions
      .filter((t: CreditTransaction): boolean =>
        t.userId === userId && t.carbonReduction > 0
      )
      .reduce((sum: number, t: CreditTransaction): number => sum + t.carbonReduction, 0);
  }

  getTradeDates(userId: string): number[] {
    const tradeTx = this.transactions.filter((t: CreditTransaction): boolean =>
      t.userId === userId && t.type === CreditTransactionType.TRADE_REWARD
    );
    const dateSet = new Set<number>();
    for (const tx of tradeTx) {
      const d = new Date(tx.timestamp);
      d.setHours(0, 0, 0, 0);
      dateSet.add(d.getTime());
    }
    const dates = Array.from(dateSet);
    dates.sort((a: number, b: number): number => b - a);
    return dates;
  }
}

export const creditTransactionRepository = new CreditTransactionRepository();