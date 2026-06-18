import db from '../businessDatabase';

// 积分增减规则常量
const TRADE_BUYER_REWARD_RATIO = 0.2;   // 买家交易奖励 = 卖家积分 × 20%
const PUBLISH_REWARD = 10;               // 发布商品固定奖励 +10
const DONATION_MULTIPLIER = 1.5;         // 捐赠积分 = 基础积分 × 1.5
const REFORM_MULTIPLIER = 2.0;           // 改造积分 = 基础积分 × 2.0
const TRANSFER_FEE_RATIO = 0.1;          // 转账手续费 = 转账金额 × 10%
const VIOLATION_DEDUCT_MULTIPLIER = 2.0; // 违规扣分 = 原始积分 × 2.0

// 等级阈值：基于累计获得(totalEarned)，非当前余额(balance)，等级只升不降
const LEVEL_THRESHOLDS: { level: string; threshold: number }[] = [
  { level: '环保新手', threshold: 0 },
  { level: '环保达人', threshold: 100 },
  { level: '环保先锋', threshold: 500 },
  { level: '环保卫士', threshold: 2000 },
  { level: '环保英雄', threshold: 5000 },
];

function getLevelByTotalEarned(totalEarned: number): string {
  let result = '环保新手';
  for (const t of LEVEL_THRESHOLDS) {
    if (totalEarned >= t.threshold) {
      result = t.level;
    }
  }
  return result;
}

function ensureCreditAccount(userId: string): void {
  const existing = db.prepare('SELECT user_id FROM credit_accounts WHERE user_id = ?').get(userId);
  if (!existing) {
    const now = Date.now();
    db.prepare('INSERT INTO credit_accounts (user_id, balance, total_earned, total_spent, level, created_at, updated_at) VALUES (?, 0, 0, 0, ?, ?, ?)')
      .run(userId, '环保新手', now, now);
  }
}

function addTransaction(userId: string, type: string, amount: number, balanceAfter: number, relatedId: string, carbonReduction: number): void {
  const id = 'ct_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6);
  const now = Date.now();
  db.prepare('INSERT INTO credit_transactions (id, user_id, type, amount, balance_after, related_id, carbon_reduction, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)')
    .run(id, userId, type, amount, balanceAfter, relatedId, carbonReduction, now);
}

// 余额更新逻辑：正数→余额+累计获得增加；负数→余额+累计消耗增加，余额不足拒绝
function updateBalance(userId: string, delta: number): { balance: number; totalEarned: number; totalSpent: number } {
  ensureCreditAccount(userId);
  const account = db.prepare('SELECT balance, total_earned, total_spent FROM credit_accounts WHERE user_id = ?').get(userId) as { balance: number; total_earned: number; total_spent: number };

  let newBalance = account.balance;
  let newEarned = account.total_earned;
  let newSpent = account.total_spent;

  if (delta > 0) {
    newBalance += delta;
    newEarned += delta;
  } else {
    const deduct = Math.abs(delta);
    if (newBalance < deduct) {
      return { balance: newBalance, totalEarned: newEarned, totalSpent: newSpent };
    }
    newBalance -= deduct;
    newSpent += deduct;
  }

  const level = getLevelByTotalEarned(newEarned);
  db.prepare('UPDATE credit_accounts SET balance = ?, total_earned = ?, total_spent = ?, level = ?, updated_at = ? WHERE user_id = ?')
    .run(newBalance, newEarned, newSpent, level, Date.now(), userId);

  return { balance: newBalance, totalEarned: newEarned, totalSpent: newSpent };
}

// 幂等性保障：通过relatedId去重，防止重复发放积分
function existsByRelatedId(relatedId: string): boolean {
  const row = db.prepare('SELECT id FROM credit_transactions WHERE related_id = ?').get(relatedId) as { id: string } | undefined;
  return !!row;
}

export class CreditService {
  static getAccount(userId: string): { balance: number; totalEarned: number; totalSpent: number; level: string } {
    ensureCreditAccount(userId);
    const row = db.prepare('SELECT balance, total_earned, total_spent, level FROM credit_accounts WHERE user_id = ?').get(userId) as { balance: number; total_earned: number; total_spent: number; level: string };
    return { balance: row.balance, totalEarned: row.total_earned, totalSpent: row.total_spent, level: row.level };
  }

  static onTradeCompleted(orderId: string, buyerId: string, sellerId: string, sellerCredits: number, carbonReduction: number): void {
    const buyerRelatedId = 'trade_buyer_' + orderId;
    const sellerRelatedId = 'trade_seller_' + orderId;
    if (existsByRelatedId(buyerRelatedId) || existsByRelatedId(sellerRelatedId)) return;

    const buyerReward = Math.round(sellerCredits * TRADE_BUYER_REWARD_RATIO * 100) / 100;
    const buyerAccount = updateBalance(buyerId, buyerReward);
    addTransaction(buyerId, 'TRADE_REWARD', buyerReward, buyerAccount.balance, buyerRelatedId, Math.round(carbonReduction * TRADE_BUYER_REWARD_RATIO * 100) / 100);

    const sellerAccount = updateBalance(sellerId, sellerCredits);
    addTransaction(sellerId, 'TRADE_REWARD', sellerCredits, sellerAccount.balance, sellerRelatedId, carbonReduction);
  }

  static onProductPublished(productId: string, sellerId: string): void {
    const relatedId = 'publish_' + productId;
    if (existsByRelatedId(relatedId)) return;

    const account = updateBalance(sellerId, PUBLISH_REWARD);
    addTransaction(sellerId, 'PUBLISH_REWARD', PUBLISH_REWARD, account.balance, relatedId, 0);
  }

  static onDonation(productId: string, donorId: string, baseCredits: number, carbonReduction: number): void {
    const relatedId = 'donation_' + productId;
    if (existsByRelatedId(relatedId)) return;

    const rewardCredits = Math.round(baseCredits * DONATION_MULTIPLIER * 100) / 100;
    const account = updateBalance(donorId, rewardCredits);
    addTransaction(donorId, 'DONATION_REWARD', rewardCredits, account.balance, relatedId, carbonReduction);
  }

  static onReform(productId: string, userId: string, baseCredits: number, carbonReduction: number): void {
    const relatedId = 'reform_' + productId;
    if (existsByRelatedId(relatedId)) return;

    const rewardCredits = Math.round(baseCredits * REFORM_MULTIPLIER * 100) / 100;
    const account = updateBalance(userId, rewardCredits);
    addTransaction(userId, 'REFORM_REWARD', rewardCredits, account.balance, relatedId, carbonReduction);
  }

  static onAchievementReward(userId: string, rewardCredits: number, relatedId: string): void {
    if (existsByRelatedId(relatedId)) return;

    const account = updateBalance(userId, rewardCredits);
    addTransaction(userId, 'ACHIEVEMENT_REWARD', rewardCredits, account.balance, relatedId, 0);
  }

  static transferCredits(fromUserId: string, toUserId: string, amount: number): { success: boolean; message: string } {
    const fee = Math.round(amount * TRANSFER_FEE_RATIO * 100) / 100;
    const totalDeduct = amount + fee;
    const fromAccount = CreditService.getAccount(fromUserId);
    if (fromAccount.balance < totalDeduct) {
      return { success: false, message: `积分不足，需${totalDeduct}积分(含${fee}手续费)` };
    }

    const afterDeduct = updateBalance(fromUserId, -totalDeduct);
    addTransaction(fromUserId, 'TRANSFER_OUT', amount, afterDeduct.balance, 'transfer_' + fromUserId + '_' + toUserId, 0);
    addTransaction(fromUserId, 'TRANSFER_FEE', fee, afterDeduct.balance, 'transfer_fee_' + fromUserId + '_' + toUserId, 0);

    const afterReceive = updateBalance(toUserId, amount);
    addTransaction(toUserId, 'TRANSFER_IN', amount, afterReceive.balance, 'transfer_' + fromUserId + '_' + toUserId, 0);

    return { success: true, message: `转让成功，手续费${fee}积分` };
  }

  static onViolation(userId: string, originalCredits: number): void {
    const deductAmount = Math.round(originalCredits * VIOLATION_DEDUCT_MULTIPLIER * 100) / 100;
    const account = CreditService.getAccount(userId);
    const actualDeduct = Math.min(deductAmount, account.balance);
    if (actualDeduct > 0) {
      const afterDeduct = updateBalance(userId, -actualDeduct);
      addTransaction(userId, 'VIOLATION_DEDUCT', actualDeduct, afterDeduct.balance, 'violation_' + userId + '_' + Date.now(), 0);
    }
  }

  static exchangeCredits(userId: string, requiredCredits: number, productId: string): { success: boolean; message: string } {
    const account = CreditService.getAccount(userId);
    if (account.balance < requiredCredits) {
      return { success: false, message: `积分不足，还差${requiredCredits - account.balance}积分可兑换` };
    }

    const afterDeduct = updateBalance(userId, -requiredCredits);
    addTransaction(userId, 'EXCHANGE_DEDUCT', requiredCredits, afterDeduct.balance, 'exchange_' + productId + '_' + Date.now(), 0);

    return { success: true, message: '兑换成功' };
  }

  static getTransactions(userId: string, page: number, pageSize: number, typeFilter?: string): { list: any[]; total: number } {
    ensureCreditAccount(userId);
    let whereClause = 'WHERE user_id = ?';
    const params: any[] = [userId];

    if (typeFilter === 'income') {
      whereClause += " AND type IN ('TRADE_REWARD','PUBLISH_REWARD','ACHIEVEMENT_REWARD','DONATION_REWARD','REFORM_REWARD','TRANSFER_IN')";
    } else if (typeFilter === 'expense') {
      whereClause += " AND type IN ('EXCHANGE_DEDUCT','EXPIRE_CLEAR','TRANSFER_OUT','TRANSFER_FEE','VIOLATION_DEDUCT')";
    }

    const total = (db.prepare(`SELECT COUNT(*) as c FROM credit_transactions ${whereClause}`).get(...params) as { c: number }).c;
    const offset = (page - 1) * pageSize;
    const rows = db.prepare(`SELECT id, user_id, type, amount, balance_after, related_id, carbon_reduction, timestamp FROM credit_transactions ${whereClause} ORDER BY timestamp DESC LIMIT ? OFFSET ?`)
      .all(...params, pageSize, offset) as any[];

    return { list: rows, total };
  }

  static getTodayEarned(userId: string): number {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const row = db.prepare('SELECT COALESCE(SUM(amount), 0) as total FROM credit_transactions WHERE user_id = ? AND amount > 0 AND timestamp >= ?')
      .get(userId, todayStart.getTime()) as { total: number };
    return row.total;
  }

  static getTotalReduction(userId: string): number {
    const row = db.prepare('SELECT COALESCE(SUM(carbon_reduction), 0) as total FROM credit_transactions WHERE user_id = ? AND carbon_reduction > 0')
      .get(userId) as { total: number };
    return Math.round(row.total * 100) / 100;
  }

  static getTradeCount(userId: string): number {
    const row = db.prepare("SELECT COUNT(*) as c FROM credit_transactions WHERE user_id = ? AND type = 'TRADE_REWARD'")
      .get(userId) as { c: number };
    return row.c;
  }

  static getTradeDates(userId: string): number[] {
    const rows = db.prepare("SELECT DISTINCT (timestamp / 86400000) as day FROM credit_transactions WHERE user_id = ? AND type = 'TRADE_REWARD' ORDER BY day DESC")
      .all(userId) as { day: number }[];
    return rows.map(r => r.day * 86400000);
  }
}