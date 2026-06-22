import { EcoAchievement } from '../models/EcoAchievement';
import { achievementRepository } from '../repository/AchievementRepository';
import { CreditEngine } from './CreditEngine';
import { creditAccountRepository } from '../repository/CreditAccountRepository';

export class AchievementDetector {
  static async detect(userId: string, actionType: string): Promise<EcoAchievement[]> {
    const achievements = achievementRepository.getAchievements(userId);
    const newlyUnlocked: EcoAchievement[] = [];

    const stats = await creditAccountRepository.getStats(userId);
    const tradeCount: number = typeof stats['tradeCount'] === 'number' ? stats['tradeCount'] : 0;
    const totalReduction: number = typeof stats['totalReduction'] === 'number' ? stats['totalReduction'] : 0;

    for (let i = 0; i < achievements.length; i++) {
      const a = achievements[i];
      if (a.unlocked) {
        continue;
      }

      let progress = 0;
      if (a.id === 'first_trade') {
        progress = tradeCount;
      } else if (a.id === 'streak_7days') {
        progress = tradeCount >= 7 ? 7 : 0;
      } else if (a.id === 'total_10trades') {
        progress = tradeCount;
      } else if (a.id === 'reduce_1kg') {
        progress = Math.floor(totalReduction * 10) / 10;
      }

      achievementRepository.updateProgress(userId, a.id, progress);

      if (progress >= a.targetValue) {
        const unlocked = achievementRepository.unlockAchievement(userId, a.id);
        if (unlocked) {
          newlyUnlocked.push(unlocked);
          const relatedId = 'achievement_' + a.id;
          await CreditEngine.onAchievementReward(userId, a.rewardCredits, relatedId);
        }
      }
    }

    return newlyUnlocked;
  }
}
