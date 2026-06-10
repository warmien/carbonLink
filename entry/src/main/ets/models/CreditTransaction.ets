export class CreditTransaction {
  id: string = '';
  userId: string = '';
  type: CreditTransactionType = CreditTransactionType.TRADE_REWARD;
  amount: number = 0;
  balanceAfter: number = 0;
  relatedId: string = '';
  timestamp: number = Date.now();
}

export enum CreditTransactionType {
  TRADE_REWARD = 'TRADE_REWARD',
  PUBLISH_REWARD = 'PUBLISH_REWARD',
  ACHIEVEMENT_REWARD = 'ACHIEVEMENT_REWARD',
  EXCHANGE_DEDUCT = 'EXCHANGE_DEDUCT',
  EXPIRE_CLEAR = 'EXPIRE_CLEAR'
}