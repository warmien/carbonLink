@Entry
@Component
struct CreditOverviewWidget {
  @LocalStorageProp('balance') balance: string = '0';
  @LocalStorageProp('level') level: string = '环保新手';
  @LocalStorageProp('totalEarned') totalEarned: string = '0';

  build() {
    Column() {
      Row() {
        Text('🌿 碳积分')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Blank()
        Text(this.level)
          .fontSize(10)
          .fontColor('#00B96B')
          .backgroundColor('#E8F8F0')
          .borderRadius(8)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      }
      .width('100%')

      Text(this.balance)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#00B96B')
        .margin({ top: 8 })

      Text('累计获得 ' + this.totalEarned)
        .fontSize(10)
        .fontColor($r('app.color.text_hint'))
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }
}