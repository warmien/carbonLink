import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { AiBackendConfig } from '../constants/AiBackendConfig';
import { AISearchService } from '../services/AISearchService';

@Component
export struct AISearchBar {
  @Link value: string;
  @State suggestions: string[] = [];
  @State showSuggestions: boolean = false;
  placeholder: string = '搜索商品、品牌...';
  onSearch?: (keyword: string, productIds: string[]) => void;
  onCameraClick?: () => void;
  private lastInputTime: number = 0;

  private async doSearch(keyword: string): Promise<void> {
    if (keyword.trim() === '') {
      this.showSuggestions = false;
      this.suggestions = [];
      if (this.onSearch) this.onSearch(keyword, []);
      return;
    }
    const config = AiBackendConfig.getSearchConfig();
    const result = await AISearchService.semanticSearch(keyword, config);
    if (this.onSearch) this.onSearch(keyword, result.productIds);
  }

  private async fetchSuggestions(keyword: string): Promise<void> {
    if (keyword.trim().length < 2) {
      this.suggestions = [];
      this.showSuggestions = false;
      return;
    }
    const config = AiBackendConfig.getSearchConfig();
    const list = await AISearchService.searchSuggest(keyword, config);
    this.suggestions = list;
    this.showSuggestions = list.length > 0;
  }

  private onInputChange(text: string): void {
    this.value = text;
    this.lastInputTime = Date.now();
    const capturedTime = this.lastInputTime;
    setTimeout(() => {
      if (capturedTime === this.lastInputTime) {
        this.fetchSuggestions(text);
      }
    }, 600);
  }

  build() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.ic_search'))
            .width(18)
            .height(18)
            .fillColor(ThemeManager.TEXT_HINT)

          TextInput({ text: this.value, placeholder: this.placeholder })
            .fontSize(AppConstants.FONT_MD)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .height(36)
            .layoutWeight(1)
            .onChange((text: string) => {
              this.onInputChange(text);
            })
            .onSubmit(() => {
              this.showSuggestions = false;
              this.doSearch(this.value);
            })

          Image($r('sys.symbol.camera_fill'))
            .width(20)
            .height(20)
            .fillColor(ThemeManager.COLOR_PRIMARY)
            .onClick(() => {
              if (this.onCameraClick) {
                this.onCameraClick();
              }
            })
        }
        .layoutWeight(1)
        .height(40)
        .backgroundColor(ThemeManager.BG_PRIMARY)
        .borderRadius(20)
        .padding({ left: 12, right: 12 })
        .border({ width: 1, color: '#CCCCCC', style: BorderStyle.Solid })
        .onClick(() => {
          this.showSuggestions = false;
          this.doSearch(this.value);
        })
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG, top: AppConstants.SPACING_XS, bottom: AppConstants.SPACING_XS })

      Row() {
        Text('AI')
          .fontSize(9)
          .fontColor(Color.White)
          .backgroundColor(ThemeManager.COLOR_PRIMARY)
          .borderRadius(4)
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .margin({ right: 4 })
        Text('智能搜索已启用')
          .fontSize(AppConstants.FONT_XS)
          .fontColor(ThemeManager.COLOR_PRIMARY)
      }
      .width('100%')
      .padding({ left: AppConstants.SPACING_LG, bottom: 4 })

      if (this.showSuggestions && this.suggestions.length > 0) {
        Column() {
          ForEach(this.suggestions, (suggestion: string) => {
            Row() {
              Image($r('sys.symbol.magnifyingglass'))
                .width(14)
                .height(14)
                .fillColor(ThemeManager.TEXT_HINT)
                .margin({ right: 8 })
              Text(suggestion)
                .fontSize(AppConstants.FONT_MD)
                .fontColor(ThemeManager.TEXT_PRIMARY)
                .layoutWeight(1)
            }
            .width('100%')
            .height(40)
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.value = suggestion;
              this.showSuggestions = false;
              this.doSearch(suggestion);
            })
          })
        }
        .width('100%')
        .backgroundColor(ThemeManager.BG_CARD)
        .borderRadius(AppConstants.RADIUS_MD)
        .margin({ left: AppConstants.SPACING_LG, right: AppConstants.SPACING_LG })
        .border({ width: 1, color: ThemeManager.DIVIDER })
      }
    }
  }
}
