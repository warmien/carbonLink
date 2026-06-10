export class UserBehavior {
  userId: string = '';
  behaviorType: BehaviorType = BehaviorType.VIEW;
  targetId: string = '';
  targetCategory: string = '';
  timestamp: number = Date.now();
}

export enum BehaviorType {
  VIEW = 'VIEW',
  FAVORITE = 'FAVORITE',
  PURCHASE = 'PURCHASE',
  SEARCH = 'SEARCH',
  DISLIKE = 'DISLIKE'
}