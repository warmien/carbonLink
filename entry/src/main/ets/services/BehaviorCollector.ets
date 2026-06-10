import { UserBehavior, BehaviorType } from '../models/UserBehavior';
import { behaviorRepository } from '../repository/BehaviorRepository';
import { UserProfileBuilder } from '../engine/UserProfileBuilder';

export class BehaviorCollector {
  private static debounceTimer: number = 0;

  static recordView(userId: string, productId: string, category: string, price: number): void {
    const b = new UserBehavior();
    b.userId = userId;
    b.behaviorType = BehaviorType.VIEW;
    b.targetId = productId;
    b.targetCategory = category;
    behaviorRepository.addBehavior(b);
    BehaviorCollector.scheduleProfileUpdate(userId);
  }

  static recordFavorite(userId: string, productId: string, category: string, condition: string): void {
    const b = new UserBehavior();
    b.userId = userId;
    b.behaviorType = BehaviorType.FAVORITE;
    b.targetId = productId;
    b.targetCategory = category;
    behaviorRepository.addBehavior(b);
    BehaviorCollector.scheduleProfileUpdate(userId);
  }

  static recordPurchase(userId: string, productId: string, category: string, price: number): void {
    const b = new UserBehavior();
    b.userId = userId;
    b.behaviorType = BehaviorType.PURCHASE;
    b.targetId = productId;
    b.targetCategory = category;
    behaviorRepository.addBehavior(b);
    BehaviorCollector.scheduleProfileUpdate(userId);
  }

  static recordSearch(userId: string, keyword: string): void {
    const b = new UserBehavior();
    b.userId = userId;
    b.behaviorType = BehaviorType.SEARCH;
    b.targetId = keyword;
    behaviorRepository.addBehavior(b);
    BehaviorCollector.scheduleProfileUpdate(userId);
  }

  static recordDislike(userId: string, productId: string, category: string): void {
    const b = new UserBehavior();
    b.userId = userId;
    b.behaviorType = BehaviorType.DISLIKE;
    b.targetId = productId;
    b.targetCategory = category;
    behaviorRepository.addBehavior(b);
  }

  private static scheduleProfileUpdate(userId: string): void {
    BehaviorCollector.debounceTimer++;
    const timerId = BehaviorCollector.debounceTimer;
    setTimeout(() => {
      if (timerId === BehaviorCollector.debounceTimer) {
        UserProfileBuilder.buildProfile(userId);
      }
    }, 5000);
  }
}