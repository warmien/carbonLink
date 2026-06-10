import { Product } from '../models/Product';
import { productRepository } from '../repository/ProductRepository';
import { userRepository } from '../repository/UserRepository';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { ProductCard } from '../components/ProductCard';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct MyProductsPage {
  @State products: Product[] = [];
  @State btnScale: number = 1;

  aboutToAppear(): void {
    this.products = productRepository.getProductsBySeller('u000');
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor(ThemeManager.TEXT_PRIMARY)
          .onClick(() => RouterManager.back())
        Text('我的发布')
          .fontSize(AppConstants.FONT_XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
          .margin({ left: AppConstants.SPACING_SM })
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_LG, bottom: AppConstants.SPACING_SM })

      if (this.products.length === 0) {
        EmptyState({ message: '还没有发布任何商品', actionText: '去发布', onAction: () => RouterManager.back() })
      } else {
        Scroll() {
          Grid() {
            ForEach(this.products, (product: Product) => {
              GridItem() {
                ProductCard({
                  product: product,
                  onCardClick: () => RouterManager.toProductDetail(product.id)
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(AppConstants.SPACING_SM)
          .rowsGap(AppConstants.SPACING_SM)
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
