import { MallProduct } from '../models/MallProduct';
import { ExchangeRecord } from '../models/ExchangeRecord';
import { mallProductRepository } from '../repository/MallProductRepository';
import { exchangeRecordRepository } from '../repository/ExchangeRecordRepository';
import { creditAccountRepository } from '../repository/CreditAccountRepository';
import { AppConstants } from '../constants/AppConstants';
import { CreditEngine } from '../engine/CreditEngine';
import { ThemeManager } from '../theme/ThemeManager';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct CreditMallPage {
  @State products: MallProduct[] = [];
  @State balance: number = 0;
  @State selectedProduct: MallProduct | null = null;
  @State exchangeRecords: ExchangeRecord[] = [];
  @State showRecords: boolean = false;
  @State btnScale: number = 1;
  private userId: string = 'user_1';

  aboutToAppear(): void {
    this.products = mallProductRepository.getProducts();
    this.balance = creditAccountRepository.getBalance(this.userId);
    this.exchangeRecords = exchangeRecordRepository.getByUserId(this.userId);
  }

  doExchange(): void {
    if (!this.selectedProduct) return;
    const result = CreditEngine.exchangeCredits(this.userId, this.selectedProduct.id, this.selectedProduct.requiredCredits);
    if (result.success) {
      promptAction.showToast({ message: '兑换成功！' });
      this.balance = creditAccountRepository.getBalance(this.userId);
      this.products = mallProductRepository.getProducts();
      this.exchangeRecords = exchangeRecordRepository.getByUserId(this.userId);
    } else {
      promptAction.showToast({ message: result.message });
    }
    this.selectedProduct = null;
  }

  private getDisplayImage(image: string): string | Resource {
    if (image.length > 0) {
      return image;
    }
    return $r('app.media.startIcon');
  }

  build() {
    Column() {
      Row() {
        Text('积分商城')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
        Blank()
        Row({ space: 4 }) {
          Text('💰')
            .fontSize(14)
          Text(this.balance.toString())
            .fontSize(16)
            .fontColor(ThemeManager.COLOR_ACCENT)
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor('rgba(255,152,0,0.08)')
        .borderRadius(16)
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .margin({ top: AppConstants.STATUS_BAR_HEIGHT })

      Row() {
        Column() {
          Text('商品')
            .fontSize(14)
            .fontColor(!this.showRecords ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
            .fontWeight(!this.showRecords ? FontWeight.Medium : FontWeight.Normal)
          if (!this.showRecords) {
            Divider()
              .width(20)
              .height(2)
              .color(ThemeManager.COLOR_PRIMARY)
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => { this.showRecords = false; })

        Column() {
          Text('兑换记录')
            .fontSize(14)
            .fontColor(this.showRecords ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
            .fontWeight(this.showRecords ? FontWeight.Medium : FontWeight.Normal)
          if (this.showRecords) {
            Divider()
              .width(20)
              .height(2)
              .color(ThemeManager.COLOR_PRIMARY)
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => { this.showRecords = true; })
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .backgroundColor(Color.White)

      if (this.showRecords) {
        this.RecordsList()
      } else {
        this.ProductGrid()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }

  @Builder
  ProductGrid() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.products, (p: MallProduct) => {
          this.ProductCard(p)
        })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  ProductCard(p: MallProduct) {
    Row({ space: 12 }) {
      Stack() {
        Image(this.getDisplayImage(p.image))
          .width(64)
          .height(64)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
      }

      Column({ space: 4 }) {
        Text(p.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .maxLines(1)

        Text(p.description)
          .fontSize(12)
          .fontColor(ThemeManager.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 8 }) {
          Row({ space: 2 }) {
            Text('💰')
              .fontSize(11)
            Text(p.requiredCredits.toString())
              .fontSize(14)
              .fontColor(ThemeManager.COLOR_ACCENT)
              .fontWeight(FontWeight.Bold)
          }

          if (p.stock <= 0) {
            Text('已兑完')
              .fontSize(11)
              .fontColor(ThemeManager.TEXT_HINT)
          } else if (this.balance < p.requiredCredits) {
            Text('还差' + (p.requiredCredits - this.balance) + '积分')
              .fontSize(11)
              .fontColor(ThemeManager.TEXT_HINT)
          }

          Blank()

          if (p.stock > 0 && this.balance >= p.requiredCredits) {
            Text('兑换')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor(ThemeManager.COLOR_PRIMARY)
              .borderRadius(12)
              .padding({ left: 16, right: 16, top: 4, bottom: 4 })
              .scale({ x: this.btnScale, y: this.btnScale })
              .animation({ duration: 100, curve: Curve.EaseOut })
              .onClick(() => {
                this.selectedProduct = p;
                AlertDialog.show({
                  title: '确认兑换',
                  message: p.name + '\n所需积分: ' + p.requiredCredits + '\n当前余额: ' + this.balance,
                  primaryButton: {
                    value: '取消',
                    action: () => { this.selectedProduct = null; }
                  },
                  secondaryButton: {
                    value: '确认兑换',
                    action: () => { this.doExchange(); }
                  }
                });
              })
          } else if (p.stock > 0) {
            Text('兑换')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .backgroundColor('#F5F5F5')
              .borderRadius(12)
              .padding({ left: 16, right: 16, top: 4, bottom: 4 })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .borderRadius(AppConstants.RADIUS_MD)
    .backgroundColor(ThemeManager.BG_CARD)
    .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
  }

  @Builder
  RecordsList() {
    if (this.exchangeRecords.length === 0) {
      Column() {
        Image($r('app.media.startIcon'))
          .width(48)
          .height(48)
          .fillColor(ThemeManager.TEXT_HINT)
          .opacity(0.5)
        Text('暂无兑换记录')
          .fontSize(14)
          .fontColor(ThemeManager.TEXT_HINT)
          .margin({ top: 12 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.exchangeRecords, (r: ExchangeRecord) => {
          ListItem() {
            Row() {
              Column({ space: 2 }) {
                Text(r.productId)
                  .fontSize(14)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)
                Text(new Date(r.timestamp).toLocaleDateString())
                  .fontSize(12)
                  .fontColor(ThemeManager.TEXT_HINT)
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Text('-' + r.creditsSpent + '积分')
                .fontSize(14)
                .fontColor(ThemeManager.COLOR_PRICE)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding(12)
            .borderRadius(AppConstants.RADIUS_MD)
            .backgroundColor(ThemeManager.BG_CARD)
          }
          .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
        })
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12 })
    }
  }
}
