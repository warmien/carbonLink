export interface CreateSPUParams {
  title: string;
  description?: string;
  images?: string[];
  categoryId: number;
  subCategoryId?: number;
  brand?: string;
  sellerId: string;
  sellerName: string;
  sellerAvatar?: string;
  location?: string;
  distance?: string;
  tags?: string[];
  attributes?: CreateAttributeParams[];
  skus: CreateSKUParams[];
}

export interface CreateSKUParams {
  price: number;
  originalPrice?: number;
  condition: string;
  stock?: number;
  skuCode?: string;
  specValueIds?: number[];
}

export interface CreateAttributeParams {
  attributeNameId: number;
  value: string;
}

export interface SPUDTO {
  id: string;
  title: string;
  description: string;
  images: string[];
  categoryId: number;
  subCategoryId: number | null;
  categoryName: string;
  subCategoryName: string;
  brand: string;
  sellerId: string;
  sellerName: string;
  sellerAvatar: string;
  location: string;
  distance: string;
  viewCount: number;
  favoriteCount: number;
  status: string;
  tags: string[];
  minPrice: number;
  createdAt: number;
  updatedAt: number;
}

export interface SKUDTO {
  id: string;
  spuId: string;
  price: number;
  originalPrice: number;
  condition: string;
  carbonReduction: number;
  carbonCredits: number;
  status: string;
  skuCode: string;
  availableStock: number;
  specValues: SpecValueDTO[];
  createdAt: number;
  updatedAt: number;
}

export interface SPUWithSKUs {
  spu: SPUDTO;
  skus: SKUDTO[];
  attributes: ProductAttributeDTO[];
}

export interface SpecNameDTO {
  id: number;
  name: string;
  sortOrder: number;
  createdAt: number;
  updatedAt: number;
}

export interface SpecValueDTO {
  id: number;
  specNameId: number;
  specName: string;
  value: string;
  sortOrder: number;
}

export interface AttributeNameDTO {
  id: number;
  name: string;
  inputType: string;
  sortOrder: number;
  createdAt: number;
  updatedAt: number;
}

export interface CategoryAttributeDTO {
  categoryId: number;
  attributeNameId: number;
  attributeName: string;
  inputType: string;
  isRequired: boolean;
}

export interface ProductAttributeDTO {
  spuId: string;
  attributeNameId: number;
  attributeName: string;
  attributeValue: string;
}

export interface InventoryDTO {
  id: number;
  skuId: string;
  totalStock: number;
  availableStock: number;
  lockedStock: number;
  createdAt: number;
  updatedAt: number;
}

export interface CategorySpecTreeDTO {
  specNameId: number;
  specName: string;
  values: SpecValueDTO[];
}

export interface MigrationResult {
  spuCount: number;
  skuCount: number;
  orderUpdateCount: number;
  errors: string[];
}

export interface MigrationStatus {
  migrated: boolean;
  spuCount: number;
  skuCount: number;
  migratedAt: number | null;
}

export interface ListSPUFilters {
  categoryId?: number;
  subCategoryId?: number;
  status?: string;
  sellerId?: string;
  keyword?: string;
  minPrice?: number;
  maxPrice?: number;
  condition?: string;
  page: number;
  pageSize: number;
}

export enum SPUStatus {
  ON_SALE = 'on_sale',
  OFF_SALE = 'off_sale',
  SOLD_OUT = 'sold_out',
  DELETED = 'deleted'
}

export enum SKUStatus {
  ON_SALE = 'on_sale',
  OFF_SALE = 'off_sale',
  SOLD_OUT = 'sold_out'
}