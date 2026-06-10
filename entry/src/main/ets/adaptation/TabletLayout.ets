import { DeviceAdapterManager } from './DeviceAdapterManager';

@Component
export struct TabletLayout {
  @Prop currentTab: number = 0;
  @BuilderParam phoneContent: () => void = () => {};

  build() {
    Row() {
      Column() {
        this.phoneContent()
      }
      .layoutWeight(1)

      Column() {
        Text('商品详情')
          .fontSize(16)
          .fontColor($r('app.color.text_hint'))
        Text('请选择一个商品查看详情')
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
          .margin({ top: 8 })
      }
      .width(360)
      .height('100%')
      .backgroundColor($r('app.color.bg_card'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}