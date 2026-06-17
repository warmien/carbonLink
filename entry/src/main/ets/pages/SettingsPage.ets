import { router } from '@kit.ArkUI';
import { AuthManager } from '../services/AuthManager';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State nickname: string = '';
  @State avatar: string = '';
  @State notificationEnabled: boolean = true;
  @State locationEnabled: boolean = false;
  @State cacheSize: string = '12.3 MB';
  @State isLoggingOut: boolean = false;
  @State currentVersion: string = '1.0.0';

  async aboutToAppear(): Promise<void> {
    const userJson: string = AppStorage.get<string>('currentUser') || '';
    if (userJson.length > 0) {
      try {
        const userObj: Record<string, string | number> = JSON.parse(userJson) as Record<string, string | number>;
        this.nickname = userObj['nickname'] as string;
        this.avatar = userObj['avatar'] as string;
      } catch (err) {
        console.error(`[SettingsPage] parse user failed: ${(err as Error).message}`);
      }
    }
  }

  async handleLogout(): Promise<void> {
    this.isLoggingOut = true;
    await AuthManager.logout();
    this.isLoggingOut = false;
  }

  private showLogoutConfirm(): void {
    promptAction.showDialog({
      title: '提示',
      message: '确定要退出登录吗？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确定', color: '#FF4D4F' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.handleLogout();
      }
    }).catch(() => {});
  }

  private showClearCacheConfirm(): void {
    promptAction.showDialog({
      title: '清除缓存',
      message: '确定要清除所有缓存数据吗？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确定', color: ThemeManager.COLOR_PRIMARY }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.cacheSize = '0 MB';
        promptAction.showToast({ message: '缓存已清除' });
      }
    }).catch(() => {});
  }

  build() {
    Column() {
      Column().height(AppConstants.STATUS_BAR_HEIGHT).width('100%')

      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 24 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 12 }) {
          this.AccountSection()
          this.GeneralSection()
          this.SupportSection()
          this.LogoutButton()
          Blank().height(40)
        }
        .padding({ left: 16, right: 16, top: 4 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }

  @Builder
  AccountSection() {
    Column() {
      Row() {
        Image(this.avatar.length > 0 ? this.avatar : $r('sys.symbol.person_crop_circle_fill'))
          .width(48)
          .height(48)
          .borderRadius(24)
          .objectFit(ImageFit.Cover)

        Column() {
          Text(this.nickname.length > 0 ? this.nickname : '未登录')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.TEXT_PRIMARY)
          Text('管理你的账号信息')
            .fontSize(13)
            .fontColor(ThemeManager.TEXT_HINT)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)

        Image($r('sys.symbol.chevron_right'))
          .width(16)
          .height(16)
          .fillColor(ThemeManager.TEXT_HINT)
      }
      .width('100%')
      .height(72)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/EditProfilePage' }).catch(() => {});
      })

      Divider().color('#F0F0F0').margin({ left: 76 })

      this.SettingItem('修改密码', $r('sys.symbol.lock_fill'), '#FAAD14', () => {
        router.pushUrl({ url: 'pages/ChangePasswordPage' }).catch(() => {});
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  GeneralSection() {
    Column() {
      Text('通用')
        .fontSize(13)
        .fontColor(ThemeManager.TEXT_HINT)
        .padding({ left: 16, top: 12, bottom: 4 })

      Column() {
        this.ToggleItem('消息通知', $r('sys.symbol.bell_fill'), '#1890FF', this.notificationEnabled, (val: boolean) => {
          this.notificationEnabled = val;
        })

        Divider().color('#F0F0F0').margin({ left: 48 })

        this.ToggleItem('位置服务', $r('sys.symbol.bell_fill'), '#52C41A', this.locationEnabled, (val: boolean) => {
          this.locationEnabled = val;
        })

        Divider().color('#F0F0F0').margin({ left: 48 })

        this.SettingItemWithExtra('清除缓存', $r('sys.symbol.trash_fill'), '#FF4D4F', this.cacheSize, () => {
          this.showClearCacheConfirm();
        })

        Divider().color('#F0F0F0').margin({ left: 48 })

        this.SettingItemWithExtra('语言', $r('sys.symbol.doc_text_fill'), '#722ED1', '简体中文', () => {
          promptAction.showToast({ message: '暂仅支持简体中文' });
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  SupportSection() {
    Column() {
      Text('支持')
        .fontSize(13)
        .fontColor(ThemeManager.TEXT_HINT)
        .padding({ left: 16, top: 12, bottom: 4 })

      Column() {
        this.SettingItem('用户协议', $r('sys.symbol.doc_text_fill'), '#1890FF', () => {
          promptAction.showToast({ message: '用户协议页面开发中' });
        })

        Divider().color('#F0F0F0').margin({ left: 48 })

        this.SettingItem('隐私政策', $r('sys.symbol.checkmark_shield_fill'), '#52C41A', () => {
          promptAction.showToast({ message: '隐私政策页面开发中' });
        })

        Divider().color('#F0F0F0').margin({ left: 48 })

        this.SettingItem('意见反馈', $r('sys.symbol.heart_fill'), '#FAAD14', () => {
          promptAction.showToast({ message: '意见反馈功能开发中' });
        })

        Divider().color('#F0F0F0').margin({ left: 48 })

        this.SettingItemWithExtra('关于碳易链', $r('sys.symbol.info_circle_fill'), '#13C2C2', 'v' + this.currentVersion, () => {
          promptAction.showToast({ message: '碳易链 v' + this.currentVersion });
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  LogoutButton() {
    Column() {
      Text('退出登录')
        .fontSize(16)
        .fontColor('#FF4D4F')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .scale({ x: this.isLoggingOut ? 0.95 : 1, y: this.isLoggingOut ? 0.95 : 1 })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onClick(() => {
      this.showLogoutConfirm();
    })
  }

  @Builder
  SettingItem(title: string, icon: Resource, iconColor: string, action: () => void) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor(iconColor)
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ left: 12 })
        .layoutWeight(1)
      Image($r('sys.symbol.chevron_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      action();
    })
  }

  @Builder
  SettingItemWithExtra(title: string, icon: Resource, iconColor: string, extra: string, action: () => void) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor(iconColor)
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ left: 12 })
        .layoutWeight(1)
      Text(extra)
        .fontSize(14)
        .fontColor(ThemeManager.TEXT_HINT)
        .margin({ right: 4 })
      Image($r('sys.symbol.chevron_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      action();
    })
  }

  @Builder
  ToggleItem(title: string, icon: Resource, iconColor: string, isOn: boolean, onChange: (val: boolean) => void) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor(iconColor)
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ left: 12 })
        .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .width(48)
        .height(28)
        .selectedColor(ThemeManager.COLOR_PRIMARY)
        .onChange((isOn: boolean) => {
          onChange(isOn);
        })
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }
}
