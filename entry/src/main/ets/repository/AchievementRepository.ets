import { EcoAchievement } from '../models/EcoAchievement';
import { CreditRules } from '../config/CreditRules';

export class AchievementRepository {
  private achievements: Map<string, EcoAchievement[]> = new Map();
  private initialized: boolean = false;

  private initDefaultAchievements(): EcoAchievement[] {
    const list: EcoAchievement[] = [];
    const configs = CreditRules.ACHIEVEMENT_CONFIGS;
    for (let i = 0; i < configs.length; i++) {
      const cfg = configs[i];
      const a = new EcoAchievement();
      a.id = cfg.id;
      a.name = cfg.name;
      a.description = cfg.description;
      a.icon = cfg.icon;
      a.targetValue = cfg.targetValue;
      a.rewardCredits = cfg.rewardCredits;
      a.unlocked = false;
      a.progress = 0;
      list.push(a);
    }
    return list;
  }

  getAchievements(userId: string): EcoAchievement[] {
    let list = this.achievements.get(userId);
    if (!list) {
      list = this.initDefaultAchievements();
      this.achievements.set(userId, list);
    }
    return list;
  }

  unlockAchievement(userId: string, achievementId: string): EcoAchievement | null {
    const list = this.getAchievements(userId);
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === achievementId && !list[i].unlocked) {
        list[i].unlocked = true;
        list[i].progress = list[i].targetValue;
        this.achievements.set(userId, list);
        return list[i];
      }
    }
    return null;
  }

  updateProgress(userId: string, achievementId: string, progress: number): void {
    const list = this.getAchievements(userId);
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === achievementId) {
        list[i].progress = Math.min(progress, list[i].targetValue);
        break;
      }
    }
    this.achievements.set(userId, list);
  }
}

export const achievementRepository = new AchievementRepository();