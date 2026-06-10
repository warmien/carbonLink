import { DeviceAdapterManager } from './DeviceAdapterManager';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';

@Component
export struct PCLayout {
  @Prop currentTab: number = 0;
  @BuilderParam contentArea: () => void = () => {};
  private onTabChange: (tab: number) => void = () => {};

  private readonly navItems: string[] = ['首页', '分类', '发布', '消息', '我的'];

  build() {
    Row() {
      Column() {
        Text('🌿 碳易链')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.COLOR_PRIMARY)
          .margin({ top: 24, bottom: 32 })

        ForEach(this.navItems, (item: string, index: number) => {
          Text(item)
            .fontSize(14)
            .fontColor(this.currentTab === index ? ThemeManager.COLOR_PRIMARY : $r('app.color.text_secondary'))
            .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
            .width('100%')
            .padding({ left: 20, top: 10, bottom: 10 })
            .backgroundColor(this.currentTab === index ? '#E8F8F0' : Color.Transparent)
            .borderRadius(8)
            .onClick(() => this.onTabChange(index))
        })
      }
      .width(240)
      .height('100%')
      .padding({ left: 12, right: 12 })
      .backgroundColor($r('app.color.bg_card'))
      .alignItems(HorizontalAlign.Start)

      Column() {
        this.contentArea()
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}