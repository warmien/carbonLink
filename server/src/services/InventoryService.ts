import db from '../businessDatabase';
import { InventoryDTO } from '../models/Product';

export class InventoryService {
  static deductStock(skuId: string, quantity: number): { success: boolean; message: string } {
    if (quantity <= 0) {
      return { success: false, message: '扣减数量必须大于0' };
    }

    const now = Date.now();
    const result = db.transaction(() => {
      const changes = db.prepare(`
        UPDATE inventory
        SET available_stock = available_stock - ?,
            updated_at = ?
        WHERE sku_id = ? AND available_stock >= ?
      `).run(quantity, now, skuId, quantity);

      return changes.changes;
    })();

    if (result === 0) {
      return { success: false, message: '库存不足' };
    }
    return { success: true, message: '扣减成功' };
  }

  static rollbackStock(skuId: string, quantity: number): void {
    if (quantity <= 0) return;

    const now = Date.now();
    db.transaction(() => {
      db.prepare(`
        UPDATE inventory
        SET available_stock = available_stock + ?,
            updated_at = ?
        WHERE sku_id = ?
      `).run(quantity, now, skuId);
    })();
  }

  static lockStock(skuId: string, quantity: number): { success: boolean; message: string } {
    if (quantity <= 0) {
      return { success: false, message: '锁定数量必须大于0' };
    }

    const now = Date.now();
    const result = db.transaction(() => {
      const changes = db.prepare(`
        UPDATE inventory
        SET available_stock = available_stock - ?,
            locked_stock = locked_stock + ?,
            updated_at = ?
        WHERE sku_id = ? AND available_stock >= ?
      `).run(quantity, quantity, now, skuId, quantity);

      return changes.changes;
    })();

    if (result === 0) {
      return { success: false, message: '可用库存不足' };
    }
    return { success: true, message: '锁定成功' };
  }

  static unlockStock(skuId: string, quantity: number): void {
    if (quantity <= 0) return;

    const now = Date.now();
    db.transaction(() => {
      db.prepare(`
        UPDATE inventory
        SET locked_stock = locked_stock - ?,
            available_stock = available_stock + ?,
            updated_at = ?
        WHERE sku_id = ? AND locked_stock >= ?
      `).run(quantity, quantity, now, skuId, quantity);
    })();
  }

  static getInventory(skuId: string): InventoryDTO | null {
    const row = db.prepare('SELECT * FROM inventory WHERE sku_id = ?').get(skuId) as Record<string, unknown> | undefined;
    if (!row) return null;

    return {
      id: row.id as number,
      skuId: row.sku_id as string,
      totalStock: row.total_stock as number,
      availableStock: row.available_stock as number,
      lockedStock: row.locked_stock as number,
      createdAt: row.created_at as number,
      updatedAt: row.updated_at as number
    };
  }
}