import { router } from '@kit.ArkUI';
import { HttpService, ApiResponse } from '../services/HttpService';
import { ThemeManager } from '../theme/ThemeManager';
import { promptAction } from '@kit.ArkUI';
import { AppConstants } from '../constants/AppConstants';


@Entry
@Component
struct ChangePasswordPage {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State showOldPassword: boolean = false;
  @State showNewPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State isSaving: boolean = false;
  @State oldError: string = '';
  @State newError: string = '';
  @State confirmError: string = '';


  validateForm(): boolean {
    this.oldError = '';
    this.newError = '';
    this.confirmError = '';

    if (this.oldPassword.length < 6) {
      this.oldError = '请输入原密码';
    }

    if (this.newPassword.length < 6) {
      this.newError = '新密码至少6位';
    }

    if (this.confirmPassword !== this.newPassword) {
      this.confirmError = '两次密码不一致';
    }

    return this.oldError.length === 0 && this.newError.length === 0 && this.confirmError.length === 0;
  }

  async handleChangePassword(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }

    if (this.isSaving) {
      return;
    }

    this.isSaving = true;

    const reqBody: Record<string, string | number | object> = {
      'oldPassword': this.oldPassword,
      'newPassword': this.newPassword
    };

    const response: ApiResponse = await HttpService.PUT('/password', reqBody);

    this.isSaving = false;

    if (response.code === 0) {
      promptAction.showToast({ message: '密码修改成功，请重新登录' });
      router.back();
    } else {
      promptAction.showToast({ message: response.message || '修改失败' });
    }
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
          .scale({ x: 1, y: 1 })
          .animation({ duration: 100, curve: Curve.EaseOut })

        Text('修改密码')
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
        Column() {
          Row() {
            TextInput({ placeholder: '请输入原密码', text: this.oldPassword })
              .type(this.showOldPassword ? InputType.Normal : InputType.Password)
              .placeholderColor('#CCCCCC')
              .fontColor('#333333')
              .fontSize(16)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.oldPassword = value;
                this.oldError = '';
              })

            Image(this.showOldPassword ? $r('sys.symbol.eye') : $r('sys.symbol.eye_slash'))
              .width(22)
              .height(22)
              .fillColor('#999999')
              .onClick(() => {
                this.showOldPassword = !this.showOldPassword;
              })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 12 })
        .height(50)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')

        if (this.oldError.length > 0) {
          Text(this.oldError)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .margin({ top: 4, left: 4 })
            .width('100%')
        }

        Column() {
          Row() {
            TextInput({ placeholder: '请输入新密码（至少6位）', text: this.newPassword })
              .type(this.showNewPassword ? InputType.Normal : InputType.Password)
              .placeholderColor('#CCCCCC')
              .fontColor('#333333')
              .fontSize(16)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.newPassword = value;
                this.newError = '';
              })

            Image(this.showNewPassword ? $r('sys.symbol.eye') : $r('sys.symbol.eye_slash'))
              .width(22)
              .height(22)
              .fillColor('#999999')
              .onClick(() => {
                this.showNewPassword = !this.showNewPassword;
              })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 12 })
        .height(50)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')
        .margin({ top: 12 })

        if (this.newError.length > 0) {
          Text(this.newError)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .margin({ top: 4, left: 4 })
            .width('100%')
        }

        Column() {
          Row() {
            TextInput({ placeholder: '请确认新密码', text: this.confirmPassword })
              .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
              .placeholderColor('#CCCCCC')
              .fontColor('#333333')
              .fontSize(16)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.confirmPassword = value;
                this.confirmError = '';
              })

            Image(this.showConfirmPassword ? $r('sys.symbol.eye') : $r('sys.symbol.eye_slash'))
              .width(22)
              .height(22)
              .fillColor('#999999')
              .onClick(() => {
                this.showConfirmPassword = !this.showConfirmPassword;
              })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 12 })
        .height(50)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')
        .margin({ top: 12 })

        if (this.confirmError.length > 0) {
          Text(this.confirmError)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .margin({ top: 4, left: 4 })
            .width('100%')
        }

        Button(this.isSaving ? '保存中...' : '确认修改')
          .width('100%')
          .height(48)
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor(ThemeManager.COLOR_PRIMARY)
          .borderRadius(24)
          .margin({ top: 32 })
          .enabled(!this.isSaving)
          .onClick(() => {
            this.handleChangePassword();
          })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
      .margin({ top: 20 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)


  }
}