import db from '../businessDatabase';
import {
  CreateSPUParams,
  SPUDTO,
  SKUDTO,
  SPUWithSKUs,
  ProductAttributeDTO,
  SpecValueDTO,
  ListSPUFilters,
  SPUStatus,
  SKUStatus
} from '../models/Product';

const { v4: uuidv4 } = require('uuid');

export class ProductService {
  static createProduct(params: CreateSPUParams): SPUWithSKUs {
    if (!params.title || !params.categoryId || !params.sellerId || !params.skus || params.skus.length === 0) {
      throw new Error('缺少必填字段：title, categoryId, sellerId, skus');
    }

    const category = db.prepare('SELECT id FROM categories WHERE id = ?').get(params.categoryId) as { id: number } | undefined;
    if (!category) {
      throw new Error('分类不存在');
    }

    const requiredAttrs = db.prepare(`
      SELECT ca.attribute_name_id, an.name
      FROM category_attributes ca
      JOIN attribute_names an ON an.id = ca.attribute_name_id
      WHERE ca.category_id = ? AND ca.is_required = 1
    `).all(params.categoryId) as { attribute_name_id: number; name: string }[];

    if (requiredAttrs.length > 0 && params.attributes) {
      for (const ra of requiredAttrs) {
        const found = params.attributes.find(a => a.attributeNameId === ra.attribute_name_id);
        if (!found || !found.value) {
          throw new Error(`必填属性"${ra.name}"未填写`);
        }
      }
    }

    const now = Date.now();
    const spuId = uuidv4();

    const result = db.transaction(() => {
      const subCatId = params.subCategoryId && params.subCategoryId > 0 ? params.subCategoryId : null;
      db.prepare(`
        INSERT INTO spu (id, title, description, images, category_id, sub_category_id, brand,
          seller_id, seller_name, seller_avatar, location, distance, view_count, favorite_count,
          status, tags, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 'on_sale', ?, ?, ?)
      `).run(
        spuId, params.title, params.description || '', JSON.stringify(params.images || []),
        params.categoryId, subCatId, params.brand || '',
        params.sellerId, params.sellerName, params.sellerAvatar || '',
        params.location || '', params.distance || '',
        JSON.stringify(params.tags || []), now, now
      );

      const skus: SKUDTO[] = [];

      for (const skuParam of params.skus) {
        const skuId = uuidv4();
        const carbon = ProductService.calculateCarbonCredits(params.categoryId, skuParam.condition, params.subCategoryId || undefined);

        db.prepare(`
          INSERT INTO sku (id, spu_id, price, original_price, condition, carbon_reduction, carbon_credits,
            status, sku_code, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, 'on_sale', ?, ?, ?)
        `).run(
          skuId, spuId, skuParam.price, skuParam.originalPrice || 0,
          skuParam.condition, carbon.carbonReduction, carbon.carbonCredits,
          skuParam.skuCode || '', now, now
        );

        const stock = skuParam.stock || 1;
        db.prepare(`
          INSERT INTO inventory (sku_id, total_stock, available_stock, locked_stock, created_at, updated_at)
          VALUES (?, ?, ?, 0, ?, ?)
        `).run(skuId, stock, stock, now, now);

        const specValues: SpecValueDTO[] = [];
        if (skuParam.specValueIds && skuParam.specValueIds.length > 0) {
          for (const svId of skuParam.specValueIds) {
            db.prepare('INSERT INTO sku_spec_values (sku_id, spec_value_id) VALUES (?, ?)').run(skuId, svId);
            const svRow = db.prepare(`
              SELECT sv.id, sv.spec_name_id, sn.name AS spec_name, sv.value, sv.sort_order
              FROM spec_values sv
              JOIN spec_names sn ON sn.id = sv.spec_name_id
              WHERE sv.id = ?
            `).get(svId) as { id: number; spec_name_id: number; spec_name: string; value: string; sort_order: number } | undefined;
            if (svRow) {
              specValues.push({
                id: svRow.id,
                specNameId: svRow.spec_name_id,
                specName: svRow.spec_name,
                value: svRow.value,
                sortOrder: svRow.sort_order
              });
            }
          }
        }

        skus.push({
          id: skuId,
          spuId,
          price: skuParam.price,
          originalPrice: skuParam.originalPrice || 0,
          condition: skuParam.condition,
          carbonReduction: carbon.carbonReduction,
          carbonCredits: carbon.carbonCredits,
          status: SKUStatus.ON_SALE,
          skuCode: skuParam.skuCode || '',
          availableStock: stock,
          specValues,
          createdAt: now,
          updatedAt: now
        });
      }

      const attributes: ProductAttributeDTO[] = [];
      if (params.attributes && params.attributes.length > 0) {
        for (const attr of params.attributes) {
          const attrNameRow = db.prepare('SELECT name FROM attribute_names WHERE id = ?').get(attr.attributeNameId) as { name: string } | undefined;
          if (attrNameRow) {
            db.prepare(`
              INSERT INTO product_attributes (spu_id, attribute_name_id, attribute_value)
              VALUES (?, ?, ?)
            `).run(spuId, attr.attributeNameId, attr.value);
            attributes.push({
              spuId,
              attributeNameId: attr.attributeNameId,
              attributeName: attrNameRow.name,
              attributeValue: attr.value
            });
          }
        }
      }

      const spu = ProductService.buildSPUDTO(spuId, params, skus, now);
      return { spu, skus, attributes };
    })();

    db.prepare('UPDATE users SET product_count = product_count + 1, updated_at = ? WHERE id = ?').run(now, params.sellerId);

    return result;
  }

  static getSPUDetail(spuId: string): SPUWithSKUs | null {
    const spuRow = db.prepare(`
      SELECT s.*, c.name AS category_name, sc.name AS sub_category_name,
        COALESCE(NULLIF(s.seller_avatar, ''), u.avatar) AS seller_avatar_resolved,
        (SELECT MIN(k.price) FROM sku k WHERE k.spu_id = s.id AND k.status = 'on_sale') AS min_price
      FROM spu s
      LEFT JOIN categories c ON c.id = s.category_id
      LEFT JOIN sub_categories sc ON sc.id = s.sub_category_id
      LEFT JOIN users u ON u.id = s.seller_id
      WHERE s.id = ?
    `).get(spuId) as Record<string, unknown> | undefined;

    if (!spuRow) return null;

    db.prepare('UPDATE spu SET view_count = view_count + 1, updated_at = ? WHERE id = ?').run(Date.now(), spuId);

    const skuRows = db.prepare(`
      SELECT k.*, COALESCE(i.available_stock, 1) AS available_stock
      FROM sku k
      LEFT JOIN inventory i ON i.sku_id = k.id
      WHERE k.spu_id = ?
      ORDER BY k.price ASC
    `).all(spuId) as Record<string, unknown>[];

    const skus: SKUDTO[] = skuRows.map(skuRow => {
      const specValueRows = db.prepare(`
        SELECT sv.id, sv.spec_name_id, sn.name AS spec_name, sv.value, sv.sort_order
        FROM sku_spec_values ssv
        JOIN spec_values sv ON sv.id = ssv.spec_value_id
        JOIN spec_names sn ON sn.id = sv.spec_name_id
        WHERE ssv.sku_id = ?
      `).all(skuRow.id) as { id: number; spec_name_id: number; spec_name: string; value: string; sort_order: number }[];

      return {
        id: skuRow.id as string,
        spuId: skuRow.spu_id as string,
        price: skuRow.price as number,
        originalPrice: (skuRow.original_price as number) || 0,
        condition: skuRow.condition as string,
        carbonReduction: (skuRow.carbon_reduction as number) || 0,
        carbonCredits: (skuRow.carbon_credits as number) || 0,
        status: skuRow.status as string,
        skuCode: (skuRow.sku_code as string) || '',
        availableStock: (skuRow.available_stock as number) || 0,
        specValues: specValueRows.map(sv => ({
          id: sv.id,
          specNameId: sv.spec_name_id,
          specName: sv.spec_name,
          value: sv.value,
          sortOrder: sv.sort_order
        })),
        createdAt: skuRow.created_at as number,
        updatedAt: skuRow.updated_at as number
      };
    });

    const attrRows = db.prepare(`
      SELECT pa.spu_id, pa.attribute_name_id, an.name AS attribute_name, pa.attribute_value
      FROM product_attributes pa
      JOIN attribute_names an ON an.id = pa.attribute_name_id
      WHERE pa.spu_id = ?
    `).all(spuId) as { spu_id: string; attribute_name_id: number; attribute_name: string; attribute_value: string }[];

    const attributes: ProductAttributeDTO[] = attrRows.map(a => ({
      spuId: a.spu_id,
      attributeNameId: a.attribute_name_id,
      attributeName: a.attribute_name,
      attributeValue: a.attribute_value
    }));

    const sellerAvatar: string = (spuRow.seller_avatar_resolved as string) || '';

    const spu: SPUDTO = {
      id: spuRow.id as string,
      title: spuRow.title as string,
      description: (spuRow.description as string) || '',
      images: JSON.parse((spuRow.images as string) || '[]'),
      categoryId: spuRow.category_id as number,
      subCategoryId: (spuRow.sub_category_id as number) || null,
      categoryName: (spuRow.category_name as string) || '',
      subCategoryName: (spuRow.sub_category_name as string) || '',
      brand: (spuRow.brand as string) || '',
      sellerId: spuRow.seller_id as string,
      sellerName: spuRow.seller_name as string,
      sellerAvatar,
      location: (spuRow.location as string) || '',
      distance: (spuRow.distance as string) || '',
      viewCount: (spuRow.view_count as number) || 0,
      favoriteCount: (spuRow.favorite_count as number) || 0,
      status: spuRow.status as string,
      tags: JSON.parse((spuRow.tags as string) || '[]'),
      minPrice: (spuRow.min_price as number) || 0,
      createdAt: spuRow.created_at as number,
      updatedAt: spuRow.updated_at as number
    };

    return { spu, skus, attributes };
  }

  static listSPUs(filters: ListSPUFilters): { list: SPUDTO[]; total: number } {
    const conditions: string[] = ['s.status != \'deleted\''];
    const params: (string | number)[] = [];

    if (filters.categoryId) {
      conditions.push('s.category_id = ?');
      params.push(filters.categoryId);
    }
    if (filters.subCategoryId) {
      conditions.push('s.sub_category_id = ?');
      params.push(filters.subCategoryId);
    }
    if (filters.status) {
      conditions.push('s.status = ?');
      params.push(filters.status);
    } else {
      conditions.push('s.status = \'on_sale\'');
    }
    if (filters.sellerId) {
      conditions.push('s.seller_id = ?');
      params.push(filters.sellerId);
    }
    if (filters.keyword) {
      conditions.push('(s.title LIKE ? OR s.description LIKE ?)');
      params.push(`%${filters.keyword}%`, `%${filters.keyword}%`);
    }
    if (filters.minPrice !== undefined) {
      conditions.push('s.id IN (SELECT k.spu_id FROM sku k WHERE k.price >= ?)');
      params.push(filters.minPrice);
    }
    if (filters.maxPrice !== undefined) {
      conditions.push('s.id IN (SELECT k.spu_id FROM sku k WHERE k.price <= ?)');
      params.push(filters.maxPrice);
    }
    if (filters.condition) {
      conditions.push('s.id IN (SELECT k.spu_id FROM sku k WHERE k.condition = ?)');
      params.push(filters.condition);
    }

    const whereClause = conditions.join(' AND ');

    const totalRow = db.prepare(`SELECT COUNT(*) as count FROM spu s WHERE ${whereClause}`).get(...params) as { count: number };

    const page = filters.page || 1;
    const pageSize = filters.pageSize || 20;
    const offset = (page - 1) * pageSize;

    const rows = db.prepare(`
      SELECT s.*, c.name AS category_name, sc.name AS sub_category_name,
        COALESCE(NULLIF(s.seller_avatar, ''), u.avatar) AS seller_avatar_resolved,
        (SELECT MIN(k.price) FROM sku k WHERE k.spu_id = s.id AND k.status = 'on_sale') AS min_price
      FROM spu s
      LEFT JOIN categories c ON c.id = s.category_id
      LEFT JOIN sub_categories sc ON sc.id = s.sub_category_id
      LEFT JOIN users u ON u.id = s.seller_id
      WHERE ${whereClause}
      ORDER BY s.created_at DESC
      LIMIT ? OFFSET ?
    `).all(...params, pageSize, offset) as Record<string, unknown>[];

    const list: SPUDTO[] = rows.map(row => ({
      id: row.id as string,
      title: row.title as string,
      description: (row.description as string) || '',
      images: JSON.parse((row.images as string) || '[]'),
      categoryId: row.category_id as number,
      subCategoryId: (row.sub_category_id as number) || null,
      categoryName: (row.category_name as string) || '',
      subCategoryName: (row.sub_category_name as string) || '',
      brand: (row.brand as string) || '',
      sellerId: row.seller_id as string,
      sellerName: row.seller_name as string,
      sellerAvatar: (row.seller_avatar_resolved as string) || '',
      location: (row.location as string) || '',
      distance: (row.distance as string) || '',
      viewCount: (row.view_count as number) || 0,
      favoriteCount: (row.favorite_count as number) || 0,
      status: row.status as string,
      tags: JSON.parse((row.tags as string) || '[]'),
      minPrice: (row.min_price as number) || 0,
      createdAt: row.created_at as number,
      updatedAt: row.updated_at as number
    }));

    return { list, total: totalRow.count };
  }

  static updateSPU(spuId: string, updates: Record<string, unknown>): SPUWithSKUs | null {
    const existing = db.prepare('SELECT id, seller_id FROM spu WHERE id = ?').get(spuId) as { id: string; seller_id: string } | undefined;
    if (!existing) return null;

    if (updates['removedImages'] && Array.isArray(updates['removedImages'])) {
      const removedImages = updates['removedImages'] as string[];
      for (const url of removedImages) {
        try {
          ObsServiceInstance.deleteObjectByUrl(url);
        } catch (e) {
          console.error('[ProductService] Failed to delete OBS object:', url, e);
        }
      }
    }

    const allowedFields = ['title', 'description', 'images', 'sub_category_id', 'brand', 'location', 'distance', 'tags'];
    const setClauses: string[] = [];
    const values: (string | number)[] = [];

    for (const field of allowedFields) {
      if (updates[field] !== undefined) {
        setClauses.push(`${field} = ?`);
        if (field === 'images' || field === 'tags') {
          values.push(JSON.stringify(updates[field]));
        } else {
          values.push(updates[field] as string | number);
        }
      }
    }

    if (setClauses.length === 0) {
      return ProductService.getSPUDetail(spuId);
    }

    setClauses.push('updated_at = ?');
    values.push(Date.now());
    values.push(spuId);

    db.prepare(`UPDATE spu SET ${setClauses.join(', ')} WHERE id = ?`).run(...values);

    return ProductService.getSPUDetail(spuId);
  }

  static updateSKU(skuId: string, updates: Record<string, unknown>): SKUDTO | null {
    const existing = db.prepare('SELECT id, spu_id FROM sku WHERE id = ?').get(skuId) as { id: string; spu_id: string } | undefined;
    if (!existing) return null;

    const allowedFields = ['price', 'original_price', 'condition', 'sku_code', 'status'];
    const setClauses: string[] = [];
    const values: (string | number)[] = [];

    for (const field of allowedFields) {
      if (updates[field] !== undefined) {
        setClauses.push(`${field} = ?`);
        values.push(updates[field] as string | number);
      }
    }

    if (setClauses.length === 0) {
      return ProductService.getSKUDTO(skuId);
    }

    if (updates.condition !== undefined) {
      const spuRow = db.prepare('SELECT category_id, sub_category_id FROM spu WHERE id = ?').get(existing.spu_id) as { category_id: number; sub_category_id: number | null } | undefined;
      if (spuRow) {
        const carbon = ProductService.calculateCarbonCredits(spuRow.category_id, updates.condition as string, spuRow.sub_category_id || undefined);
        setClauses.push('carbon_reduction = ?', 'carbon_credits = ?');
        values.push(carbon.carbonReduction, carbon.carbonCredits);
      }
    }

    setClauses.push('updated_at = ?');
    values.push(Date.now());
    values.push(skuId);

    db.prepare(`UPDATE sku SET ${setClauses.join(', ')} WHERE id = ?`).run(...values);

    return ProductService.getSKUDTO(skuId);
  }

  static toggleSPUStatus(spuId: string, status: string): void {
    if (![SPUStatus.ON_SALE, SPUStatus.OFF_SALE].includes(status as SPUStatus)) {
      throw new Error('无效的状态，仅允许 on_sale 或 off_sale');
    }

    const now = Date.now();
    db.transaction(() => {
      db.prepare('UPDATE spu SET status = ?, updated_at = ? WHERE id = ?').run(status, now, spuId);
      if (status === SPUStatus.OFF_SALE) {
        db.prepare('UPDATE sku SET status = ?, updated_at = ? WHERE spu_id = ? AND status = \'on_sale\'').run(SKUStatus.OFF_SALE, now, spuId);
      } else if (status === SPUStatus.ON_SALE) {
        db.prepare('UPDATE sku SET status = ?, updated_at = ? WHERE spu_id = ? AND status = \'off_sale\'').run(SKUStatus.ON_SALE, now, spuId);
      }
    })();
  }

  static deleteSPU(spuId: string): void {
    const now = Date.now();
    db.transaction(() => {
      db.prepare('UPDATE spu SET status = ?, updated_at = ? WHERE id = ?').run(SPUStatus.DELETED, now, spuId);
      db.prepare('UPDATE sku SET status = ?, updated_at = ? WHERE spu_id = ?').run(SKUStatus.OFF_SALE, now, spuId);
    })();
  }

  static calculateCarbonCredits(categoryId: number, condition: string, subCategoryId?: number): { carbonReduction: number; carbonCredits: number } {
    const categoryRow = db.prepare('SELECT name FROM categories WHERE id = ?').get(categoryId) as { name: string } | undefined;
    if (!categoryRow) {
      return { carbonReduction: 0, carbonCredits: 0 };
    }

    let carbonRow: { min_reduction: number; max_reduction: number; min_credits: number; max_credits: number } | undefined;

    if (subCategoryId && subCategoryId > 0) {
      const subCategoryRow = db.prepare('SELECT name FROM sub_categories WHERE id = ?').get(subCategoryId) as { name: string } | undefined;
      if (subCategoryRow) {
        carbonRow = db.prepare(
          'SELECT min_reduction, max_reduction, min_credits, max_credits FROM carbon_credit_table WHERE category = ? AND name = ?'
        ).get(categoryRow.name, subCategoryRow.name) as { min_reduction: number; max_reduction: number; min_credits: number; max_credits: number } | undefined;
      }
    }

    if (!carbonRow) {
      const rows = db.prepare(
        'SELECT min_reduction, max_reduction, min_credits, max_credits FROM carbon_credit_table WHERE category = ?'
      ).all(categoryRow.name) as { min_reduction: number; max_reduction: number; min_credits: number; max_credits: number }[];
      if (rows.length === 0) {
        return { carbonReduction: 0, carbonCredits: 0 };
      }
      const avgMinR = rows.reduce((s: number, r: { min_reduction: number }): number => s + r.min_reduction, 0) / rows.length;
      const avgMaxR = rows.reduce((s: number, r: { max_reduction: number }): number => s + r.max_reduction, 0) / rows.length;
      const avgMinC = rows.reduce((s: number, r: { min_credits: number }): number => s + r.min_credits, 0) / rows.length;
      const avgMaxC = rows.reduce((s: number, r: { max_credits: number }): number => s + r.max_credits, 0) / rows.length;
      carbonRow = { min_reduction: avgMinR, max_reduction: avgMaxR, min_credits: avgMinC, max_credits: avgMaxC };
    }

    const factorRow = db.prepare('SELECT factor FROM condition_factors WHERE name = ?').get(condition) as { factor: number } | undefined;
    const factor = factorRow ? factorRow.factor : 0.5;

    const avgReduction = (carbonRow.min_reduction + carbonRow.max_reduction) / 2;
    const avgCredits = (carbonRow.min_credits + carbonRow.max_credits) / 2;
    const carbonReduction = Math.round(avgReduction * factor * 100) / 100;
    const carbonCredits = Math.round(avgCredits * factor * 100) / 100;

    return { carbonReduction, carbonCredits };
  }

  private static buildSPUDTO(spuId: string, params: CreateSPUParams, skus: SKUDTO[], now: number): SPUDTO {
    const minPrice = skus.length > 0 ? Math.min(...skus.map(s => s.price)) : 0;
    const categoryRow = db.prepare('SELECT name FROM categories WHERE id = ?').get(params.categoryId) as { name: string } | undefined;
    const subCategoryRow = params.subCategoryId
      ? db.prepare('SELECT name FROM sub_categories WHERE id = ?').get(params.subCategoryId) as { name: string } | undefined
      : undefined;

    return {
      id: spuId,
      title: params.title,
      description: params.description || '',
      images: params.images || [],
      categoryId: params.categoryId,
      subCategoryId: params.subCategoryId || null,
      categoryName: categoryRow?.name || '',
      subCategoryName: subCategoryRow?.name || '',
      brand: params.brand || '',
      sellerId: params.sellerId,
      sellerName: params.sellerName,
      sellerAvatar: params.sellerAvatar || '',
      location: params.location || '',
      distance: params.distance || '',
      viewCount: 0,
      favoriteCount: 0,
      status: SPUStatus.ON_SALE,
      tags: params.tags || [],
      minPrice,
      createdAt: now,
      updatedAt: now
    };
  }

  private static getSKUDTO(skuId: string): SKUDTO | null {
    const skuRow = db.prepare(`
      SELECT k.*, COALESCE(i.available_stock, 1) AS available_stock
      FROM sku k
      LEFT JOIN inventory i ON i.sku_id = k.id
      WHERE k.id = ?
    `).get(skuId) as Record<string, unknown> | undefined;

    if (!skuRow) return null;

    const specValueRows = db.prepare(`
      SELECT sv.id, sv.spec_name_id, sn.name AS spec_name, sv.value, sv.sort_order
      FROM sku_spec_values ssv
      JOIN spec_values sv ON sv.id = ssv.spec_value_id
      JOIN spec_names sn ON sn.id = sv.spec_name_id
      WHERE ssv.sku_id = ?
    `).all(skuId) as { id: number; spec_name_id: number; spec_name: string; value: string; sort_order: number }[];

    return {
      id: skuRow.id as string,
      spuId: skuRow.spu_id as string,
      price: skuRow.price as number,
      originalPrice: (skuRow.original_price as number) || 0,
      condition: skuRow.condition as string,
      carbonReduction: (skuRow.carbon_reduction as number) || 0,
      carbonCredits: (skuRow.carbon_credits as number) || 0,
      status: skuRow.status as string,
      skuCode: (skuRow.sku_code as string) || '',
      availableStock: (skuRow.available_stock as number) || 0,
      specValues: specValueRows.map(sv => ({
        id: sv.id,
        specNameId: sv.spec_name_id,
        specName: sv.spec_name,
        value: sv.value,
        sortOrder: sv.sort_order
      })),
      createdAt: skuRow.created_at as number,
      updatedAt: skuRow.updated_at as number
    };
  }
}