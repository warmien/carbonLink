import db from '../businessDatabase';

const { v4: uuidv4 } = require('uuid');

export interface CreateOrderParams {
  spuId: string;
  skuId?: string;
  buyerId: string;
  paymentMethod: string;
}

export interface OrderDTO {
  id: string;
  spuId: string;
  skuId: string;
  productTitle: string;
  productImage: string;
  price: number;
  originalPrice: number;
  carbonReduction: number;
  carbonCredits: number;
  buyerId: string;
  sellerId: string;
  buyerName: string;
  sellerName: string;
  status: string;
  paymentMethod: string;
  createdAt: number;
  paidAt: number;
}

export class OrderService {
  static createOrder(params: CreateOrderParams): OrderDTO {
    const { spuId, skuId, buyerId, paymentMethod } = params;

    const spuRow = db.prepare('SELECT * FROM spu WHERE id = ? AND status = ?').get(spuId, 'on_sale') as Record<string, unknown> | undefined;
    if (!spuRow) {
      throw new Error('商品不存在或已下架');
    }

    if ((spuRow.seller_id as string) === buyerId) {
      throw new Error('不能购买自己发布的商品');
    }

    let skuRow: Record<string, unknown> | undefined;
    if (skuId) {
      skuRow = db.prepare('SELECT * FROM sku WHERE id = ? AND spu_id = ? AND status = ?').get(skuId, spuId, 'on_sale') as Record<string, unknown> | undefined;
    }
    if (!skuRow) {
      skuRow = db.prepare('SELECT * FROM sku WHERE spu_id = ? AND status = ? LIMIT 1').get(spuId, 'on_sale') as Record<string, unknown> | undefined;
    }
    if (!skuRow) {
      throw new Error('商品已售罄');
    }

    const buyerRow = db.prepare('SELECT id, nickname FROM users WHERE id = ?').get(buyerId) as { id: string; nickname: string } | undefined;
    if (!buyerRow) {
      throw new Error('买家不存在');
    }

    const orderId = 'ord_' + uuidv4().replace(/-/g, '').substring(0, 12);
    const now = Date.now();
    const price = skuRow.price as number;
    const originalPrice = (skuRow.original_price as number) || price;
    const carbonReduction = (skuRow.carbon_reduction as number) || 0;
    const carbonCredits = (skuRow.carbon_credits as number) || 0;

    let productImage = '';
    try {
      const images = JSON.parse((spuRow.images as string) || '[]');
      if (images.length > 0) productImage = images[0];
    } catch (e) { }

    const transaction = db.transaction(() => {
      db.prepare(`
        INSERT INTO orders (id, product_id, product_title, product_image, price, buyer_id, seller_id, buyer_name, seller_name, status, created_at, paid_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).run(
        orderId, spuId, spuRow.title as string, productImage, price,
        buyerId, spuRow.seller_id as string, buyerRow.nickname, spuRow.seller_name as string,
        'pending_payment', now, now
      );

      db.prepare('UPDATE sku SET status = ?, updated_at = ? WHERE id = ?').run('sold_out', now, skuRow.id as string);

      const remainingOnSale = db.prepare('SELECT COUNT(*) as c FROM sku WHERE spu_id = ? AND status = ?').get(spuId, 'on_sale') as { c: number };
      if (remainingOnSale.c === 0) {
        db.prepare('UPDATE spu SET status = ?, updated_at = ? WHERE id = ?').run('sold_out', now, spuId);
      }

      db.prepare('UPDATE users SET sold_count = sold_count + 1, updated_at = ? WHERE id = ?').run(now, spuRow.seller_id as string);

      return orderId;
    });

    const resultId = transaction();

    return {
      id: resultId,
      spuId,
      skuId: skuRow.id as string,
      productTitle: spuRow.title as string,
      productImage,
      price,
      originalPrice,
      carbonReduction,
      carbonCredits,
      buyerId,
      sellerId: spuRow.seller_id as string,
      buyerName: buyerRow.nickname,
      sellerName: spuRow.seller_name as string,
      status: 'pending_payment',
      paymentMethod: paymentMethod || 'wechat',
      createdAt: now,
      paidAt: now
    };
  }

  static getBuyerOrders(buyerId: string, status?: string): OrderDTO[] {
    let sql = `
      SELECT o.*, s.images as spu_images
      FROM orders o
      LEFT JOIN spu s ON s.id = o.product_id
      WHERE o.buyer_id = ?
    `;
    const params: (string | number)[] = [buyerId];
    if (status) {
      sql += ' AND o.status = ?';
      params.push(status);
    }
    sql += ' ORDER BY o.created_at DESC';

    const rows = db.prepare(sql).all(...params) as Record<string, unknown>[];
    return rows.map(r => ({
      id: r.id as string,
      spuId: r.product_id as string,
      skuId: '',
      productTitle: r.product_title as string,
      productImage: r.product_image as string || '',
      price: r.price as number,
      originalPrice: r.price as number,
      carbonReduction: 0,
      carbonCredits: 0,
      buyerId: r.buyer_id as string,
      sellerId: r.seller_id as string,
      buyerName: r.buyer_name as string,
      sellerName: r.seller_name as string,
      status: r.status as string,
      paymentMethod: '',
      createdAt: r.created_at as number,
      paidAt: r.paid_at as number
    }));
  }

  static getSellerOrders(sellerId: string, status?: string): OrderDTO[] {
    let sql = `
      SELECT o.* FROM orders o
      WHERE o.seller_id = ?
    `;
    const params: (string | number)[] = [sellerId];
    if (status) {
      sql += ' AND o.status = ?';
      params.push(status);
    }
    sql += ' ORDER BY o.created_at DESC';

    const rows = db.prepare(sql).all(...params) as Record<string, unknown>[];
    return rows.map(r => ({
      id: r.id as string,
      spuId: r.product_id as string,
      skuId: '',
      productTitle: r.product_title as string,
      productImage: r.product_image as string || '',
      price: r.price as number,
      originalPrice: r.price as number,
      carbonReduction: 0,
      carbonCredits: 0,
      buyerId: r.buyer_id as string,
      sellerId: r.seller_id as string,
      buyerName: r.buyer_name as string,
      sellerName: r.seller_name as string,
      status: r.status as string,
      paymentMethod: '',
      createdAt: r.created_at as number,
      paidAt: r.paid_at as number
    }));
  }

  static confirmReceive(orderId: string, userId: string): OrderDTO {
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND buyer_id = ?').get(orderId, userId) as Record<string, unknown> | undefined;
    if (!order) throw new Error('订单不存在');
    if ((order.status as string) !== 'shipped') throw new Error('订单状态不正确');

    const now = Date.now();
    db.prepare('UPDATE orders SET status = ?, received_at = ? WHERE id = ?').run('completed', now, orderId);

    return {
      id: orderId,
      spuId: order.product_id as string,
      skuId: '',
      productTitle: order.product_title as string,
      productImage: order.product_image as string || '',
      price: order.price as number,
      originalPrice: order.price as number,
      carbonReduction: 0,
      carbonCredits: 0,
      buyerId: order.buyer_id as string,
      sellerId: order.seller_id as string,
      buyerName: order.buyer_name as string,
      sellerName: order.seller_name as string,
      status: 'completed',
      paymentMethod: '',
      createdAt: order.created_at as number,
      paidAt: order.paid_at as number
    };
  }

  static shipOrder(orderId: string, sellerId: string, trackingNumber: string): OrderDTO {
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND seller_id = ?').get(orderId, sellerId) as Record<string, unknown> | undefined;
    if (!order) throw new Error('订单不存在');
    if ((order.status as string) !== 'pending_payment' && (order.status as string) !== 'paid') throw new Error('订单状态不正确');

    const now = Date.now();
    db.prepare('UPDATE orders SET status = ?, shipped_at = ?, tracking_number = ? WHERE id = ?').run('shipped', now, trackingNumber || '', orderId);

    return {
      id: orderId,
      spuId: order.product_id as string,
      skuId: '',
      productTitle: order.product_title as string,
      productImage: order.product_image as string || '',
      price: order.price as number,
      originalPrice: order.price as number,
      carbonReduction: 0,
      carbonCredits: 0,
      buyerId: order.buyer_id as string,
      sellerId: order.seller_id as string,
      buyerName: order.buyer_name as string,
      sellerName: order.seller_name as string,
      status: 'shipped',
      paymentMethod: '',
      createdAt: order.created_at as number,
      paidAt: order.paid_at as number
    };
  }

  static cancelOrder(orderId: string, userId: string): OrderDTO {
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND buyer_id = ?').get(orderId, userId) as Record<string, unknown> | undefined;
    if (!order) throw new Error('订单不存在');
    const currentStatus = order.status as string;
    if (currentStatus !== 'pending_payment') throw new Error('只能取消待付款订单');

    const now = Date.now();
    db.prepare('UPDATE orders SET status = ?, cancelled_at = ? WHERE id = ?').run('cancelled', now, orderId);

    const skuId = order.sku_id as string || '';
    if (skuId) {
      db.prepare('UPDATE sku SET status = ?, updated_at = ? WHERE id = ?').run('on_sale', now, skuId);
    }
    db.prepare('UPDATE spu SET status = ?, updated_at = ? WHERE id = ?').run('on_sale', now, order.product_id as string);

    return {
      id: orderId,
      spuId: order.product_id as string,
      skuId: '',
      productTitle: order.product_title as string,
      productImage: order.product_image as string || '',
      price: order.price as number,
      originalPrice: order.price as number,
      carbonReduction: 0,
      carbonCredits: 0,
      buyerId: order.buyer_id as string,
      sellerId: order.seller_id as string,
      buyerName: order.buyer_name as string,
      sellerName: order.seller_name as string,
      status: 'cancelled',
      paymentMethod: '',
      createdAt: order.created_at as number,
      paidAt: order.paid_at as number
    };
  }

  static payOrder(orderId: string, userId: string): OrderDTO {
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND buyer_id = ?').get(orderId, userId) as Record<string, unknown> | undefined;
    if (!order) throw new Error('订单不存在');
    if ((order.status as string) !== 'pending_payment') throw new Error('订单状态不正确');

    const now = Date.now();
    db.prepare('UPDATE orders SET status = ?, paid_at = ? WHERE id = ?').run('pending_shipment', now, orderId);

    return {
      id: orderId,
      spuId: order.product_id as string,
      skuId: '',
      productTitle: order.product_title as string,
      productImage: order.product_image as string || '',
      price: order.price as number,
      originalPrice: order.price as number,
      carbonReduction: 0,
      carbonCredits: 0,
      buyerId: order.buyer_id as string,
      sellerId: order.seller_id as string,
      buyerName: order.buyer_name as string,
      sellerName: order.seller_name as string,
      status: 'pending_shipment',
      paymentMethod: '',
      createdAt: order.created_at as number,
      paidAt: now
    };
  }
}