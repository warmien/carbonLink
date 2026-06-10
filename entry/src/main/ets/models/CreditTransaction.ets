export class CreditTransaction {
  id: string = '';
  userId: string = '';
  type: CreditTransactionType = CreditTransactionType.TRADE_REWARD;
  amount: number = 0;
  balanceAfter: number = 0;
  relatedId: string = '';
  carbonReduction: number = 0;
  timestamp: number = Date.now();
}

export enum CreditTransactionType {
  TRADE_REWARD = 'TRADE_REWARD',
  PUBLISH_REWARD = 'PUBLISH_REWARD',
  ACHIEVEMENT_REWARD = 'ACHIEVEMENT_REWARD',
  EXCHANGE_DEDUCT = 'EXCHANGE_DEDUCT',
  EXPIRE_CLEAR = 'EXPIRE_CLEAR',
  DONATION_REWARD = 'DONATION_REWARD',
  REFORM_REWARD = 'REFORM_REWARD',
  TRANSFER_OUT = 'TRANSFER_OUT',
  TRANSFER_IN = 'TRANSFER_IN',
  TRANSFER_FEE = 'TRANSFER_FEE',
  VIOLATION_DEDUCT = 'VIOLATION_DEDUCT'
}