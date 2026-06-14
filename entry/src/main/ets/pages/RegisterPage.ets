import { router } from '@kit.ArkUI';
import { AuthManager } from '../services/AuthManager';
import { CaptchaService, CaptchaData } from '../services/CaptchaService';
import { FormValidator, ValidationResult } from '../utils/FormValidator';
import { ThemeManager } from '../theme/ThemeManager';

@Entry
@Component
struct RegisterPage {
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State captchaValue: string = '';
  @State captchaKey: string = '';
  @State captchaImage: string = '';
  @State captchaText: string = '';
  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State agreeTerms: boolean = false;
  @State isLoading: boolean = false;
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State confirmError: string = '';
  @State captchaError: string = '';
  @State registerError: string = '';
  @State captchaOpacity: number = 1.0;
  @State captchaLoading: boolean = false;
  @State showTermsDialog: boolean = false;
  @State termsType: string = '';

  async aboutToAppear(): Promise<void> {
    const isLoggedIn: boolean = AppStorage.get<boolean>('isLoggedIn') || false;
    if (isLoggedIn) {
      router.replaceUrl({ url: 'pages/Index' }).catch(() => {});
      return;
    }
    await this.loadCaptcha();
  }

  async loadCaptcha(): Promise<void> {
    this.captchaLoading = true;
    this.captchaOpacity = 0.3;
    const data: CaptchaData | null = await CaptchaService.getCaptcha();
    if (data !== null) {
      this.captchaKey = data.captchaKey;
      this.captchaImage = data.captchaImage;
      this.captchaText = data.captchaText;
    }
    this.captchaLoading = false;
    this.captchaOpacity = 1.0;
  }

  validateForm(): boolean {
    this.phoneError = '';
    this.passwordError = '';
    this.confirmError = '';
    this.captchaError = '';

    const phoneResult: ValidationResult = FormValidator.validatePhone(this.phone);
    if (!phoneResult.valid) {
      this.phoneError = phoneResult.message;
    }

    const passwordResult: ValidationResult = FormValidator.validatePassword(this.password);
    if (!passwordResult.valid) {
      this.passwordError = passwordResult.message;
    }

    const confirmResult: ValidationResult = FormValidator.validateConfirmPassword(this.password, this.confirmPassword);
    if (!confirmResult.valid) {
      this.confirmError = confirmResult.message;
    }

    const captchaResult: ValidationResult = FormValidator.validateCaptcha(this.captchaValue);
    if (!captchaResult.valid) {
      this.captchaError = captchaResult.message;
    }

    if (!this.agreeTerms) {
      this.registerError = '请阅读并同意用户协议和隐私政策';
      return false;
    } else {
      this.registerError = '';
    }

    return phoneResult.valid && passwordResult.valid && confirmResult.valid && captchaResult.valid;
  }

  async handleRegister(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }

    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.registerError = '';

    const response = await AuthManager.register(this.phone, this.password, this.captchaKey, this.captchaValue);

    this.isLoading = false;

    if (response.code === 0) {
      router.replaceUrl({ url: 'pages/Index' }).catch(() => {});
    } else {
      this.registerError = response.message;
      await this.loadCaptcha();
      this.captchaValue = '';
    }
  }

  build() {
    Column() {
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

        Text('注册账号')
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
        Column() {
          Column() {
            Column() {
              TextInput({ placeholder: '请输入手机号', text: this.phone })
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .placeholderColor('#CCCCCC')
                .fontColor('#333333')
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .onChange((value: string) => {
                  this.phone = value;
                  this.phoneError = '';
                  this.registerError = '';
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .height(50)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')

            if (this.phoneError.length > 0) {
              Text(this.phoneError)
                .fontSize(12)
                .fontColor('#FF4D4F')
                .margin({ top: 4, left: 4 })
                .width('100%')
            }

            Column() {
              Row() {
                TextInput({ placeholder: '请设置密码（至少6位）', text: this.password })
                  .type(this.showPassword ? InputType.Normal : InputType.Password)
                  .placeholderColor('#CCCCCC')
                  .fontColor('#333333')
                  .fontSize(16)
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .onChange((value: string) => {
                    this.password = value;
                    this.passwordError = '';
                    this.registerError = '';
                  })

                Image(this.showPassword ? $r('sys.symbol.eye') : $r('sys.symbol.eye_slash'))
                  .width(22)
                  .height(22)
                  .fillColor('#999999')
                  .onClick(() => {
                    this.showPassword = !this.showPassword;
                  })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 12 })
            .height(50)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
            .margin({ top: 12 })

            if (this.passwordError.length > 0) {
              Text(this.passwordError)
                .fontSize(12)
                .fontColor('#FF4D4F')
                .margin({ top: 4, left: 4 })
                .width('100%')
            }

            Column() {
              Row() {
                TextInput({ placeholder: '请确认密码', text: this.confirmPassword })
                  .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
                  .placeholderColor('#CCCCCC')
                  .fontColor('#333333')
                  .fontSize(16)
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .onChange((value: string) => {
                    this.confirmPassword = value;
                    this.confirmError = '';
                    this.registerError = '';
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

            Row() {
              if (this.captchaText.length > 0) {
                Text(this.captchaText)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#4A4A4A')
                  .letterSpacing(6)
                  .fontStyle(FontStyle.Italic)
                  .width(100)
                  .height(40)
                  .borderRadius(4)
                  .backgroundColor('#F0F0F0')
                  .textAlign(TextAlign.Center)
                  .opacity(this.captchaOpacity)
                  .onClick(() => {
                    this.loadCaptcha();
                  })
              } else {
                Column() {
                  if (this.captchaLoading) {
                    LoadingProgress()
                      .width(20)
                      .height(20)
                      .color(ThemeManager.COLOR_PRIMARY)
                  } else {
                    Text('点击刷新')
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                }
                .width(100)
                .height(40)
                .borderRadius(4)
                .backgroundColor('#F0F0F0')
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.loadCaptcha();
                })
              }

              TextInput({ placeholder: '验证码', text: this.captchaValue })
                .type(InputType.Normal)
                .maxLength(6)
                .placeholderColor('#CCCCCC')
                .fontColor('#333333')
                .fontSize(16)
                .backgroundColor('#F5F5F5')
                .layoutWeight(1)
                .margin({ left: 8 })
                .onChange((value: string) => {
                  this.captchaValue = value;
                  this.captchaError = '';
                  this.registerError = '';
                })
            }
            .width('100%')
            .margin({ top: 12 })

            if (this.captchaError.length > 0) {
              Text(this.captchaError)
                .fontSize(12)
                .fontColor('#FF4D4F')
                .margin({ top: 4, left: 4 })
                .width('100%')
            }

            Row() {
              Checkbox()
                .select(this.agreeTerms)
                .onChange((isChecked: boolean) => {
                  this.agreeTerms = isChecked;
                  if (isChecked) {
                    this.registerError = '';
                  }
                })
                .width(18)
                .height(18)
                .selectedColor(ThemeManager.COLOR_PRIMARY)

              Text() {
                Span('我已阅读并同意')
                  .fontSize(12)
                  .fontColor('#999999')
                Span('《用户协议》')
                  .fontSize(12)
                  .fontColor(ThemeManager.COLOR_PRIMARY)
                  .decoration({ type: TextDecorationType.None })
                Span('和')
                  .fontSize(12)
                  .fontColor('#999999')
                Span('《隐私政策》')
                  .fontSize(12)
                  .fontColor(ThemeManager.COLOR_PRIMARY)
              }
              .margin({ left: 6 })
            }
            .width('100%')
            .margin({ top: 12 })

            if (this.registerError.length > 0) {
              Text(this.registerError)
                .fontSize(13)
                .fontColor('#FF4D4F')
                .margin({ top: 8 })
                .width('100%')
                .textAlign(TextAlign.Center)
            }

            Button(this.isLoading ? '注册中...' : '注册')
              .width('100%')
              .height(48)
              .fontSize(18)
              .fontColor(Color.White)
              .backgroundColor(ThemeManager.COLOR_PRIMARY)
              .borderRadius(24)
              .margin({ top: 24 })
              .enabled(!this.isLoading)
              .onClick(() => {
                this.handleRegister();
              })

            Row() {
              Text('已有账号？')
                .fontSize(13)
                .fontColor('#999999')

              Text('立即登录 >')
                .fontSize(13)
                .fontColor(ThemeManager.COLOR_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .margin({ left: 4 })
                .onClick(() => {
                  router.back();
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 20, bottom: 32 })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 32, right: 32 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}