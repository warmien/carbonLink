@Entry
@Component
struct ProductRecommendWidget {
  @LocalStorageProp('product_0_title') title0: string = '';
  @LocalStorageProp('product_0_price') price0: string = '0';
  @LocalStorageProp('product_1_title') title1: string = '';
  @LocalStorageProp('product_1_price') price1: string = '0';
  @LocalStorageProp('count') count: string = '0';

  build() {
    Column() {
      Text('商品推荐')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 8 })

      if (this.count > '0') {
        Row() {
          Text(this.title0)
            .fontSize(11)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .layoutWeight(1)
          Text('¥' + this.price0)
            .fontSize(11)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
      }

      if (this.count > '1') {
        Row() {
          Text(this.title1)
            .fontSize(11)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .layoutWeight(1)
          Text('¥' + this.price1)
            .fontSize(11)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .margin({ top: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
  }
}