export class Recommendation {
  productId: string = '';
  score: number = 0;
  reason: string = '';
  strategy: RecStrategy = RecStrategy.POPULARITY;
}

export enum RecStrategy {
  COLLABORATIVE_FILTERING = 'COLLABORATIVE_FILTERING',
  CONTENT_BASED = 'CONTENT_BASED',
  POPULARITY = 'POPULARITY',
  COLD_START = 'COLD_START'
}