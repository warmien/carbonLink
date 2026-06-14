import { MallProduct } from '../models/MallProduct';
import { ExchangeRecord } from '../models/ExchangeRecord';
import { mallProductRepository } from '../repository/MallProductRepository';
import { exchangeRecordRepository } from '../repository/ExchangeRecordRepository';
import { creditAccountRepository } from '../repository/CreditAccountRepository';
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

  build() {
    Column() {
      Row() {
        Text('积分商城')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
        Blank()
        Text('余额: ' + this.balance)
          .fontSize(14)
          .fontColor(ThemeManager.COLOR_PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      this.ContentArea()

      Row() {
        Text('商品')
          .fontSize(14)
          .fontColor(!this.showRecords ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
          .fontWeight(!this.showRecords ? FontWeight.Medium : FontWeight.Normal)
          .onClick(() => { this.showRecords = false; })
        Text('兑换记录')
          .fontSize(14)
          .fontColor(this.showRecords ? ThemeManager.COLOR_PRIMARY : ThemeManager.TEXT_HINT)
          .fontWeight(this.showRecords ? FontWeight.Medium : FontWeight.Normal)
          .onClick(() => { this.showRecords = true; })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding(12)
      .border({ width: 1, color: '#F0F0F0' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))

  }

  @Builder
  ContentArea() {
    if (this.showRecords) {
      this.RecordsList()
    } else {
      this.ProductGrid()
    }
  }

  @Builder
  ProductGrid() {
    Scroll() {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignContent: FlexAlign.Start }) {
        ForEach(this.products, (p: MallProduct) => {
          Column() {
            this.ProductCard(p)
          }
          .margin(6)
          .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
        })
      }
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder
  ProductCard(p: MallProduct) {
    Column() {
      Row() {
        Text(p.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')

      Text(p.description)
        .fontSize(12)
        .fontColor(ThemeManager.TEXT_HINT)
        .margin({ top: 4 })
        .maxLines(2)

      Row() {
        Text(p.requiredCredits + '积分')
          .fontSize(14)
          .fontColor(ThemeManager.COLOR_ACCENT)
          .fontWeight(FontWeight.Medium)

        Blank()

        if (p.stock <= 0) {
          Text('已兑完')
            .fontSize(12)
            .fontColor(ThemeManager.TEXT_HINT)
        } else if (this.balance < p.requiredCredits) {
          Text('还差' + (p.requiredCredits - this.balance) + '积分')
            .fontSize(12)
            .fontColor(ThemeManager.TEXT_HINT)
        } else {
          Text('兑换')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor(ThemeManager.COLOR_PRIMARY)
            .borderRadius(12)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
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
        }
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('48%')
    .padding(12)
    .borderRadius(12)
    .backgroundColor(ThemeManager.BG_CARD)
  }

  @Builder
  RecordsList() {
    List() {
      ForEach(this.exchangeRecords, (r: ExchangeRecord) => {
        ListItem() {
          Row() {
            Text(r.productId)
              .fontSize(14)
              .fontColor(ThemeManager.TEXT_PRIMARY)
            Blank()
            Text('-' + r.creditsSpent + '积分')
              .fontSize(14)
              .fontColor(ThemeManager.COLOR_PRICE)
          }
          .width('100%')
          .padding(12)
        }
        .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
      })
    }
    .layoutWeight(1)
    .padding(16)
  }

}
