import { router } from '@kit.ArkUI';
import { AuthManager } from '../services/AuthManager';
import { ApiResponse, HttpService } from '../services/HttpService';
import { CaptchaService, CaptchaData } from '../services/CaptchaService';
import { FormValidator, ValidationResult } from '../utils/FormValidator';
import { ThemeManager } from '../theme/ThemeManager';
import { ImageDisplayUtil } from '../components/ImagePickerPanel';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const PREF_NAME: string = 'carbonlink_login';
const KEY_REMEMBER_PHONE: string = 'remember_phone';
const KEY_PHONE: string = 'saved_phone';

@Entry
@Component
struct LoginPage {
  @State phone: string = '';
  @State password: string = '';
  @State captchaValue: string = '';
  @State captchaKey: string = '';
  @State captchaImage: string = '';
  @State captchaText: string = '';
  @State showPassword: boolean = false;
  @State rememberMe: boolean = false;
  @State isLoading: boolean = false;
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State captchaError: string = '';
  @State captchaLoading: boolean = false;
  @State loginError: string = '';
  @State captchaOpacity: number = 1.0;
  @State userAvatar: string = '';
  @State userNickname: string = '';
  @State avatarScale: number = 0.8;
  @State avatarOpacity: number = 0;
  private phoneDebounceId: number = 0;

  async aboutToAppear(): Promise<void> {
    const isLoggedIn: boolean = AppStorage.get<boolean>('isLoggedIn') || false;
    if (isLoggedIn) {
      router.replaceUrl({ url: 'pages/Index' }).catch(() => {});
      return;
    }

    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const pref: preferences.Preferences = await preferences.getPreferences(context, PREF_NAME);
      const savedPhone: string = (await pref.get(KEY_PHONE, '')) as string;
      const rememberFlag: string = (await pref.get(KEY_REMEMBER_PHONE, '')) as string;
      if (rememberFlag === 'true' && savedPhone.length > 0) {
        this.phone = savedPhone;
        this.rememberMe = true;
        this.fetchUserAvatar(savedPhone);
      }
    } catch (err) {
      console.error(`[LoginPage] loadRememberMe failed: ${(err as Error).message}`);
    }

    await this.loadCaptcha();
  }

  private async fetchUserAvatar(phoneNum: string): Promise<void> {
    if (phoneNum.length !== 11) {
      this.userAvatar = '';
      this.userNickname = '';
      this.avatarOpacity = 0;
      return;
    }
    try {
      const resp: ApiResponse = await HttpService.GET('/phone-avatar?phone=' + phoneNum);
      if (resp.code === 0 && resp.data !== null) {
        const avatar: string = (typeof resp.data['avatar'] === 'string') ? resp.data['avatar'] as string : '';
        const nickname: string = (typeof resp.data['nickname'] === 'string') ? resp.data['nickname'] as string : '';
        this.userAvatar = avatar;
        this.userNickname = nickname;
        if (avatar.length > 0 || nickname.length > 0) {
          animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            this.avatarOpacity = 1;
            this.avatarScale = 1;
          });
        }
      }
    } catch (err) {
      this.userAvatar = '';
      this.userNickname = '';
    }
  }

  onPhoneChange(value: string): void {
    this.phone = value;
    this.phoneError = '';
    this.loginError = '';
    clearTimeout(this.phoneDebounceId);
    if (value.length === 11) {
      this.phoneDebounceId = setTimeout(() => {
        this.fetchUserAvatar(value);
      }, 500);
    } else {
      this.userAvatar = '';
      this.userNickname = '';
      this.avatarOpacity = 0;
      this.avatarScale = 0.8;
    }
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
    this.captchaError = '';

    const phoneResult: ValidationResult = FormValidator.validatePhone(this.phone);
    if (!phoneResult.valid) {
      this.phoneError = phoneResult.message;
    }

    const passwordResult: ValidationResult = FormValidator.validatePassword(this.password);
    if (!passwordResult.valid) {
      this.passwordError = passwordResult.message;
    }

    const captchaResult: ValidationResult = FormValidator.validateCaptcha(this.captchaValue);
    if (!captchaResult.valid) {
      this.captchaError = captchaResult.message;
    }

    return phoneResult.valid && passwordResult.valid && captchaResult.valid;
  }

  async handleLogin(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }

    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.loginError = '';

    try {
      const response: ApiResponse = await AuthManager.login(this.phone, this.password, this.captchaKey, this.captchaValue);

      if (response.code === 0) {
        if (this.rememberMe) {
          try {
            const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
            const pref: preferences.Preferences = await preferences.getPreferences(context, PREF_NAME);
            await pref.put(KEY_PHONE, this.phone);
            await pref.put(KEY_REMEMBER_PHONE, 'true');
            await pref.flush();
          } catch (err) {
            console.error(`[LoginPage] saveRememberMe failed: ${(err as Error).message}`);
          }
        } else {
          try {
            const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
            const pref: preferences.Preferences = await preferences.getPreferences(context, PREF_NAME);
            await pref.delete(KEY_PHONE);
            await pref.delete(KEY_REMEMBER_PHONE);
            await pref.flush();
          } catch (err) {
            console.error(`[LoginPage] clearRememberMe failed: ${(err as Error).message}`);
          }
        }

        router.replaceUrl({ url: 'pages/Index' }).catch(() => {});
      } else {
        this.loginError = response.message;
        await this.loadCaptcha();
        this.captchaValue = '';
      }
    } catch (err) {
      this.loginError = '登录失败，请检查网络连接后重试';
      await this.loadCaptcha();
      this.captchaValue = '';
    } finally {
      this.isLoading = false;
    }
  }

  enterAsGuest(): void {
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('isGuest', true);
    router.replaceUrl({ url: 'pages/Index' }).catch(() => {});
  }

  build() {
    Column() {
      Column() {
        Column() {
          Image(ImageDisplayUtil.getDisplaySrc(this.userAvatar))
            .width(72)
            .height(72)
            .borderRadius(36)
            .scale({ x: this.avatarScale, y: this.avatarScale })
            .opacity(this.avatarOpacity)
            .margin({ bottom: 8 })

          if (this.userNickname.length > 0) {
            Text(this.userNickname)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .opacity(this.avatarOpacity)
              .margin({ bottom: 4 })
          }

          if (this.userAvatar.length === 0 && this.userNickname.length === 0) {
            Text('欢迎回来')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 4 })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .height(100)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 32 })

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
                this.onPhoneChange(value);
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
              TextInput({ placeholder: '请输入密码', text: this.password })
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .placeholderColor('#CCCCCC')
                .fontColor('#333333')
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.password = value;
                  this.passwordError = '';
                  this.loginError = '';
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
                this.loginError = '';
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
              .select(this.rememberMe)
              .onChange((isChecked: boolean) => {
                this.rememberMe = isChecked;
              })
              .width(18)
              .height(18)
              .selectedColor(ThemeManager.COLOR_PRIMARY)

            Text('记住我')
              .fontSize(13)
              .fontColor('#666666')
              .margin({ left: 6 })
          }
          .width('100%')
          .margin({ top: 12 })

          if (this.loginError.length > 0) {
            Text(this.loginError)
              .fontSize(13)
              .fontColor('#FF4D4F')
              .margin({ top: 8 })
              .width('100%')
              .textAlign(TextAlign.Center)
          }

          Button(this.isLoading ? '登录中...' : '登录')
            .width('100%')
            .height(48)
            .fontSize(18)
            .fontColor(Color.White)
            .backgroundColor(ThemeManager.COLOR_PRIMARY)
            .borderRadius(24)
            .margin({ top: 24 })
            .enabled(!this.isLoading)
            .scale({ x: this.isLoading ? 0.98 : 1, y: this.isLoading ? 0.98 : 1 })
            .animation({ duration: 100, curve: Curve.EaseOut })
            .onClick(() => {
              this.handleLogin();
            })

          Row() {
            Text('忘记密码？')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ right: 24 })

            Text('还没有账号？')
              .fontSize(13)
              .fontColor('#999999')

            Text('立即注册 >')
              .fontSize(13)
              .fontColor(ThemeManager.COLOR_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 4 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/RegisterPage' }).catch(() => {});
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 20 })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Row() {
        Text('暂不登录，')
          .fontSize(13)
          .fontColor('#999999')

        Text('游客模式进入 >')
          .fontSize(13)
          .fontColor(ThemeManager.COLOR_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.enterAsGuest();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 16, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
