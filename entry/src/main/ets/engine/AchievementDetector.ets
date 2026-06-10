import { EcoAchievement } from '../models/EcoAchievement';
import { CreditTransactionType } from '../models/CreditTransaction';
import { creditTransactionRepository } from '../repository/CreditTransactionRepository';
import { achievementRepository } from '../repository/AchievementRepository';
import { CreditEngine } from './CreditEngine';

export class AchievementDetector {
  static detect(userId: string, actionType: string): EcoAchievement[] {
    const achievements = achievementRepository.getAchievements(userId);
    const newlyUnlocked: EcoAchievement[] = [];

    for (let i = 0; i < achievements.length; i++) {
      const a = achievements[i];
      if (a.unlocked) {
        continue;
      }

      let progress = 0;
      if (a.id === 'first_trade') {
        progress = creditTransactionRepository.countByType(userId, CreditTransactionType.TRADE_REWARD);
      } else if (a.id === 'streak_7days') {
        progress = AchievementDetector.calcConsecutiveDays(userId);
      } else if (a.id === 'total_10trades') {
        progress = creditTransactionRepository.countByType(userId, CreditTransactionType.TRADE_REWARD);
      } else if (a.id === 'reduce_1kg') {
        progress = AchievementDetector.estimateCarbonReduction(userId);
      }

      achievementRepository.updateProgress(userId, a.id, progress);

      if (progress >= a.targetValue) {
        const unlocked = achievementRepository.unlockAchievement(userId, a.id);
        if (unlocked) {
          newlyUnlocked.push(unlocked);
          const relatedId = 'achievement_' + a.id;
          if (!creditTransactionRepository.existsByRelatedId(relatedId)) {
            CreditEngine.onAchievementReward(userId, a.rewardCredits, relatedId);
          }
        }
      }
    }

    return newlyUnlocked;
  }

  private static calcConsecutiveDays(userId: string): number {
    const dates = creditTransactionRepository.getTradeDates(userId);
    if (dates.length === 0) return 0;
    let streak = 1;
    const oneDayMs = 24 * 60 * 60 * 1000;
    for (let i = 0; i < dates.length - 1; i++) {
      const diff = dates[i] - dates[i + 1];
      if (diff <= oneDayMs + 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  private static estimateCarbonReduction(userId: string): number {
    const tradeCount = creditTransactionRepository.countByType(userId, CreditTransactionType.TRADE_REWARD);
    const kgPerTrade = 0.1;
    const totalKg = tradeCount * kgPerTrade;
    return Math.floor(totalKg * 10) / 10;
  }
}