import { UserLevel } from '../models/CreditAccount';

export class LevelThreshold {
  level: UserLevel = UserLevel.BEGINNER;
  threshold: number = 0;
  constructor(level: UserLevel, threshold: number) {
    this.level = level;
    this.threshold = threshold;
  }
}

export class AchievementConfig {
  id: string = '';
  name: string = '';
  description: string = '';
  icon: string = '';
  targetValue: number = 0;
  rewardCredits: number = 0;
  constructor(id: string, name: string, description: string, icon: string, targetValue: number, rewardCredits: number) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.icon = icon;
    this.targetValue = targetValue;
    this.rewardCredits = rewardCredits;
  }
}

export class CreditRules {
  static readonly TRADE_BUYER_REWARD: number = 30;
  static readonly TRADE_SELLER_REWARD: number = 20;
  static readonly PUBLISH_REWARD: number = 10;
  static readonly CREDIT_EXPIRY_MONTHS: number = 12;

  static readonly LEVEL_THRESHOLDS: LevelThreshold[] = [
    new LevelThreshold(UserLevel.BEGINNER, 0),
    new LevelThreshold(UserLevel.EXPERT, 100),
    new LevelThreshold(UserLevel.PIONEER, 500),
    new LevelThreshold(UserLevel.GUARDIAN, 2000),
    new LevelThreshold(UserLevel.HERO, 5000)
  ];

  static readonly ACHIEVEMENT_CONFIGS: AchievementConfig[] = [
    new AchievementConfig('first_trade', '首次交易', '完成第一笔二手交易', '🤝', 1, 20),
    new AchievementConfig('streak_7days', '连续交易7天', '连续7天都有交易记录', '🔥', 7, 50),
    new AchievementConfig('total_10trades', '累计交易10笔', '累计完成10笔二手交易', '🏆', 10, 100),
    new AchievementConfig('reduce_1kg', '累计减排1kg', '通过二手交易累计减少1kg碳排放', '🌱', 1, 30)
  ];

  static getLevelByTotalEarned(totalEarned: number): UserLevel {
    let result: UserLevel = UserLevel.BEGINNER;
    const thresholds = CreditRules.LEVEL_THRESHOLDS;
    for (let i = 0; i < thresholds.length; i++) {
      if (totalEarned >= thresholds[i].threshold) {
        result = thresholds[i].level;
      }
    }
    return result;
  }
}
