import { Order, OrderStatus } from '../models/Order';
import { orderRepository } from '../repository/OrderRepository';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { DateUtils } from '../utils/DateUtils';
import { EmptyState } from '../components/EmptyState';
import { CreditEngine } from '../engine/CreditEngine';
import { AchievementDetector } from '../engine/AchievementDetector';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct OrderCenterPage {
  @State currentTab: number = 0;
  @State orders: Order[] = [];
  @State pressedOrderId: string = '';
  private tabsController: TabsController = new TabsController();
  private allOrders: Order[] = [];

  readonly orderTabs: string[] = ['全部', '待付款', '待发货', '待收货', '已完成', '已取消'];

  aboutToAppear(): void {
    const params = router.getParams();
    if (params !== null && params !== undefined) {
      const tabVal: number = params.tabIndex as number;
      if (tabVal !== undefined && tabVal !== null) {
        this.currentTab = tabVal;
      }
    }
    this.refreshOrders();
  }

  refreshOrders(): void {
    this.allOrders = orderRepository.getOrders();
    this.filterOrders(this.currentTab);
  }

  filterOrders(index: number): void {
    this.currentTab = index;
    switch (index) {
      case 0: this.orders = this.allOrders; break;
      case 1: this.orders = this.allOrders.filter(o => o.status === OrderStatus.PENDING_PAYMENT); break;
      case 2: this.orders = this.allOrders.filter(o => o.status === OrderStatus.PENDING_SHIPMENT); break;
      case 3: this.orders = this.allOrders.filter(o => o.status === OrderStatus.SHIPPED); break;
      case 4: this.orders = this.allOrders.filter(o => o.status === OrderStatus.COMPLETED); break;
      case 5: this.orders = this.allOrders.filter(o => o.status === OrderStatus.CANCELLED); break;
    }
  }

  getStatusColor(status: OrderStatus): string | ResourceColor {
    switch (status) {
      case OrderStatus.PENDING_PAYMENT: return ThemeManager.COLOR_STATUS_UNPAID;
      case OrderStatus.PENDING_SHIPMENT: return ThemeManager.COLOR_STATUS_UNSHIPPED;
      case OrderStatus.SHIPPED: return ThemeManager.COLOR_STATUS_SHIPPED;
      case OrderStatus.COMPLETED: return ThemeManager.COLOR_STATUS_COMPLETED;
      case OrderStatus.CANCELLED: return ThemeManager.COLOR_STATUS_CANCELLED;
      default: return ThemeManager.TEXT_HINT;
    }
  }


  getStatusBgColor(status: OrderStatus): string {
    switch (status) {
      case OrderStatus.PENDING_PAYMENT: return '#FFF7E6';
      case OrderStatus.PENDING_SHIPMENT: return '#E6F7FF';
      case OrderStatus.SHIPPED: return '#E6FFFB';
      case OrderStatus.COMPLETED: return '#F6FFED';
      case OrderStatus.CANCELLED: return '#F5F5F5';
      default: return '#F5F5F5';
    }
  }

  @Builder
  StatusIcon(status: OrderStatus) {
    if (status === OrderStatus.PENDING_PAYMENT) {
      Shape() {
        Path().commands('M7 4L17 4A3 3 0 0 1 20 7L20 17A3 3 0 0 1 17 20L7 20A3 3 0 0 1 4 17L4 7A3 3 0 0 1 7 4Z')
          .stroke('#FAAD14').strokeWidth(1.5).fill(Color.Transparent)
        Path().commands('M4 9L20 9M12 4L12 9')
          .stroke('#FAAD14').strokeWidth(1.5).fill(Color.Transparent)
      }.width(20).height(20).viewPort({ x: 0, y: 0, width: 24, height: 24 })
    } else if (status === OrderStatus.PENDING_SHIPMENT) {
      Shape() {
        Path().commands('M5 7L19 7A2 2 0 0 1 21 9L21 19A2 2 0 0 1 19 21L5 21A2 2 0 0 1 3 19L3 9A2 2 0 0 1 5 7Z')
          .stroke('#1890FF').strokeWidth(1.5).fill(Color.Transparent)
        Path().commands('M9 7L9 5A3 3 0 0 1 15 5L15 7')
          .stroke('#1890FF').strokeWidth(1.5).fill(Color.Transparent)
      }.width(20).height(20).viewPort({ x: 0, y: 0, width: 24, height: 24 })
    } else if (status === OrderStatus.SHIPPED) {
      Shape() {
        Path().commands('M1 3L15 3L15 16L1 16Z')
          .stroke('#13C2C2').strokeWidth(1.5).fill(Color.Transparent)
        Path().commands('M15 8L21 8L23 13L23 18L15 18Z')
          .stroke('#13C2C2').strokeWidth(1.5).fill(Color.Transparent)
      }.width(20).height(20).viewPort({ x: 0, y: 0, width: 24, height: 24 })
    } else if (status === OrderStatus.COMPLETED) {
      Shape() {
        Path().commands('M12 2A10 10 0 1 0 12 2Z')
          .stroke('#52C41A').strokeWidth(1.5).fill(Color.Transparent)
        Path().commands('M8 12L11 15L16 9')
          .stroke('#52C41A').strokeWidth(1.5).fill(Color.Transparent)
      }.width(20).height(20).viewPort({ x: 0, y: 0, width: 24, height: 24 })
    } else if (status === OrderStatus.CANCELLED) {
      Shape() {
        Path().commands('M12 2A10 10 0 1 0 12 2Z')
          .stroke('#999999').strokeWidth(1.5).fill(Color.Transparent)
        Path().commands('M8 8L16 16M16 8L8 16')
          .stroke('#999999').strokeWidth(1.5).fill(Color.Transparent)
      }.width(20).height(20).viewPort({ x: 0, y: 0, width: 24, height: 24 })
    } else {
      Shape() {
        Path().commands('M12 2A10 10 0 1 0 12 2Z')
          .stroke('#999999').strokeWidth(1.5).fill(Color.Transparent)
      }.width(20).height(20).viewPort({ x: 0, y: 0, width: 24, height: 24 })
    }
  }

  build() {
    Column() {
      Column().height(48).width('100%')

      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => RouterManager.back())
          .scale({ x: 1, y: 1 })
          .animation({ duration: 100, curve: Curve.EaseOut })

        Text('我的订单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: 24 })

        Text('')
          .width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .margin({ top: AppConstants.STATUS_BAR_HEIGHT })

      Tabs({ index: this.currentTab, controller: this.tabsController }) {
        ForEach(this.orderTabs, (tab: string) => {
          TabContent() {
            if (this.orders.length === 0) {
              EmptyState({ message: `暂无${tab}订单` })
            } else {
              List({ space: 12 }) {
                ForEach(this.orders, (order: Order) => {
                  ListItem() {
                    Column() {
                      Row() {
                        Stack() {
                          Column()
                            .width(32)
                            .height(32)
                            .borderRadius(16)
                            .backgroundColor(this.getStatusBgColor(order.status))
                          this.StatusIcon(order.status)
                        }
                        .margin({ right: 8 })

                        Text(order.sellerName)
                          .fontSize(14)
                          .fontColor(ThemeManager.TEXT_SECONDARY)
                          .layoutWeight(1)

                        Text(Order.getStatusLabel(order.status))
                          .fontSize(13)
                          .fontColor(this.getStatusColor(order.status))
                          .fontWeight(FontWeight.Medium)
                      }
                      .width('100%')
                      .height(44)
                      .padding({ left: 16, right: 16 })
                      .alignItems(VerticalAlign.Center)

                      Row()
                        .width('100%')
                        .height(0.5)
                        .backgroundColor('#F0F0F0')
                        .margin({ left: 16 })

                      Row({ space: 12 }) {
                        Image(order.productImage !== '' ? order.productImage : $r('app.media.startIcon'))
                          .width(80)
                          .height(80)
                          .borderRadius(ThemeManager.RADIUS_SM)
                          .objectFit(ImageFit.Cover)

                        Column({ space: 6 }) {
                          Text(order.productTitle)
                            .fontSize(15)
                            .fontColor(ThemeManager.TEXT_PRIMARY)
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })

                          Row() {
                            Text('¥')
                              .fontSize(12)
                              .fontColor(ThemeManager.COLOR_PRICE)
                            Text(order.price.toString())
                              .fontSize(18)
                              .fontWeight(FontWeight.Bold)
                              .fontColor(ThemeManager.COLOR_PRICE)
                          }

                          Text(DateUtils.formatDateTime(order.createdAt))
                            .fontSize(12)
                            .fontColor(ThemeManager.TEXT_HINT)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                      }
                      .width('100%')
                      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

                      if (order.status === OrderStatus.PENDING_PAYMENT ||
                          order.status === OrderStatus.SHIPPED ||
                          order.status === OrderStatus.COMPLETED) {
                        Row()
                          .width('100%')
                          .height(0.5)
                          .backgroundColor('#F0F0F0')
                          .margin({ left: 16 })
                      }

                      if (order.status === OrderStatus.PENDING_PAYMENT) {
                        Row() {
                          Blank()
                          Button('取消订单')
                            .fontSize(13)
                            .backgroundColor(Color.Transparent)
                            .fontColor(ThemeManager.TEXT_SECONDARY)
                            .borderRadius(ThemeManager.RADIUS_LG)
                            .border({ width: 0.5, color: '#E0E0E0' })
                            .height(32)
                            .type(ButtonType.Normal)
                            .onClick(() => {
                              orderRepository.updateOrderStatus(order.id, OrderStatus.CANCELLED);
                              this.refreshOrders();
                              promptAction.showToast({ message: '订单已取消' });
                            })
                          Button('立即付款')
                            .fontSize(13)
                            .backgroundColor(ThemeManager.COLOR_PRIMARY)
                            .fontColor(Color.White)
                            .borderRadius(ThemeManager.RADIUS_LG)
                            .height(32)
                            .type(ButtonType.Normal)
                            .margin({ left: 8 })
                            .onClick(() => {
                              orderRepository.updateOrderStatus(order.id, OrderStatus.PENDING_SHIPMENT);
                              this.refreshOrders();
                              promptAction.showToast({ message: '付款成功' });
                            })
                        }
                        .width('100%')
                        .height(52)
                        .padding({ left: 16, right: 16 })
                        .alignItems(VerticalAlign.Center)
                      } else if (order.status === OrderStatus.SHIPPED) {
                        Row() {
                          Blank()
                          Button('确认收货')
                            .fontSize(13)
                            .backgroundColor(ThemeManager.COLOR_PRIMARY)
                            .fontColor(Color.White)
                            .borderRadius(ThemeManager.RADIUS_LG)
                            .height(32)
                            .type(ButtonType.Normal)
                            .onClick(() => {
                              orderRepository.updateOrderStatus(order.id, OrderStatus.COMPLETED);
                              CreditEngine.onTradeCompleted(order.id, 'user_1', order.sellerId, order.carbonCredits || 0, order.carbonReduction || 0);
                              AchievementDetector.detect('user_1', 'trade');
                              AchievementDetector.detect(order.sellerId, 'trade');
                              this.refreshOrders();
                              promptAction.showToast({ message: '已确认收货，积分已到账' });
                            })
                        }
                        .width('100%')
                        .height(52)
                        .padding({ left: 16, right: 16 })
                        .alignItems(VerticalAlign.Center)
                      } else if (order.status === OrderStatus.COMPLETED) {
                        Row() {
                          Blank()
                          Button('再次购买')
                            .fontSize(13)
                            .backgroundColor(Color.Transparent)
                            .fontColor(ThemeManager.TEXT_SECONDARY)
                            .borderRadius(ThemeManager.RADIUS_LG)
                            .border({ width: 0.5, color: '#E0E0E0' })
                            .height(32)
                            .type(ButtonType.Normal)
                            .onClick(() => {
                              RouterManager.toProductDetail(order.productId);
                            })
                          Button('评价')
                            .fontSize(13)
                            .backgroundColor(ThemeManager.COLOR_PRIMARY)
                            .fontColor(Color.White)
                            .borderRadius(ThemeManager.RADIUS_LG)
                            .height(32)
                            .type(ButtonType.Normal)
                            .margin({ left: 8 })
                            .onClick(() => {
                              promptAction.showToast({ message: '评价功能暂未实现' });
                            })
                        }
                        .width('100%')
                        .height(52)
                        .padding({ left: 16, right: 16 })
                        .alignItems(VerticalAlign.Center)
                      }
                    }
                    .width('100%')
                    .backgroundColor(Color.White)
                    .borderRadius(ThemeManager.RADIUS_MD)
                    .clip(true)
                    .scale({ x: this.pressedOrderId === order.id ? 0.97 : 1, y: this.pressedOrderId === order.id ? 0.97 : 1 })
                    .animation({ duration: 150, curve: Curve.EaseOut })
                    .onTouch((event: TouchEvent) => {
                      if (event.type === TouchType.Down) {
                        this.pressedOrderId = order.id;
                      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                        this.pressedOrderId = '';
                      }
                    })
                  }
                })
              }
              .width('100%')
              .height('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 80 })
              .divider({ strokeWidth: 0 })
            }
          }
          .tabBar(tab)
        })
      }
      .barMode(BarMode.Scrollable)
      .barWidth('100%')
      .barHeight(44)
      .layoutWeight(1)
      .animationDuration(300)
      .onChange((index: number) => {
        this.filterOrders(index);
      })
      .scrollable(false)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }
}
