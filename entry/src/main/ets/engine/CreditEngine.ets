
import { CarbonCreditTable, CarbonCreditResult } from '../config/CarbonCreditTable';
import { HttpService } from '../services/HttpService';

export class ExchangeResult {
  success: boolean = false;
  message: string = '';
}

export class CreditEngine {
  static calculateProductCredits(category: string, subCategory: string, condition: string): CarbonCreditResult {
    return CarbonCreditTable.calculate(category, subCategory, condition);
  }

  static async onTradeCompleted(orderId: string, buyerId: string, sellerId: string, sellerCredits: number, carbonReduction: number): Promise<void> {
    try {
      const currentUserId: string = AppStorage.get<string>('currentUserId') || '';
      const isBuyer: boolean = currentUserId === buyerId;
      const body: Record<string, string | number | object> = {};
      body['orderId'] = orderId;
      body['counterpartyId'] = isBuyer ? sellerId : buyerId;
      body['sellerCredits'] = sellerCredits;
      body['carbonReduction'] = carbonReduction;
      body['isBuyer'] = isBuyer ? 1 : 0;
      await HttpService.POST('/credits/trade-reward', body);
    } catch (err) {
    }
  }

  static async onProductPublished(productId: string, sellerId: string): Promise<void> {
    try {
      const body: Record<string, string | number | object> = {};
      body['productId'] = productId;
      await HttpService.POST('/credits/publish-reward', body);
    } catch (err) {
    }
  }

  static async onDonation(productId: string, donorId: string, baseCredits: number, carbonReduction: number): Promise<void> {
    try {
      const body: Record<string, string | number | object> = {};
      body['productId'] = productId;
      body['baseCredits'] = baseCredits;
      body['carbonReduction'] = carbonReduction;
      await HttpService.POST('/credits/donation-reward', body);
    } catch (err) {
    }
  }

  static async onReform(productId: string, userId: string, baseCredits: number, carbonReduction: number): Promise<void> {
    try {
      const body: Record<string, string | number | object> = {};
      body['productId'] = productId;
      body['baseCredits'] = baseCredits;
      body['carbonReduction'] = carbonReduction;
      await HttpService.POST('/credits/reform-reward', body);
    } catch (err) {
    }
  }

  static async onAchievementReward(userId: string, rewardCredits: number, relatedId: string): Promise<void> {
    try {
      const body: Record<string, string | number | object> = {};
      body['rewardCredits'] = rewardCredits;
      body['relatedId'] = relatedId;
      await HttpService.POST('/credits/achievement-reward', body);
    } catch (err) {
    }
  }

  static async transferCredits(fromUserId: string, toUserId: string, amount: number): Promise<ExchangeResult> {
    try {
      const body: Record<string, string | number | object> = {};
      body['toUserId'] = toUserId;
      body['amount'] = amount;
      const resp = await HttpService.POST('/credits/transfer', body);
      const result = new ExchangeResult();
      result.success = resp.code === 0;
      result.message = resp.message;
      return result;
    } catch (err) {
      const result = new ExchangeResult();
      result.success = false;
      result.message = '转账失败';
      return result;
    }
  }

  static async onViolation(userId: string, originalCredits: number): Promise<void> {
  }

  static async exchangeCredits(userId: string, productId: string, requiredCredits: number): Promise<ExchangeResult> {
    try {
      const body: Record<string, string | number | object> = {};
      body['productId'] = productId;
      body['requiredCredits'] = requiredCredits;
      const resp = await HttpService.POST('/credits/exchange', body);
      const result = new ExchangeResult();
      result.success = resp.code === 0;
      result.message = resp.message;
      return result;
    } catch (err) {
      const result = new ExchangeResult();
      result.success = false;
      result.message = '兑换失败';
      return result;
    }
  }

  static checkExpiredCredits(userId: string): void {
  }
}
