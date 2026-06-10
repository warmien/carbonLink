# CodeArts Agent Rules

## 平滑动画规则

- **所有页面切换**必须添加 `animation({ duration: 300, curve: Curve.EaseInOut })` 平滑过渡动画
- **所有弹窗/选择栏呼出**必须使用 `transition(TransitionEffect.OPACITY.combine(TransitionEffect.SLIDE(TransitionDirection.BOTTOM)).animation({ duration: 250, curve: Curve.EaseOut }))` 或等效的淡入+上滑动画
- **所有列表项增删**必须添加 `appear`/`disappear` 过渡动画，如 `.transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))`
- **所有按钮点击**必须添加缩放反馈动画，如 `.scale({ x: 0.95, y: 0.95 }).animation({ duration: 100, curve: Curve.EaseOut })`
- **所有展开/折叠**必须添加高度动画，使用 `animateTo({ duration: 300, curve: Curve.EaseInOut })` 包裹状态变更
- **Tab切换**必须设置 `animationDuration(300)` 
- **下拉刷新**收起时使用 `animation({ duration: 200, curve: Curve.EaseOut })`
- **通用动画曲线**：出场用 `Curve.EaseOut`，入场用 `Curve.EaseInOut`，交互反馈用 `Curve.EaseOut`
- **通用时长**：页面切换300ms，弹窗250ms，按钮反馈100ms，列表项200ms

## 版本完成后的 GitHub 上传规则

- 每完成一个版本（V1/V2/V3...）的所有编码任务后，**必须提醒用户上传到 GitHub**
- 提醒格式：`版本 Vx 已完成，是否需要将代码上传到 GitHub？请提供仓库地址。`
- 如果用户未提供 GitHub 仓库地址，**必须再次提醒**，直到用户确认或拒绝
- 如果用户确认上传但未提供仓库地址，询问：`请提供 GitHub 仓库链接，我将协助您推送代码。`
- 如果用户明确拒绝上传，记录在对话中，不再重复提醒该版本
- 用户可能在每个新项目对话时提供 GitHub 链接，注意读取并使用

## 上传流程

1. 版本编码全部完成 → 提醒用户上传
2. 用户提供 GitHub 仓库地址 → 执行 `git init`（如需要）→ `git add` → `git commit` → `git push`
3. 如果项目尚未初始化 git，先执行初始化再推送
4. 如果推送失败，告知用户具体错误并建议解决方案