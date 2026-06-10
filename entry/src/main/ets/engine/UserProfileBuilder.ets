import { UserProfile, CategoryWeight, PriceRange } from '../models/UserProfile';
import { BehaviorType } from '../models/UserBehavior';
import { behaviorRepository } from '../repository/BehaviorRepository';
import { userProfileRepository } from '../repository/UserProfileRepository';

export class UserProfileBuilder {
  static buildProfile(userId: string): UserProfile {
    const profile = new UserProfile();
    profile.userId = userId;

    const catWeights = behaviorRepository.getCategoryWeights(userId);
    const entries: string[] = [];
    catWeights.forEach((value: number, key: string) => {
      entries.push(key + ':' + value.toString());
    });

    let totalWeight = 0;
    const catWeightList: CategoryWeight[] = [];
    for (let i = 0; i < entries.length; i++) {
      const parts = entries[i].split(':');
      const cat = parts[0];
      const w = parseFloat(parts[1]);
      totalWeight += w;
      catWeightList.push(new CategoryWeight(cat, w));
    }

    if (totalWeight > 0) {
      for (let i = 0; i < catWeightList.length; i++) {
        catWeightList[i].weight = catWeightList[i].weight / totalWeight;
      }
    }
    catWeightList.sort((a: CategoryWeight, b: CategoryWeight): number => b.weight - a.weight);
    profile.preferredCategories = catWeightList;

    const favBehaviors = behaviorRepository.getBehaviorsByType(userId, BehaviorType.FAVORITE);
    const purchaseBehaviors = behaviorRepository.getBehaviorsByType(userId, BehaviorType.PURCHASE);
    const conditionSet: string[] = [];
    for (let i = 0; i < favBehaviors.length; i++) {
      const cat = favBehaviors[i].targetCategory;
      if (cat && conditionSet.indexOf(cat) === -1) {
        conditionSet.push(cat);
      }
    }
    profile.conditionPreference = conditionSet;

    userProfileRepository.saveProfile(profile);
    return profile;
  }
}