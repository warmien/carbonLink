import db from '../database';

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

const CARBON_REDUCTION_PER_TRADE_KG = 2.5;

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

function getTimeRange(startDate?: string, endDate?: string): { start: number; end: number } {
  const now = Date.now();
  const dayMs = 86400000;
  if (startDate && endDate) {
    return { start: new Date(startDate).getTime(), end: new Date(endDate).getTime() + dayMs };
  }
  return { start: now - 30 * dayMs, end: now };
}

export class DataQueryService {
  static getDashboardOverview(): Record<string, unknown> {
    const users = generateMockUsers();
    const orders = generateMockOrders();
    const products = generateMockProducts();
    const creditTxs = generateMockCreditTransactions();

    const now = Date.now();
    const dayMs = 86400000;
    const todayStart = now - (now % dayMs);

    const todayNewUsers = users.filter(u => new Date(u.joinDate).getTime() >= todayStart).length;
    const todayOrders = orders.filter(o => o.createdAt >= todayStart).length;
    const todayCreditEarned = creditTxs
      .filter(tx => tx.timestamp >= todayStart && tx.amount > 0)
      .reduce((sum, tx) => sum + tx.amount, 0);

    return {
      dau: users.length,
      todayNewUsers,
      totalProducts: products.length,
      todayOrders,
      totalOrders: orders.length,
      todayCreditEarned,
      totalCreditEarned: creditTxs.filter(tx => tx.amount > 0).reduce((sum, tx) => sum + tx.amount, 0)
    };
  }

  static getDashboardTrend(days: number = 7): Record<string, unknown>[] {
    const row = db.prepare(
      'SELECT data FROM data_reports WHERE reportType = ? ORDER BY generatedAt DESC LIMIT 1'
    ).get('USER_GROWTH') as { data: string } | undefined;

    if (row) {
      const data = JSON.parse(row.data) as Record<string, unknown>[];
      return data.slice(-days);
    }
    return [];
  }

  static getUserGrowth(startDate?: string, endDate?: string): Record<string, unknown> {
    const range = getTimeRange(startDate, endDate);
    const users = generateMockUsers();
    const dayMs = 86400000;

    const trend: { date: string; count: number }[] = [];
    for (let t = range.start; t < range.end; t += dayMs) {
      const dateStr = new Date(t).toISOString().slice(0, 10);
      const count = users.filter(u => new Date(u.joinDate).toISOString().slice(0, 10) === dateStr).length;
      trend.push({ date: dateStr, count });
    }

    return { trend, totalUsers: users.length };
  }

  static getUserActive(): Record<string, unknown> {
    const users = generateMockUsers();
    return {
      dau: users.length,
      mau: users.length,
      dauMauRatio: 1.0
    };
  }

  static getUserRetention(): Record<string, unknown> {
    return {
      nextDay: 0.45,
      day7: 0.28,
      day30: 0.15
    };
  }

  static getUserLevelDistribution(): Record<string, unknown> {
    const users = generateMockUsers();
    const distribution: Record<string, number> = {};
    for (const u of users) {
      distribution[u.creditLevel] = (distribution[u.creditLevel] || 0) + 1;
    }
    return { distribution };
  }

  static getUserFunnel(): Record<string, unknown> {
    return {
      steps: [
        { name: '注册', count: 11 },
        { name: '首次浏览', count: 9 },
        { name: '首次收藏', count: 5 },
        { name: '首次购买', count: 2 }
      ]
    };
  }

  static getUserList(page: number = 1, pageSize: number = 20): Record<string, unknown> {
    const users = generateMockUsers();
    const start = (page - 1) * pageSize;
    return {
      list: users.slice(start, start + pageSize),
      total: users.length,
      page,
      pageSize
    };
  }

  static getProductTrend(startDate?: string, endDate?: string): Record<string, unknown> {
    const range = getTimeRange(startDate, endDate);
    const products = generateMockProducts();
    const dayMs = 86400000;

    const trend: { date: string; count: number }[] = [];
    for (let t = range.start; t < range.end; t += dayMs) {
      const dateStr = new Date(t).toISOString().slice(0, 10);
      const dayStart = t;
      const dayEnd = t + dayMs;
      const count = products.filter(p => p.createdAt >= dayStart && p.createdAt < dayEnd).length;
      trend.push({ date: dateStr, count });
    }

    return { trend, totalProducts: products.length };
  }

  static getProductTransaction(): Record<string, unknown> {
    const orders = generateMockOrders();
    const completedOrders = orders.filter(o => o.status === 'completed');
    return {
      totalOrders: orders.length,
      completedOrders: completedOrders.length,
      completedAmount: completedOrders.reduce((sum, o) => sum + o.price, 0),
      completionRate: orders.length > 0 ? completedOrders.length / orders.length : 0
    };
  }

  static getProductCategoryDistribution(): Record<string, unknown> {
    const products = generateMockProducts();
    const distribution: Record<string, number> = {};
    for (const p of products) {
      distribution[p.category] = (distribution[p.category] || 0) + 1;
    }
    return { distribution };
  }

  static getProductPriceDistribution(): Record<string, unknown> {
    const products = generateMockProducts();
    const ranges = { '0-100': 0, '100-500': 0, '500-1000': 0, '1000-5000': 0, '5000+': 0 };
    for (const p of products) {
      if (p.price <= 100) ranges['0-100']++;
      else if (p.price <= 500) ranges['100-500']++;
      else if (p.price <= 1000) ranges['500-1000']++;
      else if (p.price <= 5000) ranges['1000-5000']++;
      else ranges['5000+']++;
    }
    return { distribution: ranges };
  }

  static getProductConditionDistribution(): Record<string, unknown> {
    const products = generateMockProducts();
    const distribution: Record<string, number> = {};
    for (const p of products) {
      distribution[p.condition] = (distribution[p.condition] || 0) + 1;
    }
    return { distribution };
  }

  static getProductHotRanking(metric: string = 'viewCount', limit: number = 10): Record<string, unknown> {
    const products = generateMockProducts();
    const sorted = [...products].sort((a, b) => {
      if (metric === 'favoriteCount') return b.favoriteCount - a.favoriteCount;
      return b.viewCount - a.viewCount;
    });
    return { ranking: sorted.slice(0, limit).map((p, i) => ({
      rank: i + 1, id: p.id, title: p.title,
      value: metric === 'favoriteCount' ? p.favoriteCount : p.viewCount
    }))};
  }

  static getProductList(page: number = 1, pageSize: number = 20): Record<string, unknown> {
    const products = generateMockProducts();
    const start = (page - 1) * pageSize;
    return {
      list: products.slice(start, start + pageSize),
      total: products.length,
      page,
      pageSize
    };
  }

  static getCarbonCreditTrend(startDate?: string, endDate?: string): Record<string, unknown> {
    const range = getTimeRange(startDate, endDate);
    const creditTxs = generateMockCreditTransactions();
    const dayMs = 86400000;

    const trend: { date: string; earned: number; spent: number }[] = [];
    for (let t = range.start; t < range.end; t += dayMs) {
      const dateStr = new Date(t).toISOString().slice(0, 10);
      const dayStart = t;
      const dayEnd = t + dayMs;
      const dayTxs = creditTxs.filter(tx => tx.timestamp >= dayStart && tx.timestamp < dayEnd);
      const earned = dayTxs.filter(tx => tx.amount > 0).reduce((sum, tx) => sum + tx.amount, 0);
      const spent = dayTxs.filter(tx => tx.amount < 0).reduce((sum, tx) => sum + Math.abs(tx.amount), 0);
      trend.push({ date: dateStr, earned, spent });
    }

    return { trend };
  }

  static getCarbonReductionEstimate(): Record<string, unknown> {
    const orders = generateMockOrders();
    const completedOrders = orders.filter(o => o.status === 'completed');
    const totalReductionKg = completedOrders.length * CARBON_REDUCTION_PER_TRADE_KG;
    return {
      totalReductionKg,
      totalTrades: completedOrders.length,
      coefficient: CARBON_REDUCTION_PER_TRADE_KG
    };
  }

  static getCarbonCreditSource(): Record<string, unknown> {
    const creditTxs = generateMockCreditTransactions();
    const distribution: Record<string, number> = {};
    for (const tx of creditTxs) {
      if (tx.amount > 0) {
        distribution[tx.type] = (distribution[tx.type] || 0) + tx.amount;
      }
    }
    return { distribution };
  }

  static getCarbonExchangeStats(): Record<string, unknown> {
    const creditTxs = generateMockCreditTransactions();
    const exchanges = creditTxs.filter(tx => tx.type === 'EXCHANGE_DEDUCT');
    return {
      exchangeCount: exchanges.length,
      totalSpent: exchanges.reduce((sum, tx) => sum + Math.abs(tx.amount), 0)
    };
  }

  static getCarbonAchievementDistribution(): Record<string, unknown> {
    return {
      achievements: [
        { id: 'first_trade', name: '首次交易', unlockCount: 2, unlockRate: 0.18 },
        { id: 'streak_7days', name: '连续交易7天', unlockCount: 0, unlockRate: 0 },
        { id: 'total_10trades', name: '累计交易10笔', unlockCount: 0, unlockRate: 0 },
        { id: 'reduce_1kg', name: '累计减排1kg', unlockCount: 1, unlockRate: 0.09 }
      ]
    };
  }

  static getCarbonRanking(limit: number = 10): Record<string, unknown> {
    const creditAccounts = generateMockCreditAccounts();
    const users = generateMockUsers();
    const sorted = [...creditAccounts].sort((a, b) => b.totalEarned - a.totalEarned);
    return {
      ranking: sorted.slice(0, limit).map((ca, i) => {
        const user = users.find(u => u.id === ca.userId);
        return {
          rank: i + 1,
          userId: ca.userId,
          nickname: user ? user.nickname : ca.userId,
          totalEarned: ca.totalEarned,
          level: ca.level
        };
      })
    };
  }
}