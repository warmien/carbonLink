import { SPU } from '../models/SPU';
import { productRepository } from '../repository/ProductRepository';
import { HttpService } from '../services/HttpService';
import { ObsService } from '../services/ObsService';
import { ImagePickerService } from '../services/ImagePickerService';
import { ImageDisplayUtil } from '../components/ImagePickerPanel';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { RouterManager } from '../router/RouterManager';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct EditProductPage {
  @State spu: SPU | null = null;
  @State title: string = '';
  @State description: string = '';
  @State price: string = '';
  @State originalPrice: string = '';
  @State selectedCondition: string = '';
  @State images: string[] = [];
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;
  @State showDeleteConfirm: boolean = false;

  private spuId: string = '';
  private originalImages: string[] = [];

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string | number | object>;
    if (params && params['spuId']) {
      this.spuId = params['spuId'] as string;
      this.loadProduct();
    }
  }

  private async loadProduct(): Promise<void> {
    this.isLoading = true;
    const result = await productRepository.getProductDetail(this.spuId);
    if (result !== null) {
      this.spu = result.spu;
      this.title = result.spu.title;
      this.description = result.spu.description;
      this.images = result.spu.images;
      this.originalImages = [];
      for (let i = 0; i < result.spu.images.length; i++) {
        this.originalImages.push(result.spu.images[i]);
      }
      if (result.skus.length > 0) {
        this.price = result.skus[0].price.toString();
        this.originalPrice = result.skus[0].originalPrice.toString();
        this.selectedCondition = result.skus[0].condition;
      }
    }
    this.isLoading = false;
  }

  private async handleSave(): Promise<void> {
    if (this.title.trim().length === 0) {
      promptAction.showToast({ message: '请输入商品标题' });
      return;
    }
    if (this.price.trim().length === 0) {
      promptAction.showToast({ message: '请输入商品价格' });
      return;
    }

    this.isSaving = true;
    try {
      let uploadedImages: string[] = [];
      const localUris: string[] = [];
      const remoteUrls: string[] = [];
      for (let i = 0; i < this.images.length; i++) {
        const url: string = this.images[i];
        if (url.startsWith('http://') || url.startsWith('https://')) {
          remoteUrls.push(url);
        } else {
          localUris.push(url);
        }
      }

      if (localUris.length > 0) {
        const newUrls: string[] = await ObsService.uploadImages(localUris);
        if (newUrls.length === 0 && localUris.length > 0) {
          promptAction.showToast({ message: '图片上传失败，请重试' });
          this.isSaving = false;
          return;
        }
        if (newUrls.length < localUris.length) {
          promptAction.showToast({ message: `已上传${newUrls.length}/${localUris.length}张图片` });
        }
        uploadedImages = remoteUrls.concat(newUrls);
      } else {
        uploadedImages = remoteUrls;
      }

      const removedUrls: string[] = [];
      for (let i = 0; i < this.originalImages.length; i++) {
        const origUrl: string = this.originalImages[i];
        let found: boolean = false;
        for (let j = 0; j < uploadedImages.length; j++) {
          if (uploadedImages[j] === origUrl) {
            found = true;
            break;
          }
        }
        if (!found) {
          removedUrls.push(origUrl);
        }
      }

      const updateBody: Record<string, string | number | object> = {};
      updateBody['title'] = this.title.trim();
      updateBody['description'] = this.description.trim();
      updateBody['images'] = uploadedImages as object;
      if (removedUrls.length > 0) {
        updateBody['removedImages'] = removedUrls as object;
      }

      const resp = await HttpService.PUT('/products/' + this.spuId, updateBody);
      if (resp.code === 0) {
        promptAction.showToast({ message: '保存成功' });
        RouterManager.back();
      } else {
        promptAction.showToast({ message: resp.message || '保存失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '保存失败，请重试' });
    }
    this.isSaving = false;
  }

  private async handleDelete(): Promise<void> {
    this.showDeleteConfirm = false;
    try {
      const resp = await HttpService.DELETE('/products/' + this.spuId);
      if (resp.code === 0) {

        promptAction.showToast({ message: '商品已删除' });
        RouterManager.back();
      } else {
        promptAction.showToast({ message: resp.message || '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  private async handlePickImages(): Promise<void> {
    const uris: string[] = await ImagePickerService.selectFromGallery(9);
    if (uris.length > 0) {
      this.images = uris;
    }
  }

  private removeImage(index: number): void {
    const newImages: string[] = [];
    for (let i = 0; i < this.images.length; i++) {
      if (i !== index) {
        newImages.push(this.images[i]);
      }
    }
    this.images = newImages;
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor(ThemeManager.TEXT_PRIMARY)
            .onClick(() => RouterManager.back())
          Text('编辑商品')
            .fontSize(AppConstants.FONT_XL)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeManager.TEXT_PRIMARY)
            .margin({ left: AppConstants.SPACING_SM })
          Blank()
          Text('删除')
            .fontSize(14)
            .fontColor('#FF4D4F')
            .onClick(() => {
              this.showDeleteConfirm = true;
            })
        }
        .width('100%')
        .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.STATUS_BAR_HEIGHT, bottom: AppConstants.SPACING_SM })

        if (this.isLoading) {
          Column() {
            LoadingProgress().width(40).height(40).color(ThemeManager.COLOR_PRIMARY)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 16 }) {
              Column({ space: 8 }) {
                Row() {
                  Text('商品图片')
                    .fontSize(14)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                    .layoutWeight(1)
                  Text('替换图片')
                    .fontSize(14)
                    .fontColor(ThemeManager.COLOR_PRIMARY)
                    .onClick(() => {
                      this.handlePickImages();
                    })
                }
                .width('100%')
                if (this.images.length > 0) {
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.images, (imgUrl: string, index: number) => {
                      Stack() {
                        Image(ImageDisplayUtil.getDisplaySrc(imgUrl))
                          .width(100)
                          .height(100)
                          .borderRadius(8)
                          .objectFit(ImageFit.Cover)
                        Image($r('sys.symbol.xmark_circle_fill'))
                          .width(24)
                          .height(24)
                          .fillColor(Color.White)
                          .position({ x: 76, y: 0 })
                          .onClick(() => {
                            this.removeImage(index);
                          })
                      }
                      .width(100)
                      .height(100)
                      .margin({ right: 8, bottom: 8 })
                    })
                  }
                } else {
                  Column() {
                    Image($r('sys.symbol.plus_circle_fill'))
                      .width(32)
                      .height(32)
                      .fillColor(ThemeManager.COLOR_PRIMARY)
                    Text('选择图片')
                      .fontSize(10)
                      .fontColor(ThemeManager.TEXT_HINT)
                      .margin({ top: 4 })
                  }
                  .width(100)
                  .height(100)
                  .borderRadius(8)
                  .border({ width: 1, color: '#E5E5E5', style: BorderStyle.Dashed })
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.handlePickImages();
                  })
                }

              }
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeManager.BG_CARD)
              .borderRadius(16)

              Column({ space: 8 }) {
                Text('商品标题')
                  .fontSize(14)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
                TextInput({ text: this.title, placeholder: '请输入商品标题' })
                  .fontSize(16)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                  .backgroundColor(ThemeManager.BG_PRIMARY)
                  .borderRadius(8)
                  .padding({ left: 12, right: 12 })
                  .height(44)
                  .onChange((value: string) => { this.title = value; })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeManager.BG_CARD)
              .borderRadius(16)

              Column({ space: 8 }) {
                Text('商品描述')
                  .fontSize(14)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
                TextArea({ text: this.description, placeholder: '请输入商品描述' })
                  .fontSize(16)
                  .fontColor(ThemeManager.TEXT_PRIMARY)
                  .backgroundColor(ThemeManager.BG_PRIMARY)
                  .borderRadius(8)
                  .padding(12)
                  .height(100)
                  .onChange((value: string) => { this.description = value; })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeManager.BG_CARD)
              .borderRadius(16)

              Row({ space: 12 }) {
                Column({ space: 8 }) {
                  Text('售价')
                    .fontSize(14)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                  TextInput({ text: this.price, placeholder: '¥' })
                    .fontSize(16)
                    .fontColor(ThemeManager.COLOR_PRICE)
                    .backgroundColor(ThemeManager.BG_PRIMARY)
                    .borderRadius(8)
                    .padding({ left: 12, right: 12 })
                    .height(44)
                    .type(InputType.Number)
                    .onChange((value: string) => { this.price = value; })
                }
                .layoutWeight(1)

                Column({ space: 8 }) {
                  Text('原价')
                    .fontSize(14)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                  TextInput({ text: this.originalPrice, placeholder: '¥' })
                    .fontSize(16)
                    .fontColor(ThemeManager.TEXT_PRIMARY)
                    .backgroundColor(ThemeManager.BG_PRIMARY)
                    .borderRadius(8)
                    .padding({ left: 12, right: 12 })
                    .height(44)
                    .type(InputType.Number)
                    .onChange((value: string) => { this.originalPrice = value; })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeManager.BG_CARD)
              .borderRadius(16)

              Column({ space: 8 }) {
                Text('成色')
                  .fontSize(14)
                  .fontColor(ThemeManager.TEXT_SECONDARY)
                Text(this.selectedCondition.length > 0 ? this.selectedCondition : '未设置')
                  .fontSize(16)
                  .fontColor(this.selectedCondition.length > 0 ? ThemeManager.TEXT_PRIMARY : ThemeManager.TEXT_HINT)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeManager.BG_CARD)
              .borderRadius(16)

              if (this.spu !== null) {
                Row() {
                  Text('商品状态：')
                    .fontSize(14)
                    .fontColor(ThemeManager.TEXT_SECONDARY)
                  Text(this.spu.status === 'on_sale' ? '在售' : this.spu.status === 'sold_out' ? '已售出' : '已下架')
                    .fontSize(14)
                    .fontColor(this.spu.status === 'on_sale' ? ThemeManager.COLOR_PRIMARY : '#FF4D4F')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .padding(16)
                .backgroundColor(ThemeManager.BG_CARD)
                .borderRadius(16)
              }

              Button('保存修改')
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(Color.White)
                .backgroundColor(ThemeManager.COLOR_PRIMARY)
                .borderRadius(24)
                .type(ButtonType.Normal)
                .enabled(!this.isSaving)
                .margin({ top: 8, bottom: 34 })
                .onClick(() => this.handleSave())
            }
            .padding({ left: 16, right: 16 })
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeManager.BG_PRIMARY)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      if (this.showDeleteConfirm) {
        Column() {
          Blank()
            .layoutWeight(1)
            .width('100%')
            .onClick(() => { this.showDeleteConfirm = false; })

          Column() {
            Text('确认删除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeManager.TEXT_PRIMARY)
              .margin({ bottom: 8 })
            Text('删除后无法恢复，确定要删除这个商品吗？')
              .fontSize(14)
              .fontColor(ThemeManager.TEXT_SECONDARY)
              .margin({ bottom: 24 })
            Row({ space: 12 }) {
              Button('取消')
                .fontSize(16)
                .fontColor(ThemeManager.TEXT_PRIMARY)
                .backgroundColor(ThemeManager.BG_PRIMARY)
                .borderRadius(24)
                .height(44)
                .layoutWeight(1)
                .type(ButtonType.Normal)
                .onClick(() => { this.showDeleteConfirm = false; })
              Button('删除')
                .fontSize(16)
                .fontColor(Color.White)
                .backgroundColor('#FF4D4F')
                .borderRadius(24)
                .height(44)
                .layoutWeight(1)
                .type(ButtonType.Normal)
                .onClick(() => this.handleDelete())
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 24, topRight: 24 })
          .padding(24)
          .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
      }
    }
    .width('100%')
    .height('100%')
  }
}
