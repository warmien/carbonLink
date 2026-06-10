import { DeviceAdapterManager } from './DeviceAdapterManager';
import { DeviceType } from '../models/DeviceInfo';

@Component
export struct WatchLayout {
  @Prop currentTab: number = 0;
  private onTabChange: (tab: number) => void = () => {};

  build() {
    Column() {
      Text('碳易链')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 8, bottom: 8 })

      Tabs({ index: this.currentTab }) {
        TabContent() {
          Text('商品浏览')
            .fontSize(12)
        }
        .tabBar('商品')

        TabContent() {
          Text('积分查看')
            .fontSize(12)
        }
        .tabBar('积分')
      }
      .layoutWeight(1)
      .onChange((index: number) => {
        this.onTabChange(index);
      })
    }
    .width('100%')
    .height('100%')
  }
}