export class SplashAdData {
  id: string = '';
  imageUrl: string = '';
  title: string = '';
  subtitle: string = '';
  actionUrl: string = '';
  duration: number = 5;
  startTime: number = 0;
  endTime: number = 0;
  constructor() {}
}

export class SplashAdService {
  private static currentAd: SplashAdData = new SplashAdData();

  static getAd(): SplashAdData {
    return SplashAdService.currentAd;
  }

  static async fetchAd(): Promise<SplashAdData> {
    // TODO: 后续接入数据库，从后端API获取广告数据
    // const response = await http.request(API_URL + '/splash-ad');
    // return JSON.parse(response.result) as SplashAdData;

    // Demo: 返回模拟广告数据
    const ad = new SplashAdData();
    ad.id = 'ad_demo_001';
    ad.imageUrl = '';
    ad.title = '绿色循环 碳享未来';
    ad.subtitle = '发布闲置物品，赚取碳积分，让闲置焕发新生';
    ad.actionUrl = '';
    ad.duration = 5;
    ad.startTime = Date.now();
    ad.endTime = Date.now() + 86400000;
    SplashAdService.currentAd = ad;
    return ad;
  }

  static async reportAdImpression(adId: string): Promise<void> {
    // TODO: 后续接入数据库，上报广告曝光
    // await http.request(API_URL + '/ad/impression', { method: 'POST', extraData: { adId } });
    console.info('[SplashAdService] Ad impression reported: ' + adId);
  }

  static async reportAdClick(adId: string): Promise<void> {
    // TODO: 后续接入数据库，上报广告点击
    // await http.request(API_URL + '/ad/click', { method: 'POST', extraData: { adId } });
    console.info('[SplashAdService] Ad click reported: ' + adId);
  }
}