import { router } from '@kit.ArkUI';
import { SplashAdService, SplashAdData } from '../services/SplashAdService';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { AuthManager } from '../services/AuthManager';
import { TokenManager } from '../services/TokenManager';

@Entry
@Component
struct SplashAdPage {
  @State adData: SplashAdData = new SplashAdData();
  @State countdown: number = 5;
  @State progress: number = 100;
  @State isLoaded: boolean = false;
  @State btnScale: number = 1;
  private timer: number = -1;

  aboutToAppear(): void {
    this.loadAd();
  }

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  private async loadAd(): Promise<void> {
    this.adData = await SplashAdService.fetchAd();
    this.isLoaded = true;
    this.countdown = this.adData.duration;
    SplashAdService.reportAdImpression(this.adData.id);
    this.startCountdown();
  }

  private startCountdown(): void {
    const totalDuration = this.adData.duration;
    const intervalMs = 50;
    const decrement = 100 / (totalDuration * 1000 / intervalMs);
    this.timer = setInterval(() => {
      this.progress = Math.max(0, this.progress - decrement);
      if (this.progress <= 0) {
        clearInterval(this.timer);
        this.timer = -1;
        this.goToMain();
      }
    }, intervalMs);
  }

  private async goToMain(): Promise<void> {
    const accessToken: string = await TokenManager.getAccessToken();
    const refreshToken: string = await TokenManager.getRefreshToken();
    const cachedUser: string = await TokenManager.getUserInfo();
    const hasLocalAuth: boolean = accessToken.length > 0 || refreshToken.length > 0;

    if (hasLocalAuth) {
      AppStorage.setOrCreate('isLoggedIn', true);
      if (cachedUser.length > 0) {
        AppStorage.setOrCreate('currentUser', cachedUser);
      }
      router.replaceUrl({ url: 'pages/Index' }).catch((err: Error) => {
        console.error('[SplashAdPage] navigate failed: ' + err.message);
      });
      AuthManager.checkAuthOnStartup();
    } else {
      AppStorage.setOrCreate('isLoggedIn', false);
      router.replaceUrl({ url: AppConstants.ROUTE_LOGIN }).catch((err: Error) => {
        console.error('[SplashAdPage] navigate failed: ' + err.message);
      });
    }
  }

  private skipAd(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.goToMain();
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          if (this.adData.imageUrl !== '') {
            Image(this.adData.imageUrl)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          } else {
            Column() {
              Image($r('app.media.startIcon'))
                .width(80)
                .height(80)
                .borderRadius(20)
                .margin({ bottom: 32 })

              Text(this.adData.title)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .margin({ bottom: 12 })

              Text(this.adData.subtitle)
                .fontSize(16)
                .fontColor('rgba(255,255,255,0.85)')
                .textAlign(TextAlign.Center)
                .maxLines(2)
                .width('70%')
                .lineHeight(24)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .width('100%')
        .layoutWeight(1)

        Row() {
          Text('碳易链')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.6)')
            .margin({ left: 16 })

          Blank()

          Button() {
            Text(`跳过 ${Math.ceil(this.countdown * this.progress / 100)}s`)
              .fontSize(13)
              .fontColor(Color.White)
          }
          .backgroundColor('rgba(255,255,255,0.2)')
          .borderRadius(16)
          .height(32)
          .padding({ left: 12, right: 12 })
          .margin({ right: 16 })
          .scale({ x: this.btnScale, y: this.btnScale })
          .animation({ duration: 100, curve: Curve.EaseOut })
          .onClick(() => {
            animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.btnScale = 0.95; });
            setTimeout(() => { animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.btnScale = 1; }); }, 100);
            this.skipAd();
          })
        }
        .width('100%')
        .height(56)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')

      Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color('rgba(255,255,255,0.6)')
        .backgroundColor('rgba(255,255,255,0.15)')
        .position({ x: 0, y: 0 })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[ThemeManager.COLOR_PRIMARY, 0], ['#00695C', 0.5], ['#004D40', 1]]
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }
}