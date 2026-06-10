import { EcoAchievement } from '../models/EcoAchievement';
import { achievementRepository } from '../repository/AchievementRepository';
import { ThemeManager } from '../theme/ThemeManager';

@Entry
@Component
struct EcoAchievementPage {
  @State achievements: EcoAchievement[] = [];
  @State btnScale: number = 1;
  private userId: string = 'user_1';

  aboutToAppear(): void {
    this.achievements = achievementRepository.getAchievements(this.userId);
  }

  build() {
    Column() {
      Row() {
        Text('环保成就')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeManager.TEXT_PRIMARY)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      List({ space: 12 }) {
        ForEach(this.achievements, (a: EcoAchievement) => {
          ListItem() {
            this.AchievementCard(a)
          }
          .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
        })
      }
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.BG_PRIMARY)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }

  @Builder
  AchievementCard(a: EcoAchievement) {
    Row() {
      Text(a.icon)
        .fontSize(32)
        .margin({ right: 12 })

      Column() {
        Text(a.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(a.unlocked ? ThemeManager.TEXT_PRIMARY : ThemeManager.TEXT_SECONDARY)
        Text(a.description)
          .fontSize(12)
          .fontColor(ThemeManager.TEXT_HINT)
          .margin({ top: 2 })

        if (!a.unlocked) {
          Progress({ value: a.progress, total: a.targetValue, type: ProgressType.Linear })
            .width('100%')
            .height(4)
            .color(ThemeManager.COLOR_PRIMARY)
            .backgroundColor('#E8E8E8')
            .margin({ top: 8 })
          Text(a.progress + '/' + a.targetValue)
            .fontSize(10)
            .fontColor(ThemeManager.TEXT_HINT)
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (a.unlocked) {
        Text('已解锁')
          .fontSize(12)
          .fontColor(ThemeManager.COLOR_PRIMARY)
          .fontWeight(FontWeight.Medium)
      } else {
        Text('+' + a.rewardCredits + '积分')
          .fontSize(12)
          .fontColor(ThemeManager.COLOR_ACCENT)
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(12)
    .backgroundColor(a.unlocked ? '#F0FFF4' : ThemeManager.BG_CARD)
    .border({ width: 1, color: a.unlocked ? ThemeManager.COLOR_PRIMARY : '#F0F0F0' })
  }
}