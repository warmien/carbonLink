import { router } from '@kit.ArkUI';
import { AuthManager } from '../services/AuthManager';
import { AppConstants } from '../constants/AppConstants';
import { promptAction } from '@kit.ArkUI';


@Entry
@Component
struct SettingsPage {
  @State nickname: string = '';
  @State avatar: string = '';

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
    await AuthManager.logout();
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

      Column() {
        this.SettingItem('个人信息', () => {
          router.pushUrl({ url: 'pages/EditProfilePage' }).catch(() => {});
        })

        Divider().color('#F0F0F0').padding({ left: 16, right: 16 })

        this.SettingItem('修改密码', () => {
          router.pushUrl({ url: 'pages/ChangePasswordPage' }).catch(() => {});
        })

        Divider().color('#F0F0F0').padding({ left: 16, right: 16 })

        this.SettingItem('关于我们', () => {
          console.info('[SettingsPage] about us clicked');
        })
      }
      .width('100%')
      .margin({ top: 12 })
      .backgroundColor(Color.White)
      .borderRadius(12)

      Column() {
        Text('退出登录')
          .fontSize(16)
          .fontColor('#FF4D4F')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.showLogoutConfirm();
          })
      }
      .width('100%')
      .height(52)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 32 })
      .backgroundColor(Color.White)
      .borderRadius(12)

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F5F5F5')
  }

  @Builder
  SettingItem(title: string, action: () => void) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)

      Image($r('sys.symbol.chevron_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      action();
    })
  }
}
