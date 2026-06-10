export class ThemeManager {
  // 主色调 - 绿色 (环保主题)
  static readonly COLOR_PRIMARY: string = '#00B96B';
  static readonly COLOR_PRIMARY_LIGHT: string = '#52C997';
  static readonly COLOR_PRIMARY_DARK: string = '#008A4F';

  // 辅助色
  static readonly COLOR_ACCENT: string = '#FF6B35';
  static readonly COLOR_ACCENT_LIGHT: string = '#FF8C5E';

  // 背景色
  static readonly BG_PRIMARY: ResourceColor = $r('app.color.bg_primary');
  static readonly BG_SECONDARY: ResourceColor = $r('app.color.bg_secondary');
  static readonly BG_CARD: ResourceColor = $r('app.color.bg_card');

  // 文字色
  static readonly TEXT_PRIMARY: ResourceColor = $r('app.color.text_primary');
  static readonly TEXT_SECONDARY: ResourceColor = $r('app.color.text_secondary');
  static readonly TEXT_HINT: ResourceColor = $r('app.color.text_hint');

  // 分割线
  static readonly DIVIDER: ResourceColor = $r('app.color.divider');

  // 价格色
  static readonly COLOR_PRICE: string = '#FF4D4F';

  // 订单状态色
  static readonly COLOR_STATUS_PENDING: string = '#FAAD14';
  static readonly COLOR_STATUS_PROCESSING: string = '#1890FF';
  static readonly COLOR_STATUS_COMPLETED: string = '#52C41A';
  static readonly COLOR_STATUS_CANCELLED: string = '#999999';

  // 阴影 (ArkUI不支持直接shadow，用elevation或border模拟)
}
