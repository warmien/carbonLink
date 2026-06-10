export class CreditAccount {
  userId: string = '';
  balance: number = 0;
  totalEarned: number = 0;
  totalSpent: number = 0;
  level: UserLevel = UserLevel.BEGINNER;
  createdAt: number = Date.now();
}

export enum UserLevel {
  BEGINNER = '环保新手',
  EXPERT = '环保达人',
  PIONEER = '环保先锋',
  GUARDIAN = '环保卫士',
  HERO = '环保英雄'
}