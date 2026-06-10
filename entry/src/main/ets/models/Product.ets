export class Product {
  id: string = '';
  title: string = '';
  description: string = '';
  price: number = 0;
  originalPrice: number = 0;
  images: string[] = [];
  category: string = '';
  condition: string = ''; // 成色: 全新/几乎全新/轻微使用/正常使用
  brand: string = '';
  location: string = '';
  distance: string = ''; // 距离描述
  sellerId: string = '';
  sellerName: string = '';
  sellerAvatar: string = '';
  viewCount: number = 0;
  favoriteCount: number = 0;
  isFavorited: boolean = false;
  status: string = 'selling'; // selling / sold / removed
  createdAt: number = Date.now();
  tags: string[] = [];
}

export enum ProductCondition {
  BRAND_NEW = '全新',
  LIKE_NEW = '几乎全新',
  LIGHTLY_USED = '轻微使用',
  NORMAL_USED = '正常使用'
}

export enum ProductStatus {
  SELLING = 'selling',
  SOLD = 'sold',
  REMOVED = 'removed'
}
