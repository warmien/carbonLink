export class RecommendationConfig {
  static readonly WEIGHT_COLLABORATIVE: number = 0.4;
  static readonly WEIGHT_CONTENT: number = 0.3;
  static readonly WEIGHT_POPULARITY: number = 0.3;

  static readonly HOME_RECOMMEND_LIMIT: number = 10;
  static readonly DETAIL_RECOMMEND_LIMIT: number = 6;
  static readonly DIVERSITY_MIN_CATEGORIES: number = 3;

  static readonly BEHAVIOR_WEIGHT_VIEW: number = 1;
  static readonly BEHAVIOR_WEIGHT_FAVORITE: number = 3;
  static readonly BEHAVIOR_WEIGHT_PURCHASE: number = 5;
  static readonly BEHAVIOR_WEIGHT_SEARCH: number = 2;

  static readonly PROFILE_UPDATE_DEBOUNCE_MS: number = 5000;
  static readonly BEHAVIOR_RECORD_LIMIT: number = 500;
}