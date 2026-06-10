import db from '../database';
import fs from 'fs';
import path from 'path';

interface MockProduct {
  id: string; title: string; price: number; originalPrice: number;
  category: string; condition: string; status: string;
  sellerId: string; sellerName: string;
  viewCount: number; favoriteCount: number; createdAt: number;
}

interface MockOrder {
  id: string; productId: string; productTitle: string; price: number;
  buyerId: string; sellerId: string; status: string;
  createdAt: number; completedAt: number;
}

interface MockUser {
  id: string; nickname: string; creditScore: number;
  creditLevel: string; productCount: number; soldCount: number;
  joinDate: string;
}

interface CreditTx {
  id: string; userId: string; type: string; amount: number;
  timestamp: number;
}

interface CreditAccount {
  userId: string; balance: number; totalEarned: number;
  totalSpent: number; level: string;
}

const MOCK_DIR = path.resolve(__dirname, '../../../entry/src/main/resources/mock');

function readJsonFile<T>(filename: string): T[] {
  const filePath = path.join(MOCK_DIR, filename);
  if (fs.existsSync(filePath)) {
    return JSON.parse(fs.readFileSync(filePath, 'utf-8')) as T[];
  }
  return [];
}

function generateMockProducts(): MockProduct[] {
  const now = Date.now();
  const day = 86400000;
  return [
    { id: 'p001', title: 'iPhone 15 Pro 256GB', price: 6800, originalPrice: 8999, category: '电子产品', condition: '几乎全新', status: 'selling', sellerId: 'u001', sellerName: '小明同学', viewCount: 328, favoriteCount: 45, createdAt: now - 3 * day },
    { id: 'p002', title: 'MacBook Air M2', price: 6500, originalPrice: 8999, category: '电子产品', condition: '几乎全新', status: 'selling', sellerId: 'u002', sellerName: '海淀码农', viewCount: 512, favoriteCount: 67, createdAt: now - 5 * day },
    { id: 'p003', title: '设计心理学（套装4册）', price: 89, originalPrice: 198, category: '图书', condition: '全新', status: 'selling', sellerId: 'u003', sellerName: '阅读者小王', viewCount: 156, favoriteCount: 23, createdAt: now - 2 * day },
    { id: 'p004', title: 'Nike AF1 白色 42码', price: 399, originalPrice: 799, category: '服装', condition: '轻微使用', status: 'selling', sellerId: 'u004', sellerName: '广州潮人', viewCount: 234, favoriteCount: 34, createdAt: now - 4 * day },
    { id: 'p005', title: '小米空气净化器 4 Pro', price: 799, originalPrice: 1499, category: '家居', condition: '正常使用', status: 'selling', sellerId: 'u005', sellerName: '杭州家居控', viewCount: 189, favoriteCount: 28, createdAt: now - 6 * day },
    { id: 'p006', title: 'Sony WH-1000XM5', price: 1799, originalPrice: 2499, category: '数码', condition: '几乎全新', status: 'selling', sellerId: 'u006', sellerName: '数码玩家老张', viewCount: 456, favoriteCount: 89, createdAt: now - 1 * day },
    { id: 'p007', title: '人体工学椅 Ergomax', price: 1200, originalPrice: 2599, category: '办公', condition: '正常使用', status: 'selling', sellerId: 'u007', sellerName: '程序员小陈', viewCount: 267, favoriteCount: 41, createdAt: now - 7 * day },
    { id: 'p008', title: '瑜伽垫 Liforme 6mm', price: 299, originalPrice: 580, category: '运动', condition: '轻微使用', status: 'selling', sellerId: 'u008', sellerName: '瑜伽爱好者', viewCount: 112, favoriteCount: 17, createdAt: now - 2 * day },
    { id: 'p009', title: '富士 X-T5 微单', price: 9500, originalPrice: 13999, category: '数码', condition: '几乎全新', status: 'selling', sellerId: 'u009', sellerName: '摄影爱好者', viewCount: 678, favoriteCount: 112, createdAt: now - 4 * day },
    { id: 'p010', title: '北面 1996 羽绒服 L码', price: 899, originalPrice: 1899, category: '服装', condition: '轻微使用', status: 'selling', sellerId: 'u010', sellerName: '朝阳群众', viewCount: 345, favoriteCount: 56, createdAt: now - 8 * day },
  ];
}

function generateMockOrders(): MockOrder[] {
  const now = Date.now();
  const day = 86400000;
  return [
    { id: 'ord001', productId: 'p001', productTitle: 'iPhone 15 Pro', price: 6800, buyerId: 'u000', sellerId: 'u001', status: 'pending_payment', createdAt: now - 2 * 3600000, completedAt: 0 },
    { id: 'ord002', productId: 'p004', productTitle: 'Nike AF1', price: 399, buyerId: 'u000', sellerId: 'u004', status: 'pending_shipment', createdAt: now - 1 * day, completedAt: 0 },
    { id: 'ord003', productId: 'p006', productTitle: 'Sony XM5', price: 1799, buyerId: 'u000', sellerId: 'u006', status: 'shipped', createdAt: now - 3 * day, completedAt: 0 },
    { id: 'ord004', productId: 'p010', productTitle: '北面羽绒服', price: 899, buyerId: 'u000', sellerId: 'u010', status: 'shipped', createdAt: now - 5 * day, completedAt: 0 },
    { id: 'ord005', productId: 'p002', productTitle: 'MacBook Air M2', price: 6500, buyerId: 'u000', sellerId: 'u002', status: 'completed', createdAt: now - 15 * day, completedAt: now - 10 * day },
    { id: 'ord006', productId: 'p007', productTitle: '人体工学椅', price: 1200, buyerId: 'u000', sellerId: 'u007', status: 'cancelled', createdAt: now - 20 * day, completedAt: 0 },
  ];
}

function generateMockUsers(): MockUser[] {
  return [
    { id: 'u000', nickname: '碳易用户', creditScore: 98, creditLevel: '良好', productCount: 3, soldCount: 5, joinDate: '2024-01-15' },
    { id: 'u001', nickname: '小明同学', creditScore: 95, creditLevel: '优秀', productCount: 2, soldCount: 1, joinDate: '2024-02-20' },
    { id: 'u002', nickname: '海淀码农', creditScore: 88, creditLevel: '良好', productCount: 1, soldCount: 1, joinDate: '2024-03-10' },
    { id: 'u003', nickname: '阅读者小王', creditScore: 92, creditLevel: '良好', productCount: 1, soldCount: 0, joinDate: '2024-04-05' },
    { id: 'u004', nickname: '广州潮人', creditScore: 85, creditLevel: '一般', productCount: 1, soldCount: 0, joinDate: '2024-05-01' },
    { id: 'u005', nickname: '杭州家居控', creditScore: 78, creditLevel: '一般', productCount: 1, soldCount: 0, joinDate: '2024-06-15' },
    { id: 'u006', nickname: '数码玩家老张', creditScore: 96, creditLevel: '优秀', productCount: 1, soldCount: 0, joinDate: '2024-07-20' },
    { id: 'u007', nickname: '程序员小陈', creditScore: 82, creditLevel: '一般', productCount: 1, soldCount: 0, joinDate: '2024-08-10' },
    { id: 'u008', nickname: '瑜伽爱好者', creditScore: 90, creditLevel: '良好', productCount: 1, soldCount: 0, joinDate: '2024-09-01' },
    { id: 'u009', nickname: '摄影爱好者', creditScore: 94, creditLevel: '优秀', productCount: 1, soldCount: 0, joinDate: '2024-10-15' },
    { id: 'u010', nickname: '朝阳群众', creditScore: 87, creditLevel: '良好', productCount: 1, soldCount: 0, joinDate: '2024-11-01' },
  ];
}

function generateMockCreditTransactions(): CreditTx[] {
  const now = Date.now();
  const day = 86400000;
  return [
    { id: 'ctx01', userId: 'u000', type: 'TRADE_REWARD', amount: 30, timestamp: now - 10 * day },
    { id: 'ctx02', userId: 'u000', type: 'TRADE_REWARD', amount: 20, timestamp: now - 10 * day },
    { id: 'ctx03', userId: 'u000', type: 'PUBLISH_REWARD', amount: 10, timestamp: now - 3 * day },
    { id: 'ctx04', userId: 'u000', type: 'PUBLISH_REWARD', amount: 10, timestamp: now - 5 * day },
    { id: 'ctx05', userId: 'u000', type: 'ACHIEVEMENT_REWARD', amount: 20, timestamp: now - 10 * day },
    { id: 'ctx06', userId: 'u000', type: 'EXCHANGE_DEDUCT', amount: -50, timestamp: now - 8 * day },
    { id: 'ctx07', userId: 'u001', type: 'TRADE_REWARD', amount: 20, timestamp: now - 10 * day },
    { id: 'ctx08', userId: 'u001', type: 'PUBLISH_REWARD', amount: 10, timestamp: now - 3 * day },
    { id: 'ctx09', userId: 'u002', type: 'TRADE_REWARD', amount: 20, timestamp: now - 15 * day },
    { id: 'ctx10', userId: 'u002', type: 'PUBLISH_REWARD', amount: 10, timestamp: now - 5 * day },
    { id: 'ctx11', userId: 'u006', type: 'PUBLISH_REWARD', amount: 10, timestamp: now - 1 * day },
    { id: 'ctx12', userId: 'u009', type: 'PUBLISH_REWARD', amount: 10, timestamp: now - 4 * day },
  ];
}

function generateMockCreditAccounts(): CreditAccount[] {
  return [
    { userId: 'u000', balance: 40, totalEarned: 90, totalSpent: 50, level: '环保达人' },
    { userId: 'u001', balance: 30, totalEarned: 30, totalSpent: 0, level: '环保达人' },
    { userId: 'u002', balance: 30, totalEarned: 30, totalSpent: 0, level: '环保达人' },
    { userId: 'u006', balance: 10, totalEarned: 10, totalSpent: 0, level: '环保新手' },
    { userId: 'u009', balance: 10, totalEarned: 10, totalSpent: 0, level: '环保新手' },
  ];
}

export class DataAggregationService {
  static aggregateAll(): void {
    const products = generateMockProducts();
    const orders = generateMockOrders();
    const users = generateMockUsers();
    const creditTxs = generateMockCreditTransactions();
    const creditAccounts = generateMockCreditAccounts();

    DataAggregationService.aggregateUserGrowth(users);
    DataAggregationService.aggregateProductTrend(products);
    DataAggregationService.aggregateTransaction(orders);
    DataAggregationService.aggregateCreditTrend(creditTxs, creditAccounts);
  }

  private static aggregateUserGrowth(users: MockUser[]): void {
    const now = new Date();
    const dayMs = 86400000;
    const data: { date: string; count: number }[] = [];

    for (let i = 29; i >= 0; i--) {
      const d = new Date(now.getTime() - i * dayMs);
      const dateStr = d.toISOString().slice(0, 10);
      const count = users.filter(u => {
        const joinDate = new Date(u.joinDate);
        return joinDate.toISOString().slice(0, 10) === dateStr;
      }).length;
      data.push({ date: dateStr, count });
    }

    const insert = db.prepare(
      'INSERT OR REPLACE INTO data_reports (reportType, timeRange, granularity, data, generatedAt) VALUES (?, ?, ?, ?, ?)'
    );
    insert.run('USER_GROWTH', '30d', 'DAILY', JSON.stringify(data), Date.now());
  }

  private static aggregateProductTrend(products: MockProduct[]): void {
    const now = new Date();
    const dayMs = 86400000;
    const data: { date: string; count: number }[] = [];

    for (let i = 29; i >= 0; i--) {
      const d = new Date(now.getTime() - i * dayMs);
      const dateStr = d.toISOString().slice(0, 10);
      const dayStart = d.getTime();
      const dayEnd = dayStart + dayMs;
      const count = products.filter(p => p.createdAt >= dayStart && p.createdAt < dayEnd).length;
      data.push({ date: dateStr, count });
    }

    const insert = db.prepare(
      'INSERT OR REPLACE INTO data_reports (reportType, timeRange, granularity, data, generatedAt) VALUES (?, ?, ?, ?, ?)'
    );
    insert.run('PRODUCT_TREND', '30d', 'DAILY', JSON.stringify(data), Date.now());
  }

  private static aggregateTransaction(orders: MockOrder[]): void {
    const now = new Date();
    const dayMs = 86400000;
    const data: { date: string; count: number; amount: number }[] = [];

    for (let i = 29; i >= 0; i--) {
      const d = new Date(now.getTime() - i * dayMs);
      const dateStr = d.toISOString().slice(0, 10);
      const dayStart = d.getTime();
      const dayEnd = dayStart + dayMs;
      const dayOrders = orders.filter(o => o.createdAt >= dayStart && o.createdAt < dayEnd);
      const completedOrders = dayOrders.filter(o => o.status === 'completed');
      data.push({
        date: dateStr,
        count: completedOrders.length,
        amount: completedOrders.reduce((sum, o) => sum + o.price, 0)
      });
    }

    const insert = db.prepare(
      'INSERT OR REPLACE INTO data_reports (reportType, timeRange, granularity, data, generatedAt) VALUES (?, ?, ?, ?, ?)'
    );
    insert.run('TRANSACTION', '30d', 'DAILY', JSON.stringify(data), Date.now());
  }

  private static aggregateCreditTrend(creditTxs: CreditTx[], creditAccounts: CreditAccount[]): void {
    const now = new Date();
    const dayMs = 86400000;
    const data: { date: string; earned: number; spent: number }[] = [];

    for (let i = 29; i >= 0; i--) {
      const d = new Date(now.getTime() - i * dayMs);
      const dateStr = d.toISOString().slice(0, 10);
      const dayStart = d.getTime();
      const dayEnd = dayStart + dayMs;
      const dayTxs = creditTxs.filter(tx => tx.timestamp >= dayStart && tx.timestamp < dayEnd);
      const earned = dayTxs.filter(tx => tx.amount > 0).reduce((sum, tx) => sum + tx.amount, 0);
      const spent = dayTxs.filter(tx => tx.amount < 0).reduce((sum, tx) => sum + Math.abs(tx.amount), 0);
      data.push({ date: dateStr, earned, spent });
    }

    const insert = db.prepare(
      'INSERT OR REPLACE INTO data_reports (reportType, timeRange, granularity, data, generatedAt) VALUES (?, ?, ?, ?, ?)'
    );
    insert.run('CARBON_CREDIT', '30d', 'DAILY', JSON.stringify(data), Date.now());
  }
}