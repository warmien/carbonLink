import { Order, OrderStatus } from '../models/Order';
import { orderRepository } from '../repository/OrderRepository';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { DateUtils } from '../utils/DateUtils';
import { EmptyState } from '../components/EmptyState';
import { CreditEngine } from '../engine/CreditEngine';
import { AchievementDetector } from '../engine/AchievementDetector';
import { promptAction } from '@kit.ArkUI';

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
      case OrderStatus.PENDING_PAYMENT: return ThemeManager.COLOR_STATUS_PENDING;
      case OrderStatus.PENDING_SHIPMENT:
      case OrderStatus.SHIPPED: return ThemeManager.COLOR_STATUS_PROCESSING;
      case OrderStatus.COMPLETED: return ThemeManager.COLOR_STATUS_COMPLETED;
      case OrderStatus.CANCELLED: return ThemeManager.COLOR_STATUS_CANCELLED;
      default: return ThemeManager.TEXT_HINT;
    }
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor(ThemeManager.TEXT_PRIMARY)
          .onClick(() => RouterManager.back())
        Text('我的订单')
          .fontSize(AppConstants.FONT_XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .margin({ left: AppConstants.SPACING_SM })
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_LG, bottom: AppConstants.SPACING_SM })

      // Tab 切换
      Tabs({ index: this.currentTab, controller: this.tabsController }) {
        ForEach(this.orderTabs, (tab: string) => {
          TabContent() {
            if (this.orders.length === 0) {
              EmptyState({ message: `暂无${tab}订单` })
            } else {
              List({ space: AppConstants.SPACING_SM }) {
                ForEach(this.orders, (order: Order) => {
                  ListItem() {
                    Column({ space: AppConstants.SPACING_SM }) {
                      // 订单状态
                      Row() {
                        Text(order.sellerName)
                          .fontSize(AppConstants.FONT_SM)
                          .fontColor(ThemeManager.TEXT_SECONDARY)
                        Blank()
                        Text(Order.getStatusLabel(order.status))
                          .fontSize(AppConstants.FONT_SM)
                          .fontColor(this.getStatusColor(order.status))
                          .fontWeight(FontWeight.Medium)
                      }
                      .width('100%')

                      // 商品信息
                      Row({ space: AppConstants.SPACING_MD }) {
                        Image(order.productImage !== '' ? order.productImage : $r('app.media.startIcon'))
                          .width(80)
                          .height(80)
                          .borderRadius(AppConstants.RADIUS_MD)
                          .objectFit(ImageFit.Cover)

                        Column({ space: 4 }) {
                          Text(order.productTitle)
                            .fontSize(AppConstants.FONT_MD)
                            .fontColor(ThemeManager.TEXT_PRIMARY)
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                          Text(`¥${order.price}`)
                            .fontSize(AppConstants.FONT_LG)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(ThemeManager.COLOR_PRICE)
                          Text(DateUtils.formatDateTime(order.createdAt))
                            .fontSize(AppConstants.FONT_XS)
                            .fontColor(ThemeManager.TEXT_HINT)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                      }
                      .width('100%')

                      // 操作按钮
                      if (order.status === OrderStatus.PENDING_PAYMENT) {
                        Row() {
                          Blank()
                          Button('取消订单')
                            .fontSize(AppConstants.FONT_XS)
                            .backgroundColor(ThemeManager.BG_PRIMARY)
                            .fontColor(ThemeManager.TEXT_SECONDARY)
                            .borderRadius(16)
                            .height(30)
                            .onClick(() => {
                              orderRepository.updateOrderStatus(order.id, OrderStatus.CANCELLED);
                              this.refreshOrders();
                              promptAction.showToast({ message: '订单已取消' });
                            })
                          Button('立即付款')
                            .fontSize(AppConstants.FONT_XS)
                            .backgroundColor(ThemeManager.COLOR_PRIMARY)
                            .fontColor(Color.White)
                            .borderRadius(16)
                            .height(30)
                            .margin({ left: AppConstants.SPACING_SM })
                            .onClick(() => {
                              orderRepository.updateOrderStatus(order.id, OrderStatus.PENDING_SHIPMENT);
                              this.refreshOrders();
                              promptAction.showToast({ message: '付款成功' });
                            })
                        }
                        .width('100%')
                      } else if (order.status === OrderStatus.SHIPPED) {
                        Row() {
                          Blank()
                          Button('确认收货')
                            .fontSize(AppConstants.FONT_XS)
                            .backgroundColor(ThemeManager.COLOR_PRIMARY)
                            .fontColor(Color.White)
                            .borderRadius(16)
                            .height(30)
                            .onClick(() => {
                               orderRepository.updateOrderStatus(order.id, OrderStatus.COMPLETED);
                                CreditEngine.onTradeCompleted(order.id, 'user_1', order.sellerId, 0, 0);
                               AchievementDetector.detect('user_1', 'trade');
                               AchievementDetector.detect(order.sellerId, 'trade');
                               this.refreshOrders();
                               promptAction.showToast({ message: '已确认收货，积分已到账' });
                             })
                        }
                        .width('100%')
                      } else if (order.status === OrderStatus.COMPLETED) {
                        Row() {
                          Blank()
                          Button('再次购买')
                            .fontSize(AppConstants.FONT_XS)
                            .backgroundColor(ThemeManager.BG_PRIMARY)
                            .fontColor(ThemeManager.TEXT_SECONDARY)
                            .borderRadius(16)
                            .height(30)
                            .onClick(() => {
                              RouterManager.toProductDetail(order.productId);
                            })
                          Button('评价')
                            .fontSize(AppConstants.FONT_XS)
                            .backgroundColor(ThemeManager.COLOR_PRIMARY)
                            .fontColor(Color.White)
                            .borderRadius(16)
                            .height(30)
                            .margin({ left: AppConstants.SPACING_SM })
                            .onClick(() => {
                              promptAction.showToast({ message: '评价功能暂未实现' });
                            })
                        }
                        .width('100%')
                      }
                    }
                    .width('100%')
                    .backgroundColor(ThemeManager.BG_CARD)
                    .borderRadius(AppConstants.RADIUS_MD)
                    .padding(AppConstants.SPACING_MD)
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
              .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_SM, bottom: 80 })
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
      .onChange((index: number) => {
        this.filterOrders(index);
      })
      .scrollable(false)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }
}
