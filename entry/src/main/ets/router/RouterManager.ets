import { router } from '@kit.ArkUI';
import { AppConstants } from '../constants/AppConstants';

export class RouterManager {
  static switchTab(tabIndex: number): void {
    AppStorage.setOrCreate('currentTabIndex', tabIndex);
  }

  static toProductDetail(productId: string): void {
    router.pushUrl({
      url: AppConstants.ROUTE_PRODUCT_DETAIL,
      params: { productId: productId }
    }).catch((err: Error) => {
      console.error(`[RouterManager] toProductDetail failed: ${err.message}`);
    });
  }

  static toChat(conversationId: string, targetUserName: string, targetUserId: string): void {
    router.pushUrl({
      url: AppConstants.ROUTE_CHAT,
      params: {
        conversationId: conversationId,
        targetUserName: targetUserName,
        targetUserId: targetUserId
      }
    }).catch((err: Error) => {
      console.error(`[RouterManager] toChat failed: ${err.message}`);
    });
  }

  static toMyProducts(): void {
    router.pushUrl({ url: AppConstants.ROUTE_MY_PRODUCTS }).catch((err: Error) => {
      console.error(`[RouterManager] toMyProducts failed: ${err.message}`);
    });
  }

  static toMyFavorites(): void {
    router.pushUrl({ url: AppConstants.ROUTE_MY_FAVORITES }).catch((err: Error) => {
      console.error(`[RouterManager] toMyFavorites failed: ${err.message}`);
    });
  }

  static toOrderCenter(): void {
    router.pushUrl({ url: AppConstants.ROUTE_ORDER_CENTER }).catch((err: Error) => {
      console.error(`[RouterManager] toOrderCenter failed: ${err.message}`);
    });
  }

  static toCreditCenter(): void {
    router.pushUrl({ url: AppConstants.ROUTE_CREDIT_CENTER }).catch((err: Error) => {
      console.error(`[RouterManager] toCreditCenter failed: ${err.message}`);
    });
  }

  static toCreditLedger(): void {
    router.pushUrl({ url: AppConstants.ROUTE_CREDIT_LEDGER }).catch((err: Error) => {
      console.error(`[RouterManager] toCreditLedger failed: ${err.message}`);
    });
  }

  static toEcoAchievement(): void {
    router.pushUrl({ url: AppConstants.ROUTE_ECO_ACHIEVEMENT }).catch((err: Error) => {
      console.error(`[RouterManager] toEcoAchievement failed: ${err.message}`);
    });
  }

  static toCreditMall(): void {
    router.pushUrl({ url: AppConstants.ROUTE_CREDIT_MALL }).catch((err: Error) => {
      console.error(`[RouterManager] toCreditMall failed: ${err.message}`);
    });
  }


  static back(): void {
    router.back();
  }
}
