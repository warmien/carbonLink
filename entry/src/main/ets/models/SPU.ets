export class SPU {
  id: string = ''
  title: string = ''
  description: string = ''
  images: string[] = []
  categoryId: number = 0
  subCategoryId: number = 0
  categoryName: string = ''
  subCategoryName: string = ''
  brand: string = ''
  sellerId: string = ''
  sellerName: string = ''
  sellerAvatar: string = ''
  location: string = ''
  distance: string = ''
  viewCount: number = 0
  favoriteCount: number = 0
  isFavorited: boolean = false
  status: string = 'on_sale'
  tags: string[] = []
  minPrice: number = 0
  createdAt: number = Date.now()
  updatedAt: number = Date.now()
}

export enum SPUStatus {
  ON_SALE = 'on_sale',
  OFF_SALE = 'off_sale',
  SOLD_OUT = 'sold_out',
  DELETED = 'deleted'
}