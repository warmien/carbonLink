import { CreditTransaction, CreditTransactionType } from '../models/CreditTransaction';
import { ExchangeRecord } from '../models/ExchangeRecord';
import { UserLevel } from '../models/CreditAccount';
import { CreditRules } from '../config/CreditRules';
import { CarbonCreditTable, CarbonCreditResult } from '../config/CarbonCreditTable';
import { creditAccountRepository } from '../repository/CreditAccountRepository';
import { creditTransactionRepository } from '../repository/CreditTransactionRepository';
import { mallProductRepository } from '../repository/MallProductRepository';
import { exchangeRecordRepository } from '../repository/ExchangeRecordRepository';

export class ExchangeResult {
  success: boolean = false;
  message: string = '';
}

export class CreditEngine {
  static calculateProductCredits(category: string, subCategory: string, condition: string): CarbonCreditResult {
    return CarbonCreditTable.calculate(category, subCategory, condition);
  }

  static onTradeCompleted(orderId: string, buyerId: string, sellerId: string, sellerCredits: number, carbonReduction: number): void {
    const buyerRelatedId = 'trade_buyer_' + orderId;
    const sellerRelatedId = 'trade_seller_' + orderId;
    if (creditTransactionRepository.existsByRelatedId(buyerRelatedId) ||
      creditTransactionRepository.existsByRelatedId(sellerRelatedId)) {
      return;
    }

    const buyerReward = Math.round(sellerCredits * CreditRules.TRADE_BUYER_REWARD_RATIO * 100) / 100;
    const buyerAccount = creditAccountRepository.updateBalance(buyerId, buyerReward);
    const buyerTx = new CreditTransaction();
    buyerTx.id = 'ct_' + Date.now() + '_b';
    buyerTx.userId = buyerId;
    buyerTx.type = CreditTransactionType.TRADE_REWARD;
    buyerTx.amount = buyerReward;
    buyerTx.balanceAfter = buyerAccount.balance;
    buyerTx.relatedId = buyerRelatedId;
    buyerTx.carbonReduction = Math.round(carbonReduction * CreditRules.TRADE_BUYER_REWARD_RATIO * 100) / 100;
    creditTransactionRepository.add(buyerTx);

    const sellerAccount = creditAccountRepository.updateBalance(sellerId, sellerCredits);
    const sellerTx = new CreditTransaction();
    sellerTx.id = 'ct_' + Date.now() + '_s';
    sellerTx.userId = sellerId;
    sellerTx.type = CreditTransactionType.TRADE_REWARD;
    sellerTx.amount = sellerCredits;
    sellerTx.balanceAfter = sellerAccount.balance;
    sellerTx.relatedId = sellerRelatedId;
    sellerTx.carbonReduction = carbonReduction;
    creditTransactionRepository.add(sellerTx);

    creditAccountRepository.updateLevel(buyerId, buyerAccount.totalEarned);
    creditAccountRepository.updateLevel(sellerId, sellerAccount.totalEarned);
  }

  static onProductPublished(productId: string, sellerId: string): void {
    const relatedId = 'publish_' + productId;
    if (creditTransactionRepository.existsByRelatedId(relatedId)) {
      return;
    }

    const account = creditAccountRepository.updateBalance(sellerId, CreditRules.PUBLISH_REWARD);
    const tx = new CreditTransaction();
    tx.id = 'ct_' + Date.now();
    tx.userId = sellerId;
    tx.type = CreditTransactionType.PUBLISH_REWARD;
    tx.amount = CreditRules.PUBLISH_REWARD;
    tx.balanceAfter = account.balance;
    tx.relatedId = relatedId;
    creditTransactionRepository.add(tx);

    creditAccountRepository.updateLevel(sellerId, account.totalEarned);
  }

  static onDonation(productId: string, donorId: string, baseCredits: number, carbonReduction: number): void {
    const relatedId = 'donation_' + productId;
    if (creditTransactionRepository.existsByRelatedId(relatedId)) {
      return;
    }
    const rewardCredits = Math.round(baseCredits * CreditRules.DONATION_MULTIPLIER * 100) / 100;
    const account = creditAccountRepository.updateBalance(donorId, rewardCredits);
    const tx = new CreditTransaction();
    tx.id = 'ct_' + Date.now();
    tx.userId = donorId;
    tx.type = CreditTransactionType.DONATION_REWARD;
    tx.amount = rewardCredits;
    tx.balanceAfter = account.balance;
    tx.relatedId = relatedId;
    tx.carbonReduction = carbonReduction;
    creditTransactionRepository.add(tx);
    creditAccountRepository.updateLevel(donorId, account.totalEarned);
  }

  static onReform(productId: string, userId: string, baseCredits: number, carbonReduction: number): void {
    const relatedId = 'reform_' + productId;
    if (creditTransactionRepository.existsByRelatedId(relatedId)) {
      return;
    }
    const rewardCredits = Math.round(baseCredits * CreditRules.REFORM_MULTIPLIER * 100) / 100;
    const account = creditAccountRepository.updateBalance(userId, rewardCredits);
    const tx = new CreditTransaction();
    tx.id = 'ct_' + Date.now();
    tx.userId = userId;
    tx.type = CreditTransactionType.REFORM_REWARD;
    tx.amount = rewardCredits;
    tx.balanceAfter = account.balance;
    tx.relatedId = relatedId;
    tx.carbonReduction = carbonReduction;
    creditTransactionRepository.add(tx);
    creditAccountRepository.updateLevel(userId, account.totalEarned);
  }

  static transferCredits(fromUserId: string, toUserId: string, amount: number): ExchangeResult {
    const result = new ExchangeResult();
    const fee = Math.round(amount * CreditRules.TRANSFER_FEE_RATIO * 100) / 100;
    const totalDeduct = amount + fee;
    const balance = creditAccountRepository.getBalance(fromUserId);
    if (balance < totalDeduct) {
      result.success = false;
      result.message = '积分不足，需' + totalDeduct + '积分(含' + fee + '手续费)';
      return result;
    }

    const fromAccount = creditAccountRepository.updateBalance(fromUserId, -totalDeduct);
    const outTx = new CreditTransaction();
    outTx.id = 'ct_' + Date.now() + '_out';
    outTx.userId = fromUserId;
    outTx.type = CreditTransactionType.TRANSFER_OUT;
    outTx.amount = amount;
    outTx.balanceAfter = fromAccount.balance;
    outTx.relatedId = 'transfer_' + fromUserId + '_' + toUserId;
    creditTransactionRepository.add(outTx);

    const feeTx = new CreditTransaction();
    feeTx.id = 'ct_' + Date.now() + '_fee';
    feeTx.userId = fromUserId;
    feeTx.type = CreditTransactionType.TRANSFER_FEE;
    feeTx.amount = fee;
    feeTx.balanceAfter = fromAccount.balance;
    feeTx.relatedId = 'transfer_fee_' + fromUserId + '_' + toUserId;
    creditTransactionRepository.add(feeTx);

    const toAccount = creditAccountRepository.updateBalance(toUserId, amount);
    const inTx = new CreditTransaction();
    inTx.id = 'ct_' + Date.now() + '_in';
    inTx.userId = toUserId;
    inTx.type = CreditTransactionType.TRANSFER_IN;
    inTx.amount = amount;
    inTx.balanceAfter = toAccount.balance;
    inTx.relatedId = 'transfer_' + fromUserId + '_' + toUserId;
    creditTransactionRepository.add(inTx);

    creditAccountRepository.updateLevel(fromUserId, fromAccount.totalEarned);
    creditAccountRepository.updateLevel(toUserId, toAccount.totalEarned);

    result.success = true;
    result.message = '转让成功，手续费' + fee + '积分';
    return result;
  }

  static onViolation(userId: string, originalCredits: number): void {
    const deductAmount = Math.round(originalCredits * CreditRules.VIOLATION_DEDUCT_MULTIPLIER * 100) / 100;
    const balance = creditAccountRepository.getBalance(userId);
    const actualDeduct = Math.min(deductAmount, balance);
    if (actualDeduct > 0) {
      creditAccountRepository.updateBalance(userId, -actualDeduct);
    }
    const tx = new CreditTransaction();
    tx.id = 'ct_' + Date.now();
    tx.userId = userId;
    tx.type = CreditTransactionType.VIOLATION_DEDUCT;
    tx.amount = actualDeduct;
    tx.balanceAfter = Math.max(0, balance - actualDeduct);
    tx.relatedId = 'violation_' + userId + '_' + Date.now();
    creditTransactionRepository.add(tx);
  }

  static exchangeCredits(userId: string, productId: string, requiredCredits: number): ExchangeResult {
    const result = new ExchangeResult();
    const balance = creditAccountRepository.getBalance(userId);
    if (balance < requiredCredits) {
      result.success = false;
      result.message = '积分不足，还差' + (requiredCredits - balance) + '积分可兑换';
      return result;
    }

    const product = mallProductRepository.getProductById(productId);
    if (!product || product.stock <= 0) {
      result.success = false;
      result.message = '商品库存不足';
      return result;
    }

    const account = creditAccountRepository.updateBalance(userId, -requiredCredits);
    const tx = new CreditTransaction();
    tx.id = 'ct_' + Date.now();
    tx.userId = userId;
    tx.type = CreditTransactionType.EXCHANGE_DEDUCT;
    tx.amount = requiredCredits;
    tx.balanceAfter = account.balance;
    tx.relatedId = 'exchange_' + productId + '_' + Date.now();
    creditTransactionRepository.add(tx);

    mallProductRepository.updateStock(productId, -1);

    const record = new ExchangeRecord();
    record.id = 'ex_' + Date.now();
    record.userId = userId;
    record.productId = productId;
    record.creditsSpent = requiredCredits;
    exchangeRecordRepository.add(record);

    result.success = true;
    result.message = '兑换成功';
    return result;
  }

  static checkExpiredCredits(userId: string): void {
    const expiryMs = CreditRules.CREDIT_EXPIRY_MONTHS * 30 * 24 * 60 * 60 * 1000;
    const cutoffTime = Date.now() - expiryMs;
    const account = creditAccountRepository.getOrCreate(userId);
    if (account.createdAt < cutoffTime && account.balance > 0) {
      const expiredAmount = account.balance;
      creditAccountRepository.updateBalance(userId, -expiredAmount);
      const tx = new CreditTransaction();
      tx.id = 'ct_' + Date.now();
      tx.userId = userId;
      tx.type = CreditTransactionType.EXPIRE_CLEAR;
      tx.amount = expiredAmount;
      tx.balanceAfter = 0;
      tx.relatedId = 'expire_' + userId;
      creditTransactionRepository.add(tx);
    }
  }

  static onAchievementReward(userId: string, rewardCredits: number, relatedId: string): void {
    if (creditTransactionRepository.existsByRelatedId(relatedId)) {
      return;
    }
    const account = creditAccountRepository.updateBalance(userId, rewardCredits);
    const tx = new CreditTransaction();
    tx.id = 'ct_' + Date.now();
    tx.userId = userId;
    tx.type = CreditTransactionType.ACHIEVEMENT_REWARD;
    tx.amount = rewardCredits;
    tx.balanceAfter = account.balance;
    tx.relatedId = relatedId;
    creditTransactionRepository.add(tx);
    creditAccountRepository.updateLevel(userId, account.totalEarned);
  }
}
