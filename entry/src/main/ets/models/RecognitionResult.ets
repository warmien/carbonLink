export class RecognitionResult {
  itemName: string = '';
  condition: string = '';
  mappedCondition: string = '';
  description: string = '';
  category: string = '';
  subCategory: string = '';
  suggestedPrice: number = 0;
  originalPrice: number = 0;
  success: boolean = false;
  errorMessage: string = '';
}