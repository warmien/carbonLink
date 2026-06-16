import { SPU } from '../models/SPU';
import { HttpService } from '../services/HttpService';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { EmptyState } from '../components/EmptyState';

class BrowseHistoryItem {
  targetId: string = '';
  targetCategory: string = '';
  timestamp: number = 0;
  title: string = '';
  images: string[] = [];
  minPrice: number = 0;
}

@Entry
@Component
struct BrowseHistoryPage {
  @State items: BrowseHistoryItem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadBrowseHistory();
  }

  private async loadBrowseHistory(): Promise<void> {
    this.isLoading = true;
    try {
      const resp = await HttpService.GET('/browse-history?page=1&pageSize=50');
      if (resp.code === 0 && resp.data !== null) {
        const dataObj: Record<string, string | number | object> = resp.data;
        const listData = dataObj['list'];
        if (listData !== null && listData !== undefined && typeof listData !== 'string' && typeof listData !== 'number' && typeof listData !== 'boolean') {
          const arr: Record<string, string | number | object>[] = listData as Record<string, string | number | object>[];
          this.items = [];
          for (let i = 0; i < arr.length; i++) {
            const item = new BrowseHistoryItem();
            item.targetId = arr[i]['targetId'] as string;
            item.targetCategory = arr[i]['targetCategory'] as string;
            const tsVal = arr[i]['timestamp'];
            item.timestamp = typeof tsVal === 'number' ? tsVal : 0;
            item.title = arr[i]['title'] as string;
            item.minPrice = typeof arr[i]['minPrice'] === 'number' ? arr[i]['minPrice'] as number : 0;
            const imagesVal = arr[i]['images'];
            if (imagesVal !== null && imagesVal !== undefined && typeof imagesVal !== 'string' && typeof imagesVal !== 'number' && typeof imagesVal !== 'boolean') {
              const imgArr: (string | number | boolean | object)[] = imagesVal as (string | number | boolean | object)[];
              item.images = imgArr.map((v: string | number | boolean | object): string => String(v));
            }
            this.items.push(item);
          }
        }
      }
    } catch (err) {
      this.items = [];
    }
    this.isLoading = false;
  }

  private getDisplayImage(images: string[]): string | Resource {
    for (let i = 0; i < images.length; i++) {
      if (images[i].length > 0 && !images[i].endsWith('.svg')) {
        return images[i];
      }
    }
    return $r('app.media.startIcon');
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor(ThemeManager.TEXT_PRIMARY)
          .onClick(() => RouterManager.back())
        Text('浏览记录')
          .fontSize(AppConstants.FONT_XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .margin({ left: AppConstants.SPACING_SM })
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.STATUS_BAR_HEIGHT, bottom: AppConstants.SPACING_SM })

      if (this.items.length === 0) {
        EmptyState({ message: '暂无浏览记录', actionText: '去逛逛', onAction: () => RouterManager.back() })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.items, (item: BrowseHistoryItem) => {
              Row({ space: 12 }) {
                Image(item.images.length > 0 ? this.getDisplayImage(item.images) : $r('app.media.startIcon'))
                  .width(80)
                  .height(80)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)

                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(14)
                    .fontColor(ThemeManager.TEXT_PRIMARY)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.targetCategory)
                    .fontSize(12)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                  Text('¥' + item.minPrice.toString())
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ThemeManager.COLOR_PRIMARY)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(ThemeManager.BG_CARD)
              .borderRadius(12)
              .onClick(() => RouterManager.toProductDetail(item.targetId))
            })
          }
          .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }
}