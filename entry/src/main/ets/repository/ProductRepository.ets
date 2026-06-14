import { SPU } from '../models/SPU';
import { SKU, SpecValueItem } from '../models/SKU';
import { ProductAttribute, CategorySpecTree, SpecValue, AttributeName } from '../models/Spec';
import { Product } from '../models/Product';
import { HttpService } from '../services/HttpService';
import { MockProducts } from '../mock/MockProducts';
import { MockUsers } from '../mock/MockUsers';

export class SPUListResult {
  list: SPU[] = [];
  total: number = 0;
}

export class FavoriteToggleResult {
  isFavorited: boolean = false;
  favoriteCount: number = 0;
}

export class ProductDetailResult {
  spu: SPU = new SPU();
  skus: SKU[] = [];
  attributes: ProductAttribute[] = [];
}

function toStr(val: string | number | object | undefined): string {
  if (typeof val === 'string') return val;
  if (typeof val === 'number') return val.toString();
  return '';
}

function toNum(val: string | number | object | undefined): number {
  if (typeof val === 'number') return val;
  if (typeof val === 'string') {
    const n = parseFloat(val);
    return isNaN(n) ? 0 : n;
  }
  return 0;
}

function toBool(val: string | number | object | undefined): boolean {
  if (typeof val === 'number') return val !== 0;
  if (typeof val === 'string') return val === 'true' || val === '1';
  return false;
}

function toStrArr(val: string | number | object | undefined): string[] {
  if (val === undefined) {
    return [];
  }
  if (typeof val !== 'string' && typeof val !== 'number' && typeof val !== 'boolean') {
    const arr: (string | number | boolean | object)[] = val as (string | number | boolean | object)[];
    return arr.map((item: string | number | boolean | object): string => String(item));
  }
  return [];
}

function toObjArr(val: string | number | object | undefined): Record<string, string | number | object>[] {
  if (val === undefined) {
    return [];
  }
  const result: Record<string, string | number | object>[] = val as Record<string, string | number | object>[];
  return result;
}

export class ProductRepository {
  async fetchProducts(queryString?: string): Promise<SPUListResult> {
    let path: string = '/products';
    if (queryString && queryString.length > 0) {
      path += '?' + queryString;
    }
    const resp = await HttpService.GET(path);
    const result = new SPUListResult();
    if (resp.code === 0 && resp.data !== null) {
      const listData = toObjArr(resp.data['list']);
      result.total = toNum(resp.data['total']);
      for (let i = 0; i < listData.length; i++) {
        result.list.push(ProductRepository.mapSPU(listData[i]));
      }
    }
    return result;
  }

  async getProductDetail(spuId: string): Promise<ProductDetailResult | null> {
    const resp = await HttpService.GET('/products/' + spuId);
    if (resp.code === 0 && resp.data !== null) {
      const spuData = resp.data['spu'] as Record<string, string | number | object>;
      const skusData = toObjArr(resp.data['skus']);
      const attrsData = toObjArr(resp.data['attributes']);
      if (!spuData) return null;

      const result = new ProductDetailResult();
      result.spu = ProductRepository.mapSPU(spuData);
      for (let i = 0; i < skusData.length; i++) {
        result.skus.push(ProductRepository.mapSKU(skusData[i]));
      }
      for (let i = 0; i < attrsData.length; i++) {
        const a = attrsData[i];
        const attr = new ProductAttribute();
        attr.attributeNameId = toNum(a['attributeNameId']);
        attr.attributeName = toStr(a['attributeName']);
        attr.attributeValue = toStr(a['attributeValue']);
        result.attributes.push(attr);
      }
      return result;
    }
    return null;
  }

  async createProduct(data: Record<string, string | number | object>): Promise<SPU | null> {
    const resp = await HttpService.POST('/products', data);
    if (resp.code === 0 && resp.data !== null) {
      const spuData = resp.data['spu'] as Record<string, string | number | object>;
      if (!spuData) return null;
      return ProductRepository.mapSPU(spuData);
    }
    return null;
  }

  async getCategorySpecTree(categoryId: number): Promise<CategorySpecTree[]> {
    const resp = await HttpService.GET('/category-specs/' + categoryId.toString());
    if (resp.code === 0 && resp.data !== null) {
      const data = toObjArr(resp.data as object);
      const result: CategorySpecTree[] = [];
      for (let i = 0; i < data.length; i++) {
        const item = data[i];
        const tree = new CategorySpecTree();
        tree.specNameId = toNum(item['specNameId']);
        tree.specName = toStr(item['specName']);
        const valuesData = toObjArr(item['values']);
        tree.values = [];
        for (let j = 0; j < valuesData.length; j++) {
          const v = valuesData[j];
          const sv = new SpecValue();
          sv.id = toNum(v['id']);
          sv.specNameId = toNum(v['specNameId']);
          sv.value = toStr(v['value']);
          sv.sortOrder = toNum(v['sortOrder']);
          tree.values.push(sv);
        }
        result.push(tree);
      }
      return result;
    }
    return [];
  }

  async getCategoryAttributes(categoryId: number): Promise<AttributeName[]> {
    const resp = await HttpService.GET('/category-attributes/' + categoryId.toString());
    if (resp.code === 0 && resp.data !== null) {
      const data = toObjArr(resp.data as object);
      const result: AttributeName[] = [];
      for (let i = 0; i < data.length; i++) {
        const item = data[i];
        const an = new AttributeName();
        an.id = toNum(item['attributeNameId']);
        an.name = toStr(item['attributeName']);
        an.inputType = toStr(item['inputType']);
        result.push(an);
      }
      return result;
    }
    return [];
  }

  async toggleProductStatus(spuId: string, status: string): Promise<boolean> {
    const body: Record<string, string | number | object> = {};
    body['status'] = status;
    const resp = await HttpService.PUT('/products/' + spuId + '/status', body);
    return resp.code === 0;
  }

  async toggleFavorite(spuId: string): Promise<FavoriteToggleResult | null> {
    const body: Record<string, string | number | object> = {};
    body['spuId'] = spuId;
    const resp = await HttpService.POST('/favorites/toggle', body);
    if (resp.code === 0 && resp.data !== null) {
      const result = new FavoriteToggleResult();
      result.isFavorited = toBool(resp.data['isFavorited']);
      result.favoriteCount = toNum(resp.data['favoriteCount']);
      return result;
    }
    return null;
  }

  async fetchFavoriteProducts(page?: number, pageSize?: number): Promise<SPUListResult> {
    let path: string = '/favorites?';
    if (page !== undefined) {
      path += 'page=' + page.toString() + '&';
    }
    if (pageSize !== undefined) {
      path += 'pageSize=' + pageSize.toString();
    }
    const resp = await HttpService.GET(path);
    const result = new SPUListResult();
    if (resp.code === 0 && resp.data !== null) {
      const listData = toObjArr(resp.data['list']);
      result.total = toNum(resp.data['total']);
      for (let i = 0; i < listData.length; i++) {
        result.list.push(ProductRepository.mapSPU(listData[i]));
      }
    }
    return result;
  }

  async getFavoriteCount(): Promise<number> {
    const resp = await HttpService.GET('/favorites/count');
    if (resp.code === 0 && resp.data !== null) {
      return toNum(resp.data['count']);
    }
    return 0;
  }

  async checkFavorite(spuId: string): Promise<boolean> {
    const resp = await HttpService.GET('/favorites/check/' + spuId);
    if (resp.code === 0 && resp.data !== null) {
      return toBool(resp.data['isFavorited']);
    }
    return false;
  }

  async deleteProduct(spuId: string): Promise<boolean> {
    const resp = await HttpService.DELETE('/products/' + spuId);
    return resp.code === 0;
  }

  async updateSKU(skuId: string, updates: Record<string, string | number | object>): Promise<SKU | null> {
    const resp = await HttpService.PUT('/skus/' + skuId, updates);
    if (resp.code === 0 && resp.data !== null) {
      return ProductRepository.mapSKU(resp.data as Record<string, string | number | object>);
    }
    return null;
  }

  private static mapSPU(data: Record<string, string | number | object>): SPU {
    const spu = new SPU();
    spu.id = toStr(data['id']);
    spu.title = toStr(data['title']);
    spu.description = toStr(data['description']);
    spu.images = toStrArr(data['images']);
    spu.categoryId = toNum(data['categoryId']);
    spu.subCategoryId = toNum(data['subCategoryId']);
    spu.categoryName = toStr(data['categoryName']);
    spu.subCategoryName = toStr(data['subCategoryName']);
    spu.brand = toStr(data['brand']);
    spu.sellerId = toStr(data['sellerId']);
    spu.sellerName = toStr(data['sellerName']);
    spu.sellerAvatar = toStr(data['sellerAvatar']);
    spu.location = toStr(data['location']);
    spu.distance = toStr(data['distance']);
    spu.viewCount = toNum(data['viewCount']);
    spu.favoriteCount = toNum(data['favoriteCount']);
    spu.status = toStr(data['status']) || 'on_sale';
    spu.tags = toStrArr(data['tags']);
    spu.minPrice = toNum(data['minPrice']);
    spu.createdAt = toNum(data['createdAt']);
    spu.updatedAt = toNum(data['updatedAt']);
    return spu;
  }

  private static mapSKU(data: Record<string, string | number | object>): SKU {
    const sku = new SKU();
    sku.id = toStr(data['id']);
    sku.spuId = toStr(data['spuId']);
    sku.price = toNum(data['price']);
    sku.originalPrice = toNum(data['originalPrice']);
    sku.condition = toStr(data['condition']);
    sku.carbonReduction = toNum(data['carbonReduction']);
    sku.carbonCredits = toNum(data['carbonCredits']);
    sku.status = toStr(data['status']) || 'on_sale';
    sku.skuCode = toStr(data['skuCode']);
    sku.availableStock = toNum(data['availableStock']);
    sku.createdAt = toNum(data['createdAt']);
    sku.updatedAt = toNum(data['updatedAt']);

    const specValuesData = toObjArr(data['specValues']);
    if (specValuesData.length > 0) {
      sku.specValues = [];
      for (let i = 0; i < specValuesData.length; i++) {
        const sv = specValuesData[i];
        const item = new SpecValueItem();
        item.specNameId = toNum(sv['specNameId']);
        item.specName = toStr(sv['specName']);
        item.specValueId = toNum(sv['specValueId']);
        item.specValue = toStr(sv['specValue']);
        sku.specValues.push(item);
      }
    }
    return sku;
  }

  getProducts(): Product[] {
    return MockProducts.getProducts();
  }

  getProductById(id: string): Product | undefined {
    return MockProducts.getProductById(id);
  }

  getProductsByCategory(category: string): Product[] {
    return MockProducts.getProductsByCategory(category);
  }

  getProductsBySeller(sellerId: string): Product[] {
    return MockProducts.getProductsBySeller(sellerId);
  }

  searchProducts(keyword: string): Product[] {
    return MockProducts.searchProducts(keyword);
  }

  getMockFavoriteProducts(): Product[] {
    const ids = MockUsers.getFavoriteIds();
    return MockProducts.getFavoriteProducts(ids);
  }

  toggleMockFavorite(productId: string): boolean {
    return MockProducts.toggleFavorite(productId);
  }

  addProduct(product: Product): void {
    MockProducts.addProduct(product);
  }

  static productToSPU(product: Product): SPU {
    const spu = new SPU();
    spu.id = product.id;
    spu.title = product.title;
    spu.description = product.description;
    spu.images = product.images;
    spu.categoryName = product.category;
    spu.subCategoryName = product.subCategory;
    spu.brand = product.brand;
    spu.sellerId = product.sellerId;
    spu.sellerName = product.sellerName;
    spu.sellerAvatar = product.sellerAvatar;
    spu.location = product.location;
    spu.distance = product.distance;
    spu.viewCount = product.viewCount;
    spu.favoriteCount = product.favoriteCount;
    spu.isFavorited = product.isFavorited;
    spu.status = product.status;
    spu.tags = product.tags;
    spu.minPrice = product.price;
    spu.createdAt = product.createdAt;
    return spu;
  }
}

export const productRepository = new ProductRepository();
