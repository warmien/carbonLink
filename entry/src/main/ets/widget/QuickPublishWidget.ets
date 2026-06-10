@Entry
@Component
struct QuickPublishWidget {
  build() {
    Column() {
      Text('📦')
        .fontSize(24)
      Text('一键发布')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8 })
      Text('闲置商品')
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}