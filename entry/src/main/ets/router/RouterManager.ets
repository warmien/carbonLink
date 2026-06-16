import { router } from '@kit.ArkUI';
import { AppConstants } from '../constants/AppConstants';

export class RouterManager {
  static switchTab(tabIndex: number): void {
    AppStorage.setOrCreate('currentTabIndex', tabIndex);
  }

  static toLogin(): void {
    router.replaceUrl({ url: AppConstants.ROUTE_LOGIN }).catch((err: Error) => {
      console.error(`[RouterManager] toLogin failed: ${err.message}`);
    });
  }

  static toRegister(): void {
    router.pushUrl({ url: AppConstants.ROUTE_REGISTER }).catch((err: Error) => {
      console.error(`[RouterManager] toRegister failed: ${err.message}`);
    });
  }

  static toMainFromLogin(): void {
    router.replaceUrl({ url: 'pages/Index' }).catch((err: Error) => {
      console.error(`[RouterManager] toMainFromLogin failed: ${err.message}`);
    });
  }

  static toSettings(): void {
    router.pushUrl({ url: AppConstants.ROUTE_SETTINGS }).catch((err: Error) => {
      console.error(`[RouterManager] toSettings failed: ${err.message}`);
    });
  }

  static requireAuth(): boolean {
    const isLoggedIn: boolean = AppStorage.get<boolean>('isLoggedIn') || false;
    if (!isLoggedIn) {
      RouterManager.toLogin();
      return false;
    }
    return true;
  }

  static redirectIfLoggedIn(): void {
    const isLoggedIn: boolean = AppStorage.get<boolean>('isLoggedIn') || false;
    if (isLoggedIn) {
      RouterManager.toMainFromLogin();
    }
  }

  static toProductDetail(productId: string): void {
    router.pushUrl({
      url: AppConstants.ROUTE_PRODUCT_DETAIL,
      params: { productId: productId }
    }).catch((err: Error) => {
      console.error(`[RouterManager] toProductDetail failed: ${err.message}`);
    });
  }

  static toChat(conversationId: string, targetUserName: string, targetUserId: string,
    productTitle?: string, productImage?: string, targetUserAvatar?: string, productId?: string): void {
    const params: Record<string, string> = {};
    params['conversationId'] = conversationId;
    params['targetUserName'] = targetUserName;
    params['targetUserId'] = targetUserId;
    if (productTitle) {
      params['productTitle'] = productTitle;
    }
    if (productImage) {
      params['productImage'] = productImage;
    }
    if (targetUserAvatar) {
      params['targetUserAvatar'] = targetUserAvatar;
    }
    if (productId) {
      params['productId'] = productId;
    }
    router.pushUrl({
      url: AppConstants.ROUTE_CHAT,
      params: params
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

  static toOrderCenter(tabIndex?: number): void {
    const params: Record<string, number> = {};
    if (tabIndex !== undefined) {
      params['tabIndex'] = tabIndex;
    }
    router.pushUrl({ url: AppConstants.ROUTE_ORDER_CENTER, params: params }).catch((err: Error) => {
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

  static toEditProfile(): void {
    router.pushUrl({ url: AppConstants.ROUTE_EDIT_PROFILE }).catch((err: Error) => {
      console.error(`[RouterManager] toEditProfile failed: ${err.message}`);
    });
  }

  static toChangePassword(): void {
    router.pushUrl({ url: AppConstants.ROUTE_CHANGE_PASSWORD }).catch((err: Error) => {
      console.error(`[RouterManager] toChangePassword failed: ${err.message}`);
    });
  }

  static toBrowseHistory(): void {
    router.pushUrl({ url: AppConstants.ROUTE_BROWSE_HISTORY }).catch((err: Error) => {
      console.error(`[RouterManager] toBrowseHistory failed: ${err.message}`);
    });
  }


  static back(): void {
    router.back();
  }
}
