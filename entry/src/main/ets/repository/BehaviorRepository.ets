import { UserBehavior, BehaviorType } from '../models/UserBehavior';
import { RecommendationConfig } from '../config/RecommendationConfig';

export class BehaviorRepository {
  private behaviors: UserBehavior[] = [];
  private dislikedIds: string[] = [];

  addBehavior(behavior: UserBehavior): void {
    if (behavior.behaviorType === BehaviorType.DISLIKE) {
      this.dislikedIds.push(behavior.targetId);
      return;
    }
    this.behaviors.push(behavior);
    if (this.behaviors.length > RecommendationConfig.BEHAVIOR_RECORD_LIMIT) {
      this.behaviors.shift();
    }
  }

  getBehaviors(userId: string, limit: number): UserBehavior[] {
    const filtered = this.behaviors.filter((b: UserBehavior): boolean => b.userId === userId);
    filtered.sort((a: UserBehavior, b: UserBehavior): number => b.timestamp - a.timestamp);
    return filtered.slice(0, limit);
  }

  getDislikedProductIds(userId: string): string[] {
    return this.dislikedIds;
  }

  getBehaviorsByType(userId: string, type: BehaviorType): UserBehavior[] {
    return this.behaviors.filter((b: UserBehavior): boolean =>
      b.userId === userId && b.behaviorType === type
    );
  }

  getCategoryWeights(userId: string): Map<string, number> {
    const weights = new Map<string, number>();
    const userBehaviors = this.behaviors.filter((b: UserBehavior): boolean => b.userId === userId);
    for (let i = 0; i < userBehaviors.length; i++) {
      const b = userBehaviors[i];
      if (!b.targetCategory) continue;
      let w = 0;
      if (b.behaviorType === BehaviorType.VIEW) w = RecommendationConfig.BEHAVIOR_WEIGHT_VIEW;
      else if (b.behaviorType === BehaviorType.FAVORITE) w = RecommendationConfig.BEHAVIOR_WEIGHT_FAVORITE;
      else if (b.behaviorType === BehaviorType.PURCHASE) w = RecommendationConfig.BEHAVIOR_WEIGHT_PURCHASE;
      else if (b.behaviorType === BehaviorType.SEARCH) w = RecommendationConfig.BEHAVIOR_WEIGHT_SEARCH;
      const current = weights.get(b.targetCategory);
      if (current !== undefined) {
        weights.set(b.targetCategory, current + w);
      } else {
        weights.set(b.targetCategory, w);
      }
    }
    return weights;
  }
}

export const behaviorRepository = new BehaviorRepository();