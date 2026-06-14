import { CategorySpecTree, SpecValue } from '../models/Spec';
import { SKU, SpecValueItem } from '../models/SKU';
import { ThemeManager } from '../theme/ThemeManager';
import { AppConstants } from '../constants/AppConstants';

@Component
export struct SpecSelector {
  @Prop specTree: CategorySpecTree[] = [];
  @Prop skus: SKU[] = [];
  @Link selectedSpecNameIds: number[];
  @Link selectedSpecValueIds: number[];
  @Link selectedSku: SKU | null;
  @Prop isVisible: boolean = false;
  onClose?: () => void;

  build() {
    if (this.isVisible) {
      Column() {
        Row() {
          Text('选择规格')
            .fontSize(AppConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.TEXT_PRIMARY)
          Blank()
          Image($r('sys.symbol.xmark'))
            .width(24)
            .height(24)
            .fillColor(ThemeManager.TEXT_HINT)
            .onClick(() => {
              if (this.onClose) {
                this.onClose();
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        Scroll() {
          Column() {
            ForEach(this.specTree, (spec: CategorySpecTree) => {
              Column() {
                Text(spec.specName)
                  .fontSize(AppConstants.FONT_MD)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                  .width('100%')
                  .margin({ bottom: 8 })

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(spec.values, (sv: SpecValue) => {
                    Text(sv.value)
                      .fontSize(AppConstants.FONT_SM)
                      .fontColor(this.isSelected(spec.specNameId, sv.id) ? Color.White : ThemeManager.TEXT_PRIMARY)
                      .backgroundColor(this.isSelected(spec.specNameId, sv.id) ? ThemeManager.COLOR_PRIMARY : ThemeManager.BG_PRIMARY)
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .borderRadius(AppConstants.RADIUS_SM)
                      .margin({ right: 8, bottom: 8 })
                      .onClick(() => {
                        this.selectSpec(spec.specNameId, sv.id);
                      })
                  }, (sv: SpecValue) => sv.id.toString())
                }
                .width('100%')
              }
              .width('100%')
              .margin({ bottom: 16 })
            }, (spec: CategorySpecTree) => spec.specNameId.toString())
          }
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        if (this.selectedSku !== null) {
          Row() {
            Text(`¥${this.selectedSku.price}`)
              .fontSize(AppConstants.FONT_XL)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeManager.COLOR_PRICE)
            Blank()
            Text(`库存: ${this.selectedSku.availableStock}`)
              .fontSize(AppConstants.FONT_SM)
              .fontColor(ThemeManager.TEXT_HINT)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
      }
      .width('100%')
      .height('60%')
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: AppConstants.RADIUS_LG, topRight: AppConstants.RADIUS_LG })
      .padding({ bottom: 34 })
      .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
    }
  }

  private isSelected(specNameId: number, specValueId: number): boolean {
    for (let i = 0; i < this.selectedSpecNameIds.length; i++) {
      if (this.selectedSpecNameIds[i] === specNameId && this.selectedSpecValueIds[i] === specValueId) {
        return true;
      }
    }
    return false;
  }

  private selectSpec(specNameId: number, specValueId: number): void {
    const newIds: number[] = [];
    const newValues: number[] = [];
    let found: boolean = false;
    for (let i = 0; i < this.selectedSpecNameIds.length; i++) {
      if (this.selectedSpecNameIds[i] === specNameId) {
        newIds.push(specNameId);
        newValues.push(specValueId);
        found = true;
      } else {
        newIds.push(this.selectedSpecNameIds[i]);
        newValues.push(this.selectedSpecValueIds[i]);
      }
    }
    if (!found) {
      newIds.push(specNameId);
      newValues.push(specValueId);
    }
    this.selectedSpecNameIds = newIds;
    this.selectedSpecValueIds = newValues;
    this.matchSKU();
  }

  private matchSKU(): void {
    if (this.specTree.length === 0 || this.skus.length === 0) {
      this.selectedSku = null;
      return;
    }

    if (this.selectedSpecNameIds.length < this.specTree.length) {
      this.selectedSku = null;
      return;
    }

    for (let i = 0; i < this.skus.length; i++) {
      const sku: SKU = this.skus[i];
      if (sku.specValues.length === 0) continue;

      let allMatch: boolean = true;
      for (let j = 0; j < this.selectedSpecNameIds.length; j++) {
        const specNameId: number = this.selectedSpecNameIds[j];
        const selectedValueId: number = this.selectedSpecValueIds[j];
        let found: boolean = false;
        for (let k = 0; k < sku.specValues.length; k++) {
          if (sku.specValues[k].specNameId === specNameId && sku.specValues[k].specValueId === selectedValueId) {
            found = true;
            break;
          }
        }
        if (!found) {
          allMatch = false;
          break;
        }
      }

      if (allMatch) {
        this.selectedSku = sku;
        return;
      }
    }
    this.selectedSku = null;
  }
}
