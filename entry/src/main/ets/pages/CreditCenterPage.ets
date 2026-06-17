import { CreditAccount, UserLevel } from '../models/CreditAccount';
import { creditAccountRepository } from '../repository/CreditAccountRepository';
import { creditTransactionRepository } from '../repository/CreditTransactionRepository';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';
import { RouterManager } from '../router/RouterManager';

@Entry
@Component
struct CreditCenterPage {
  @State balance: number = 0;
  @State totalEarned: number = 0;
  @State level: UserLevel = UserLevel.BEGINNER;
  @State todayEarned: number = 0;
  @State levelProgress: number = 0;
  @State nextLevelThreshold: number = 100;
  @State totalReduction: number = 0;
  @State btnScale: number = 1;
  private userId: string = 'user_1';

  aboutToAppear(): void {
    this.loadCreditData();
  }

  loadCreditData(): void {
    const account = creditAccountRepository.getOrCreate(this.userId);
    this.balance = account.balance;
    this.totalEarned = account.totalEarned;
    this.level = account.level;
    this.todayEarned = creditTransactionRepository.getTodayEarned(this.userId);
    this.totalReduction = creditTransactionRepository.getTotalReduction(this.userId);
    this.calcLevelProgress();
  }

  calcLevelProgress(): void {
    const thresholds = [0, 100, 500, 2000, 5000];
    let currentIdx = 0;
    for (let i = thresholds.length - 1; i >= 0; i--) {
      if (this.totalEarned >= thresholds[i]) {
        currentIdx = i;
        break;
      }
    }
    if (currentIdx >= thresholds.length - 1) {
      this.levelProgress = 100;
      this.nextLevelThreshold = thresholds[thresholds.length - 1];
    } else {
      const currentThreshold = thresholds[currentIdx];
      this.nextLevelThreshold = thresholds[currentIdx + 1];
      const range = this.nextLevelThreshold - currentThreshold;
      this.levelProgress = range > 0 ? Math.floor(((this.totalEarned - currentThreshold) / range) * 100) : 0;
    }
  }

  build() {
    Column() {
      Row() {
        Text('碳积分中心')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
      .margin({ top: AppConstants.STATUS_BAR_HEIGHT })

      Scroll() {
        Column({ space: 16 }) {
          this.CreditOverviewCard()
          this.QuickActions()
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }

  @Builder
  CreditOverviewCard() {
    Column() {
      Row() {
        Text(this.level)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(ThemeManager.COLOR_PRIMARY)
          .borderRadius(12)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text('积分余额')
        .fontSize(13)
        .fontColor(ThemeManager.TEXT_SECONDARY)
      Text(this.balance.toString())
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeManager.COLOR_PRIMARY)
        .margin({ top: 4, bottom: 16 })

      Row() {
        Column() {
          Text('今日获取')
            .fontSize(11)
            .fontColor(ThemeManager.TEXT_HINT)
          Text('+' + this.todayEarned)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Column() {
          Text('累计获得')
            .fontSize(11)
            .fontColor(ThemeManager.TEXT_HINT)
          Text(this.totalEarned.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.TEXT_PRIMARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Column() {
          Text('碳减排量')
            .fontSize(11)
            .fontColor(ThemeManager.TEXT_HINT)
          Text(this.totalReduction.toFixed(1) + 'kg')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.COLOR_PRIMARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Column() {
          Text('等级进度')
            .fontSize(11)
            .fontColor(ThemeManager.TEXT_HINT)
          Text(this.levelProgress + '%')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.COLOR_ACCENT)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
      }
      .width('100%')

      Progress({ value: this.levelProgress, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(6)
        .color(ThemeManager.COLOR_PRIMARY)
        .backgroundColor('#E8E8E8')
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(20)
    .borderRadius(16)
    .backgroundColor(ThemeManager.BG_CARD)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  QuickActions() {
    Column() {
      Text('快捷入口')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeManager.TEXT_PRIMARY)
        .margin({ bottom: 12 })

      Row() {
        this.ActionItem('积分流水', '#1890FF', $r('sys.symbol.doc_text_fill'), () => {
          RouterManager.toCreditLedger();
        })
        this.ActionItem('环保成就', '#52C41A', $r('sys.symbol.leaf_fill'), () => {
          RouterManager.toEcoAchievement();
        })
        this.ActionItem('积分商城', '#FAAD14', $r('sys.symbol.gift_fill'), () => {
          RouterManager.toCreditMall();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .backgroundColor(ThemeManager.BG_CARD)
  }

  @Builder
  ActionItem(label: string, color: string, icon: Resource, action: () => void) {
    Column() {
      SymbolGlyph(icon)
        .fontSize(28)
        .fontColor([color])
      Text(label)
        .fontSize(12)
        .fontColor(ThemeManager.TEXT_SECONDARY)
        .margin({ top: 8 })
    }
    .onClick(() => action())
  }
}