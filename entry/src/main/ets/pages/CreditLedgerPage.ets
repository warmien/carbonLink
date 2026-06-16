import { CreditTransaction, CreditTransactionType } from '../models/CreditTransaction';
import { creditTransactionRepository } from '../repository/CreditTransactionRepository';
import { ThemeManager } from '../theme/ThemeManager';
import { DateUtils } from '../utils/DateUtils';
import { AppConstants } from '../constants/AppConstants';

@Entry
@Component
struct CreditLedgerPage {
  @State transactions: CreditTransaction[] = [];
  @State currentFilter: string = 'all';
  @State currentPage: number = 1;
  @State hasMore: boolean = true;
  @State btnScale: number = 1;
  private userId: string = 'user_1';
  private pageSize: number = 20;

  aboutToAppear(): void {
    this.loadTransactions();
  }

  loadTransactions(): void {
    this.currentPage = 1;
    this.transactions = creditTransactionRepository.getByUserId(this.userId, 1, this.pageSize, this.currentFilter);
    this.hasMore = this.transactions.length >= this.pageSize;
  }

  loadMore(): void {
    if (!this.hasMore) return;
    this.currentPage++;
    const more = creditTransactionRepository.getByUserId(this.userId, this.currentPage, this.pageSize, this.currentFilter);
    if (more.length > 0) {
      this.transactions = this.transactions.concat(more);
    }
    this.hasMore = more.length >= this.pageSize;
  }

  getTypeLabel(type: CreditTransactionType): string {
    if (type === CreditTransactionType.TRADE_REWARD) return '交易奖励';
    if (type === CreditTransactionType.PUBLISH_REWARD) return '发布奖励';
    if (type === CreditTransactionType.ACHIEVEMENT_REWARD) return '成就奖励';
    if (type === CreditTransactionType.EXCHANGE_DEDUCT) return '积分兑换';
    if (type === CreditTransactionType.EXPIRE_CLEAR) return '积分过期';
    if (type === CreditTransactionType.DONATION_REWARD) return '捐赠奖励';
    if (type === CreditTransactionType.REFORM_REWARD) return '改造奖励';
    if (type === CreditTransactionType.TRANSFER_OUT) return '积分转出';
    if (type === CreditTransactionType.TRANSFER_IN) return '积分转入';
    if (type === CreditTransactionType.TRANSFER_FEE) return '转让手续费';
    if (type === CreditTransactionType.VIOLATION_DEDUCT) return '违规扣除';
    return '未知';
  }

  isIncome(type: CreditTransactionType): boolean {
    return type === CreditTransactionType.TRADE_REWARD ||
      type === CreditTransactionType.PUBLISH_REWARD ||
      type === CreditTransactionType.ACHIEVEMENT_REWARD ||
      type === CreditTransactionType.DONATION_REWARD ||
      type === CreditTransactionType.REFORM_REWARD ||
      type === CreditTransactionType.TRANSFER_IN;
  }

  build() {
    Column() {
      Row() {
        Text('积分流水')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
      .margin({ top: AppConstants.STATUS_BAR_HEIGHT })

      Row({ space: 8 }) {
        ForEach(['all', 'income', 'expense'], (filter: string) => {
          Text(filter === 'all' ? '全部' : filter === 'income' ? '收入' : '支出')
            .fontSize(14)
            .fontColor(this.currentFilter === filter ? '#FFFFFF' : ThemeManager.TEXT_SECONDARY)
            .backgroundColor(this.currentFilter === filter ? ThemeManager.COLOR_PRIMARY : '#F5F5F5')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .onClick(() => {
              this.currentFilter = filter;
              this.loadTransactions();
            })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      if (this.transactions.length === 0) {
        Column() {
          Text('暂无积分记录')
            .fontSize(14)
            .fontColor(ThemeManager.TEXT_HINT)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.transactions, (tx: CreditTransaction) => {
            ListItem() {
              this.TransactionItem(tx)
            }
            .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
          })
          ListItem() {
            if (this.hasMore) {
              Text('加载更多')
                .fontSize(13)
                .fontColor(ThemeManager.TEXT_HINT)
                .textAlign(TextAlign.Center)
                .width('100%')
                .padding(12)
                .onClick(() => this.loadMore())
            }
          }
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .divider({ strokeWidth: 0.5, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }

  @Builder
  TransactionItem(tx: CreditTransaction) {
    Row() {
      Column() {
        Text(this.getTypeLabel(tx.type))
          .fontSize(14)
          .fontColor(ThemeManager.TEXT_PRIMARY)
        Text(DateUtils.formatTimeAgo(tx.timestamp))
          .fontSize(11)
          .fontColor(ThemeManager.TEXT_HINT)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text((this.isIncome(tx.type) ? '+' : '-') + tx.amount)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isIncome(tx.type) ? ThemeManager.COLOR_PRIMARY : ThemeManager.COLOR_PRICE)
        Text('余额 ' + tx.balanceAfter)
          .fontSize(11)
          .fontColor(ThemeManager.TEXT_HINT)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}