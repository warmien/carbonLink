import { CreditTransaction, CreditTransactionType } from '../models/CreditTransaction';
import { ExchangeRecord } from '../models/ExchangeRecord';
import { UserLevel } from '../models/CreditAccount';
import { CreditRules } from '../config/CreditRules';
import { creditAccountRepository } from '../repository/CreditAccountRepository';
import { creditTransactionRepository } from '../repository/CreditTransactionRepository';
import { mallProductRepository } from '../repository/MallProductRepository';
import { exchangeRecordRepository } from '../repository/ExchangeRecordRepository';

export class ExchangeResult {
  success: boolean = false;
  message: string = '';
}

export class CreditEngine {
  static onTradeCompleted(orderId: string, buyerId: string, sellerId: string): void {
    const buyerRelatedId = 'trade_buyer_' + orderId;
    const sellerRelatedId = 'trade_seller_' + orderId;
    if (creditTransactionRepository.existsByRelatedId(buyerRelatedId) ||
      creditTransactionRepository.existsByRelatedId(sellerRelatedId)) {
      return;
    }

    const buyerAccount = creditAccountRepository.updateBalance(buyerId, CreditRules.TRADE_BUYER_REWARD);
    const buyerTx = new CreditTransaction();
    buyerTx.id = 'ct_' + Date.now() + '_b';
    buyerTx.userId = buyerId;
    buyerTx.type = CreditTransactionType.TRADE_REWARD;
    buyerTx.amount = CreditRules.TRADE_BUYER_REWARD;
    buyerTx.balanceAfter = buyerAccount.balance;
    buyerTx.relatedId = buyerRelatedId;
    creditTransactionRepository.add(buyerTx);

    const sellerAccount = creditAccountRepository.updateBalance(sellerId, CreditRules.TRADE_SELLER_REWARD);
    const sellerTx = new CreditTransaction();
    sellerTx.id = 'ct_' + Date.now() + '_s';
    sellerTx.userId = sellerId;
    sellerTx.type = CreditTransactionType.TRADE_REWARD;
    sellerTx.amount = CreditRules.TRADE_SELLER_REWARD;
    sellerTx.balanceAfter = sellerAccount.balance;
    sellerTx.relatedId = sellerRelatedId;
    creditTransactionRepository.add(sellerTx);

    const newBuyerLevel = creditAccountRepository.updateLevel(buyerId, buyerAccount.totalEarned);
    const newSellerLevel = creditAccountRepository.updateLevel(sellerId, sellerAccount.totalEarned);
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