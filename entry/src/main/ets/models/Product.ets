/** @deprecated 使用 SPU 替代 */
export class Product {
  id: string = '';
  title: string = '';
  description: string = '';
  price: number = 0;
  originalPrice: number = 0;
  images: string[] = [];
  category: string = '';
  subCategory: string = '';
  condition: string = '';
  carbonReduction: number = 0;
  carbonCredits: number = 0;
  brand: string = '';
  location: string = '';
  distance: string = '';
  sellerId: string = '';
  sellerName: string = '';
  sellerAvatar: string = '';
  viewCount: number = 0;
  favoriteCount: number = 0;
  isFavorited: boolean = false;
  status: string = 'selling';
  createdAt: number = Date.now();
  tags: string[] = [];
}

export enum ProductCondition {
  A_GRADE = 'A级-全新未用',
  B_GRADE = 'B级-99成新',
  C_GRADE = 'C级-95成新',
  D_GRADE = 'D级-9成新',
  E_GRADE = 'E级-8成新',
  F_GRADE = 'F级-7成新'
}

export enum ProductStatus {
  SELLING = 'selling',
  SOLD = 'sold',
  REMOVED = 'removed'
}
