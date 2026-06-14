import db from '../businessDatabase';
import { MigrationResult, MigrationStatus } from '../models/Product';

const { v4: uuidv4 } = require('uuid');

export class MigrationService {
  static migrate(): MigrationResult {
    const existingSPU = db.prepare('SELECT COUNT(*) as count FROM spu WHERE status != \'deleted\'').get() as { count: number };
    if (existingSPU.count > 0) {
      const skuCount = db.prepare('SELECT COUNT(*) as count FROM sku').get() as { count: number };
      if (skuCount.count > 0) {
        throw new Error('数据已迁移，请勿重复执行');
      }
    }

    const products = db.prepare('SELECT * FROM products').all() as Record<string, unknown>[];
    if (products.length === 0) {
      return { spuCount: 0, skuCount: 0, orderUpdateCount: 0, errors: [] };
    }

    const errors: string[] = [];
    let spuCount = 0;
    let skuCount = 0;
    let orderUpdateCount = 0;

    const now = Date.now();

    db.transaction(() => {
      for (const p of products) {
        try {
          const productId = p.id as string;
          const categoryText = p.category as string;
          const subCategoryText = p.sub_category as string;
          const oldStatus = p.status as string;

          const categoryRow = db.prepare('SELECT id FROM categories WHERE name = ?').get(categoryText) as { id: number } | undefined;
          let categoryId = categoryRow?.id || 1;

          let subCategoryId = 0;
          if (subCategoryText && categoryRow) {
            const subCatRow = db.prepare('SELECT id FROM sub_categories WHERE parent_id = ? AND name = ?').get(categoryRow.id, subCategoryText) as { id: number } | undefined;
            subCategoryId = subCatRow?.id || 0;
          }

          let newStatus = 'on_sale';
          if (oldStatus === 'sold') newStatus = 'sold_out';
          else if (oldStatus === 'removed') newStatus = 'off_sale';

          db.prepare(`
            INSERT INTO spu (id, title, description, images, category_id, sub_category_id, brand,
              seller_id, seller_name, seller_avatar, location, distance, view_count, favorite_count,
              status, tags, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `).run(
            productId, p.title, p.description || '', p.images || '[]',
            categoryId, subCategoryId, p.brand || '',
            p.seller_id, p.seller_name, p.seller_avatar || '',
            p.location || '', p.distance || '',
            p.view_count || 0, p.favorite_count || 0,
            newStatus, p.tags || '[]',
            p.created_at || now, p.updated_at || now
          );
          spuCount++;

          const skuId = uuidv4();
          db.prepare(`
            INSERT INTO sku (id, spu_id, price, original_price, condition, carbon_reduction, carbon_credits,
              status, sku_code, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `).run(
            skuId, productId, p.price || 0, p.original_price || 0,
            p.condition || '', p.carbon_reduction || 0, p.carbon_credits || 0,
            newStatus === 'sold_out' ? 'sold_out' : (newStatus === 'off_sale' ? 'off_sale' : 'on_sale'),
            '', p.created_at || now, p.updated_at || now
          );
          skuCount++;

          db.prepare(`
            INSERT INTO inventory (sku_id, total_stock, available_stock, locked_stock, created_at, updated_at)
            VALUES (?, 1, 1, 0, ?, ?)
          `).run(skuId, now, now);

          const conditionText = p.condition as string;
          if (conditionText) {
            const specValueRow = db.prepare(`
              SELECT sv.id FROM spec_values sv
              JOIN spec_names sn ON sn.id = sv.spec_name_id
              WHERE sv.value = ? AND sn.name = '成色'
            `).get(conditionText) as { id: number } | undefined;
            if (specValueRow) {
              db.prepare('INSERT INTO sku_spec_values (sku_id, spec_value_id) VALUES (?, ?)').run(skuId, specValueRow.id);
            }
          }

          const orderChanges = db.prepare('UPDATE orders SET product_id = ? WHERE product_id = ?').run(skuId, productId);
          orderUpdateCount += orderChanges.changes;

        } catch (err) {
          errors.push(`产品 ${p.id}: ${err instanceof Error ? err.message : String(err)}`);
        }
      }
    })();

    return { spuCount, skuCount, orderUpdateCount, errors };
  }

  static rollback(): void {
    db.transaction(() => {
      const skuRows = db.prepare('SELECT id, spu_id FROM sku').all() as { id: string; spu_id: string }[];
      for (const sku of skuRows) {
        db.prepare('UPDATE orders SET product_id = ? WHERE product_id = ?').run(sku.spu_id, sku.id);
      }

      db.prepare('DELETE FROM sku_spec_values').run();
      db.prepare('DELETE FROM inventory').run();
      db.prepare('DELETE FROM product_attributes').run();
      db.prepare('DELETE FROM sku').run();
      db.prepare('DELETE FROM spu').run();
    })();
  }

  static getStatus(): MigrationStatus {
    const spuCount = db.prepare('SELECT COUNT(*) as count FROM spu').get() as { count: number };
    const skuCount = db.prepare('SELECT COUNT(*) as count FROM sku').get() as { count: number };
    const migrated = spuCount.count > 0 && skuCount.count > 0;

    let migratedAt: number | null = null;
    if (migrated) {
      const oldestSPU = db.prepare('SELECT MIN(created_at) as created_at FROM spu').get() as { created_at: number | null };
      migratedAt = oldestSPU?.created_at || null;
    }

    return {
      migrated,
      spuCount: spuCount.count,
      skuCount: skuCount.count,
      migratedAt
    };
  }
}