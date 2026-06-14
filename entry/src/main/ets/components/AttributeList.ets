import { ProductAttribute } from '../models/Spec';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';

@Component
export struct AttributeList {
  @Prop attributes: ProductAttribute[] = [];

  build() {
    Column() {
      if (this.attributes.length > 0) {
        Text('商品参数')
          .fontSize(AppConstants.FONT_MD)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .width('100%')
          .margin({ bottom: 8 })

        ForEach(this.attributes, (attr: ProductAttribute, index: number) => {
          Row() {
            Text(attr.attributeName)
              .fontSize(AppConstants.FONT_SM)
              .fontColor(ThemeManager.TEXT_HINT)
              .width(80)
              .textAlign(TextAlign.Start)

            Text(attr.attributeValue)
              .fontSize(AppConstants.FONT_SM)
              .fontColor(ThemeManager.TEXT_PRIMARY)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .borderWidth({ bottom: index < this.attributes.length - 1 ? 0.5 : 0 })
          .borderColor(ThemeManager.DIVIDER)
        }, (attr: ProductAttribute, index: number) => `${attr.attributeNameId}_${index}`)
      }
    }
    .width('100%')
  }
}