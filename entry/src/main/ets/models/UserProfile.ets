export class UserProfile {
  userId: string = '';
  preferredCategories: CategoryWeight[] = [];
  priceRangePreference: PriceRange = new PriceRange();
  conditionPreference: string[] = [];
  lastUpdated: number = Date.now();
}

export class CategoryWeight {
  category: string = '';
  weight: number = 0;
  constructor(category: string, weight: number) {
    this.category = category;
    this.weight = weight;
  }
}

export class PriceRange {
  min: number = 0;
  max: number = 99999;
}