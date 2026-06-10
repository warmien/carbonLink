export class SemanticSearchResult {
  productIds: string[] = [];
  relevanceScores: number[] = [];
  totalMatches: number = 0;
  success: boolean = false;
  errorMessage: string = '';
}