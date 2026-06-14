import db from '../businessDatabase';

const { v4: uuidv4 } = require('uuid');

export class FavoriteService {
  static toggleFavorite(userId: string, spuId: string): { isFavorited: boolean; favoriteCount: number } {
    const existing = db.prepare('SELECT id FROM favorites WHERE user_id = ? AND product_id = ?')
      .get(userId, spuId) as { id: string } | undefined;

    if (existing) {
      db.prepare('DELETE FROM favorites WHERE id = ?').run(existing.id);
      db.prepare('UPDATE spu SET favorite_count = favorite_count - 1, updated_at = ? WHERE id = ? AND favorite_count > 0')
        .run(Date.now(), spuId);
      const row = db.prepare('SELECT favorite_count FROM spu WHERE id = ?').get(spuId) as { favorite_count: number } | undefined;
      return { isFavorited: false, favoriteCount: row?.favorite_count || 0 };
    } else {
      const id = uuidv4();
      db.prepare('INSERT INTO favorites (id, user_id, product_id, created_at) VALUES (?, ?, ?, ?)')
        .run(id, userId, spuId, Date.now());
      db.prepare('UPDATE spu SET favorite_count = favorite_count + 1, updated_at = ? WHERE id = ?')
        .run(Date.now(), spuId);
      const row = db.prepare('SELECT favorite_count FROM spu WHERE id = ?').get(spuId) as { favorite_count: number } | undefined;
      return { isFavorited: true, favoriteCount: row?.favorite_count || 0 };
    }
  }

  static getUserFavorites(userId: string, page: number = 1, pageSize: number = 20): { list: object[]; total: number } {
    const offset = (page - 1) * pageSize;
    const totalRow = db.prepare('SELECT COUNT(*) as count FROM favorites WHERE user_id = ?').get(userId) as { count: number };
    const total = totalRow.count;

    const rows = db.prepare(`
      SELECT s.id, s.title, s.description, s.images, s.category_id, s.sub_category_id,
        c.name as category_name, sc.name as sub_category_name, s.brand,
        s.seller_id, s.seller_name, s.seller_avatar, s.location, s.distance,
        s.view_count, s.favorite_count, s.status, s.tags, s.created_at, s.updated_at,
        (SELECT MIN(k.price) FROM sku k WHERE k.spu_id = s.id) as min_price,
        f.created_at as favorited_at
      FROM favorites f
      JOIN spu s ON s.id = f.product_id
      LEFT JOIN categories c ON c.id = s.category_id
      LEFT JOIN sub_categories sc ON sc.id = s.sub_category_id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
      LIMIT ? OFFSET ?
    `).all(userId, pageSize, offset) as object[];

    return { list: rows, total };
  }

  static isFavorited(userId: string, spuId: string): boolean {
    const row = db.prepare('SELECT id FROM favorites WHERE user_id = ? AND product_id = ?')
      .get(userId, spuId) as { id: string } | undefined;
    return !!row;
  }

  static getFavoriteCount(userId: string): number {
    const row = db.prepare('SELECT COUNT(*) as count FROM favorites WHERE user_id = ?').get(userId) as { count: number };
    return row.count;
  }
}