# CarbonLink 开发历程记录

## 项目概述

**项目名称**：碳易链（CarbonLink）  
**项目定位**：HarmonyOS NEXT 原生应用 — 校园二手闲置交易平台  
**技术栈**：ArkTS + ArkUI + Stage Model + MVVM  
**仓库地址**：https://github.com/warmien/carbonLink.git  
**当前版本**：V9 种子数据+OBS联调完成版

---

## V1-V6 全版本开发

### V1：项目初始化与基础框架
- 创建 HarmonyOS NEXT 项目
- 搭建 MVVM 架构
- 实现底部 Tab 导航（首页/分类/发布/消息/我的）

### V2：核心功能实现
- 商品列表与详情页
- 用户系统（登录/注册/个人中心）
- 消息系统（聊天列表/聊天页）

### V3：AI 功能集成
- AI 图像识别（豆包 API）
- AI 智能估价
- AI 描述生成
- AI 搜索推荐

### V4：碳积分体系（初版）
- CreditEngine 积分引擎
- 积分中心页面
- 积分流水页面
- 环保成就系统
- 积分商城

### V5：交易与订单
- 订单中心
- 购买/确认收货流程
- 积分自动发放

### V6：管理后台
- 后端：Node.js + Express + better-sqlite3 + JWT
- 前端：Vue 3 + Element Plus + ECharts + Pinia

---

## UI 优化与编译修复阶段

### 底部导航栏改造
- 自定义 Stack 布局替代 Tabs 内置 TabBar
- 中间发布按钮凸起效果（白色外圈 + 渐变内圈 + SVG 图标）
- 发布按钮添加"发布减碳"文字
- Tab 切换动画 animationDuration(300) + 按钮缩放反馈
- SymbolGlyph 系统图标库替代 Image 图标
  - 选中：`_fill` 图标 + `#5CB8A0` 填充色
  - 未选中：描边版图标 + `#000000` 黑色
- 文字颜色统一为黑色 `#000000`

### 发布页优化
- 添加图片区域改为虚线框 + 居中加号 + `#5CB8A0` 配色（100x100）
- 删除"添加图片"标题行和文字
- 商品描述移到图片选择下方
- AI 识别按钮背景色改为 `#5CB8A0` + 白色文字 + 点击缩放效果
- 识别中显示 LoadingProgress + "识别中..."
- 移除 AI 估价按钮
- 移除 AI 生成描述按钮
- AI 识别一步到位（填充所有字段）

### 页面切换动画
- 所有页面添加 `.transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))`
- 3 个弹窗添加 `.transition(TransitionEffect.OPACITY.animation({ duration: 250 }))`
- 弹窗 z-index(999) 修复

### 编译错误修复
- 系统图标符号替换：`list_bullet_fill` → `leaf_fill`、`tag_fill` → `gift_fill`
- `Partial<T>` → 完整类型
- `instanceof Array` → `Array.isArray()`
- `Object.keys()` → 移除
- `typeof` 运行时检查 → try/catch + JSON.parse
- BOM 头移除（15 个文件）
- `GradientDirection.BottomRight` → `GradientDirection.Bottom`
- `TransitionDirection` → `TransitionEffect.OPACITY.animation()`
- `OrderCenterPage.onTradeCompleted` 参数修复

---

## 碳积分功能模块改造（核心变更）

### 成色体系升级
- **旧**：4 级（全新/几乎全新/轻微使用/正常使用）
- **新**：6 级 A-F（A级-全新未用 / B级-99成新 / C级-95成新 / D级-9成新 / E级-8成新 / F级-7成新）

### 分类体系升级
- **旧**：10 个扁平分类（电子产品/图书/服装/家居/数码/办公/运动/母婴/美妆/食品/其他）
- **新**：10 大类 + 子分类二级结构
  - 电子数码（旧手机/平板电脑/蓝牙耳机等 13 项）
  - 图书教材（书籍/笔记本/考研网课账号）
  - 服装鞋帽（外套/包/帽子/袜子类/丝巾类）
  - 家居生活（小电煮锅/台灯/散热架等 15 项）
  - 美妆护肤（28 项完整美妆子分类）
  - 运动户外（球类/车类/健身卡等 10 项）
  - 文具办公（文具/计算器/背书椅）
  - 乐器文创（二手乐器/文创产品/绿植）
  - 虚拟服务（考研网课账号/健身卡/水卡）
  - 其他闲置

### 碳积分核算规则
- **核心公式**：碳积分 = 物品基础积分 × 成色系数
- **成色系数**：A=1.0 / B=0.85 / C=0.7 / D=0.55 / E=0.4 / F=0.25
- **买家奖励**：卖家积分的 20%
- **捐赠奖励**：基础积分的 1.5 倍
- **改造奖励**：基础积分的 2 倍
- **转让手续费**：10%
- **违规扣除**：2 倍积分

### 新建文件
- `config/CarbonCreditTable.ets` — 碳积分核算表 + 成色系数 + 模糊匹配
- `pages/SplashAdPage.ets` — 开屏广告页
- `services/SplashAdService.ets` — 广告数据服务

### 修改文件
| 文件 | 变更 |
|------|------|
| `models/Product.ets` | ProductCondition A-F 六级；新增 subCategory/carbonReduction/carbonCredits |
| `constants/AppConstants.ets` | 10 大类 + SUB_CATEGORIES 子分类映射 |
| `config/CreditRules.ets` | 买家20%/捐赠1.5倍/改造2倍/转让10%手续费/违规2倍扣除 |
| `engine/CreditEngine.ets` | 基于分类×成色核算；新增捐赠/改造/转让/违规方法 |
| `models/CreditTransaction.ets` | 新增6种交易类型 + carbonReduction 字段 |
| `models/RecognitionResult.ets` | 新增 description/category/subCategory/suggestedPrice/originalPrice |
| `services/AIRecognitionService.ets` | 解析新字段 |
| `constants/AiBackendConfig.ets` | AI prompt 改为一次返回所有字段 |
| `utils/ConditionMapper.ets` | 适配 A-F 六级成色 |
| `pages/Index.ets` | 两级分类选择器 + A-F成色 + 碳积分/碳减排表单行 + AI识别一步到位 |
| `pages/CreditCenterPage.ets` | 新增碳减排量展示 |
| `pages/CreditLedgerPage.ets` | 新增6种交易类型标签 |
| `repository/CreditTransactionRepository.ets` | getTotalReduction + 新类型过滤 |
| `mock/MockProducts.ets` | 适配新分类/成色 + 自动计算碳积分 |

### AI 识别一步到位
- 上传图片后不自动识别，需手动点击 AI 识别按钮
- AI 返回 JSON 包含：name/condition/category/subCategory/description/suggestedPrice/originalPrice
- 自动填充：标题、分类、子分类、成色、商品描述、售价、原价
- 自动计算：碳积分、碳减排量
- 子分类模糊匹配（"手机"→"旧手机"，"耳机"→"蓝牙耳机"）

---

## 登录注册前端开发（V7 前端改造）

### 新建文件
| 文件 | 说明 |
|------|------|
| `services/HttpService.ets` | HTTP统一请求服务，封装@ohos.net.http，JWT自动附加，401刷新，统一响应解析 |
| `services/TokenManager.ets` | Token管理器，preferences持久化，双Token存储/刷新/清除/过期判断 |
| `utils/FormValidator.ets` | 表单校验工具，手机号/密码/确认密码/验证码/昵称校验 |
| `services/AuthManager.ets` | 登录状态管理器，login/register/logout/checkAuthOnStartup，AppStorage同步 |
| `services/CaptchaService.ets` | 验证码服务，调用GET /api/v1/captcha获取图形验证码 |
| `pages/LoginPage.ets` | 登录页面，Logo+手机号+密码+验证码+记住我+登录按钮+注册链接 |
| `pages/RegisterPage.ets` | 注册页面，导航栏+手机号+密码+确认密码+验证码+协议勾选+注册按钮 |
| `pages/SettingsPage.ets` | 设置页面，个人信息/修改密码/关于我们+退出登录确认弹窗 |

### 修改文件
| 文件 | 变更 |
|------|------|
| `constants/AppConstants.ets` | 新增 ROUTE_LOGIN/ROUTE_REGISTER/ROUTE_SETTINGS 路由常量 |
| `router/RouterManager.ets` | 新增 toLogin/toRegister/toMainFromLogin/toSettings + requireAuth/redirectIfLoggedIn 守卫 |
| `theme/ThemeManager.ets` | COLOR_PRIMARY 改为 #5CB8A0，LIGHT 改为 #8ED4C2，DARK 改为 #4A9A84 |
| `entryability/EntryAbility.ets` | 启动时初始化 TokenManager |
| `pages/SplashAdPage.ets` | goToMain 改为根据 AuthManager.checkAuthOnStartup 判断跳转登录页/首页 |
| `pages/Index.ets` | ProfilePageView 添加登录/未登录状态适配+设置入口；PublishPageView/MessagePageView 添加登录守卫；硬编码#5CB8A0/#66C2A5/#006D77替换为ThemeManager常量 |
| `repository/UserRepository.ets` | 新增 login/register/logout/refreshToken/getProfile/updateProfile/changePassword 方法 |
| `components/ImagePickerPanel.ets` | #5CB8A0 → ThemeManager.COLOR_PRIMARY |
| `pages/CreditCenterPage.ets` | #5CB8A0 → ThemeManager.COLOR_PRIMARY |
| `resources/base/profile/main_pages.json` | 注册 LoginPage/RegisterPage/SettingsPage 路由 |

### 核心功能
- **双Token机制**：AccessToken 2h + RefreshToken 7d，401自动刷新，刷新失败跳转登录页
- **图形验证码**：SVG base64格式，点击刷新，淡入淡出动画200ms
- **表单校验**：手机号11位格式、密码≥6位、确认密码一致、验证码≥4位
- **记住我**：preferences持久化手机号
- **路由守卫**：requireAuth()拦截发布/消息页，redirectIfLoggedIn()防止重复进入登录页
- **启动流程**：开屏广告 → Token检查 → 有效进首页/无效进登录页
- **主题色统一**：全局#5CB8A0，ThemeManager常量引用，消除硬编码

---

## 后端登录注册API开发（V7 后端）

### 环境配置
- 安装 nvm-windows 1.2.2
- Node.js 从 v24.12.0 降级到 v20.20.2 LTS（better-sqlite3 兼容性）
- npm 10.8.2 → 11.6.2
- 修复 nvm settings.txt 路径配置（NVM_SYMLINK 指向正确目录）

### 新建文件
| 文件 | 说明 |
|------|------|
| `server/src/businessDatabase.ts` | 业务数据库初始化，22张表+索引+初始分类/成色数据+3条测试用户 |
| `server/src/models/User.ts` | 用户模型接口 |
| `server/src/services/UserAuthService.ts` | 注册/登录/刷新Token/登出/改密码/改资料 |
| `server/src/services/CaptchaService.ts` | svg-captcha生成/校验/频率限制/过期清理 |
| `server/src/middleware/userAuth.ts` | 用户JWT中间件 |
| `server/src/routes/userAuth.ts` | 7个API接口（captcha/register/login/refresh/logout/profile/password） |
| `server/src/types/svg-captcha.d.ts` | 手动类型声明 |
| `server/scripts/init.sql` | 纯SQL初始化脚本 |
| `server/scripts/init-db.sh` | Shell初始化脚本 |
| `server/Dockerfile` | Docker镜像 |
| `server/docker-compose.yml` | Docker Compose编排 |

### 修改文件
| 文件 | 变更 |
|------|------|
| `server/src/index.ts` | 引入业务数据库+用户路由+定时清理任务 |
| `server/src/database.ts` | 修复导出类型 |
| `server/src/middleware/audit.ts` | 修复类型兼容 |
| `server/package.json` | 新增 svg-captcha + uuid + bcryptjs 依赖 |

### API测试结果
| 接口 | 方法 | 结果 |
|------|------|------|
| /api/v1/captcha | GET | ✅ 返回captchaKey + SVG base64图片 |
| /api/v1/login | POST | ✅ 双Token(accessToken+refreshToken)+用户信息 |
| /api/v1/register | POST | ✅ 注册成功 |
| /api/v1/refresh | POST | ✅ Token刷新 |
| /api/v1/profile | GET | ✅ 需JWT认证 |
| /api/v1/logout | POST | ✅ Token加入黑名单 |

### 测试用户
| 手机号 | 密码 | 昵称 | 碳积分 | 信用等级 |
|--------|------|------|--------|----------|
| 13800000001 | 123456 | 测试用户小王 | 280 | 良好 |
| 13800000002 | 123456 | 测试用户小李 | 520 | 优秀 |
| 13800000003 | 123456 | 测试用户小张 | 100 | 一般 |

---

## V8：SPU/SKU模型重构 + 前后端对接

### 后端 — SPU/SKU模型重构（全层）

#### 新建文件
| 文件 | 说明 |
|------|------|
| `server/src/models/Product.ts` | 16个TypeScript接口/类型/枚举（CreateSPUParams/SPUDTO/SKUDTO等） |
| `server/src/services/ProductService.ts` | 商品服务（CRUD+碳减排计算+规格值关联+属性关联） |
| `server/src/services/InventoryService.ts` | 库存服务（原子扣减/锁定/回滚/补货） |
| `server/src/services/SpecService.ts` | 规格/属性管理服务（CRUD+分类关联） |
| `server/src/services/MigrationService.ts` | 数据迁移服务（旧products→spu/sku迁移） |
| `server/src/services/FavoriteService.ts` | 收藏服务（toggle/列表/计数/检查） |
| `server/src/routes/product.ts` | 商品API路由（含skuRouter导出） |
| `server/src/routes/spec.ts` | 规格/属性API路由 |
| `server/src/routes/inventory.ts` | 库存API路由 |
| `server/src/routes/migration.ts` | 迁移API路由 |
| `server/src/routes/favorite.ts` | 收藏API路由（toggle/list/count/check） |

#### 修改文件
| 文件 | 变更 |
|------|------|
| `server/src/businessDatabase.ts` | 10张新表DDL+索引+兼容视图v_products+种子数据+favorites外键迁移(products→spu)+subCategoryId NULL修复 |
| `server/src/index.ts` | 路由注册（products/skus/inventory/migration/favorites前缀）+analytics改/admin |

#### 数据库结构
- 31张表 + 1视图(v_products) + 47索引
- 种子数据：6规格名/13规格值/12分类规格关联/5属性名/5分类属性关联
- API端点：22/22通过（商品CRUD+规格树+库存锁定/解锁+迁移状态+收藏CRUD）

### 前端 — SPU/SKU模型 + 前后端对接

#### 新建文件
| 文件 | 说明 |
|------|------|
| `entry/src/main/ets/models/SPU.ets` | SPU数据模型 + SPUStatus枚举 |
| `entry/src/main/ets/models/SKU.ets` | SKU数据模型 + SpecValueItem |
| `entry/src/main/ets/models/Spec.ets` | SpecName/SpecValue/AttributeName/ProductAttribute/CategorySpecTree |
| `entry/src/main/ets/components/SpecSelector.ets` | 规格选择器（双数组替代Record） |
| `entry/src/main/ets/components/AttributeList.ets` | 属性列表组件 |

#### 修改文件
| 文件 | 变更 |
|------|------|
| `entry/src/main/ets/repository/ProductRepository.ets` | 异步API方法(fetchProducts/getProductDetail/createProduct/toggleFavorite/getFavoriteProducts等)+同步Mock方法兼容+productToSPU()静态转换 |
| `entry/src/main/ets/components/ProductCard.ets` | 接受SPU模型，起售价+多规格标签 |
| `entry/src/main/ets/components/RecommendProductCard.ets` | 适配SPU模型，minPrice替代Product.price |
| `entry/src/main/ets/pages/ProductDetailPage.ets` | SPU+SKU双模型+规格选择+属性展示+收藏API对接 |
| `entry/src/main/ets/pages/Index.ets` | 首页/分类页改为异步API+SPU模型；发布页对接createProduct()API；CategoryIdMap分类名→ID映射；WaterfallGrid/NearbyProducts改用SPU |
| `entry/src/main/ets/pages/MyProductsPage.ets` | 改为异步API+SPU模型，AuthManager获取用户ID |
| `entry/src/main/ets/pages/MyFavoritesPage.ets` | 改为异步API+SPU模型，getFavoriteProducts() |
| `entry/src/main/ets/services/AISearchService.ets` | fallbackSearch改为异步，调用fetchProducts(keyword) |

### 前后端对接状态

| 页面 | 状态 | 数据源 |
|------|------|--------|
| 首页 HomePageView | ✅ 已对接 | fetchProducts() / fetchProducts('categoryId=xx') |
| 分类页 CategoryPageView | ✅ 已对接 | fetchProducts('categoryId=xx') |
| 发布页 PublishPageView | ✅ 已对接 | createProduct() |
| 商品详情 ProductDetailPage | ✅ 已对接 | getProductDetail() + getCategorySpecTree() |
| 我的发布 MyProductsPage | ✅ 已对接 | fetchProducts('sellerId=xx') |
| 我的收藏 MyFavoritesPage | ✅ 已对接 | getFavoriteProducts() |
| 收藏切换 | ✅ 已对接 | toggleFavorite() |
| AI搜索 | ✅ 已对接 | fetchProducts('keyword=xx') fallback |
| 推荐引擎 | ⏳ 暂保留Mock | RecommendationEngine仍用同步Mock（首页已移除推荐区域） |

### 后端API路由

| 路由前缀 | 说明 |
|----------|------|
| /api/v1/products | 商品CRUD |
| /api/v1/skus | SKU更新 |
| /api/v1/inventory | 库存锁定/解锁 |
| /api/v1/migration | 数据迁移 |
| /api/v1/favorites | 收藏toggle/列表/计数/检查 |
| /api/v1/spec-names | 规格名CRUD |
| /api/v1/category-specs/:categoryId | 分类规格树 |
| /api/v1/category-attributes/:categoryId | 分类属性列表 |

---

## GitHub 提交记录

| 时间 | Commit | 说明 |
|------|--------|------|
| 2026-06-10 | 570d202 | UI优化与编译修复 |
| 2026-06-11 | 8758287 | 发布减碳前端开发完毕版 |

---

### 登录流程Bug修复

- `LoginPage.ets` handleLogin() 添加 try-catch-finally，异常时显示"登录失败，请检查网络连接后重试"并重置 isLoading
- 添加 `ApiResponse` 类型导入，response 变量添加类型注解
- isLoading 重置移到 finally 块，确保无论成功/失败/异常都能重置

### 首页UI优化

- 删除"附近闲置"区域和 `NearbyProducts` 组件（无定位功能）
- "推荐好物"商品列表改为 `Flex` 双列瀑布流，整个首页统一在一个 `Scroll` 中
- 分类图标移除背景色圆角矩形，只保留28x28彩色图标
- 搜索栏改为默认数据库关键词搜索，可手动切换AI搜索

### ArkTS编译错误全面修复

| 修复类型 | 涉及文件 | 修复方式 |
|----------|---------|---------|
| `object` 类型注解 | AISearchService/AIRecognitionService/AIDescriptionService/AIPricingService/JsonPathResolver | `object` → `Record<string, string \| number \| boolean \| object>` |
| `Array.isArray()` | AISearchService.ets | 替换为 `typeof` 类型检查 |
| `as number` 从联合类型转换 | AuthManager/TokenManager/Index/EditProfilePage | 改为 `typeof val === 'number' ? val : 0` |
| `pencil_circle_fill` 图标 | EditProfilePage.ets | 替换为 `pencil` |
| 空状态默认图标 | EmptyState.ets | `app.media.startIcon` → `sys.symbol.xmark_circle_fill` |

### 华为云OBS图片上传接入

#### 方案：前端直传OBS + 后端签名预授权

1. 后端生成临时签名URL（30分钟有效期）
2. 前端获取签名URL后直接PUT上传到OBS
3. 后端仅存储OBS公开访问URL

#### 后端新建文件

| 文件 | 说明 |
|------|------|
| `server/src/services/ObsService.ts` | OBS服务：初始化/生成上传凭证/删除对象/提取objectKey |
| `server/src/routes/obs.ts` | OBS路由：`/upload-credential` 单张凭证 + `/batch-credentials` 批量凭证(≤9张) |
| `server/src/types/esdk-obs-nodejs.d.ts` | OBS SDK类型声明 |
| `server/.env.example` | OBS环境变量模板 |

#### 后端修改文件

| 文件 | 变更 |
|------|------|
| `server/package.json` | 新增 `esdk-obs-nodejs` 依赖 |
| `server/src/index.ts` | 引入OBS路由 + `initObsFromEnv()` 初始化 |

#### 前端新建文件

| 文件 | 说明 |
|------|------|
| `entry/src/main/ets/services/ObsService.ets` | OBS上传服务：获取凭证/上传文件到OBS/批量上传 |

#### 前端修改文件

| 文件 | 变更 |
|------|------|
| `entry/src/main/ets/pages/Index.ets` | 发布页：选图后先上传OBS获取URL再发布；添加 `isPublishing` 状态 |
| `entry/src/main/ets/pages/EditProfilePage.ets` | 头像上传：从相册选图→上传OBS→更新头像URL |

#### OBS环境变量

```env
OBS_ACCESS_KEY_ID=your_access_key_id
OBS_SECRET_ACCESS_KEY=your_secret_access_key
OBS_ENDPOINT=obs.cn-north-4.myhuaweicloud.com
OBS_BUCKET=your-bucket-name
```

---

## V9：种子数据填充 + OBS联调 + ArkTS修复

### 种子数据填充

- 创建 `server/scripts/seed-direct.js` 脚本，20条多种类商品数据直接插入DB
- 关闭外键检查 `db.pragma('foreign_keys = OFF')` 避免约束冲突
- SKU表列名修正：`condition_grade` → `condition`，移除 `stock` 列
- 执行结果：SPU 25条（含5条旧测试数据）、SKU 28条、v_products视图25条

#### 种子商品清单

| # | 商品 | 分类 | 价格 | 成色 | 卖家 |
|---|------|------|------|------|------|
| 1 | iPhone 13 128G 绿色 | 电子数码 | ¥2999 | B级-99成新 | 小王 |
| 2 | iPad Air 5 64G | 电子数码 | ¥2599 | C级-95成新 | 小李 |
| 3 | AirPods Pro 2代 | 电子数码 | ¥899 | B级-99成新 | 小张 |
| 4 | 高等数学同济第七版 | 图书教材 | ¥15 | D级-9成新 | 小王 |
| 5 | 考研英语真题十年 | 图书教材 | ¥25 | C级-95成新 | 小李 |
| 6 | 优衣库羽绒服黑色L码 | 服装鞋帽 | ¥199 | C级-95成新 | 小张 |
| 7 | Nike Air Force 1 白色42码 | 服装鞋帽 | ¥299 | D级-9成新 | 小王 |
| 8 | 小米台灯Pro | 家居生活 | ¥59 | B级-99成新 | 小李 |
| 9 | 小熊电煮锅1.5L | 家居生活 | ¥35 | D级-9成新 | 小张 |
| 10 | 兰蔻小黑瓶精华50ml | 美妆护肤 | ¥280 | B级-99成新 | 小王 |
| 11 | MAC口红3支套装 | 美妆护肤 | ¥120 | C级-95成新 | 小李 |
| 12 | 李宁跑步鞋43码 | 运动户外 | ¥159 | D级-9成新 | 小张 |
| 13 | 瑜伽垫加厚10mm | 运动户外 | ¥29 | C级-95成新 | 小王 |
| 14 | 得力文具套装 | 文具办公 | ¥18 | B级-99成新 | 小李 |
| 15 | 卡西欧计算器fx-991CNX | 文具办公 | ¥89 | B级-99成新 | 小张 |
| 16 | 尤克里里23寸 | 乐器文创 | ¥129 | C级-95成新 | 小王 |
| 17 | 手绘帆布包 | 乐器文创 | ¥35 | B级-99成新 | 小李 |
| 18 | 网易云音乐年卡 | 虚拟服务 | ¥68 | A级-全新未用 | 小张 |
| 19 | 考研网课账号政治+英语 | 虚拟服务 | ¥99 | A级-全新未用 | 小王 |
| 20 | 宿舍收纳架三层 | 其他闲置 | ¥25 | D级-9成新 | 小李 |

### ArkTS编译修复（续）

| 修复类型 | 涉及文件 | 修复方式 |
|----------|---------|---------|
| `as string` 从object转换 | SyncDataStore.ets | `typeof result === 'string' ? result : String(result)` |
| `as string[]` 从联合类型转换 | AISearchService.ets | `(string \| number \| boolean \| object)[]` + `.map(String)` |
| `as string[]` 从联合类型转换 | ProductRepository.ets toStrArr() | typeof守卫 + `.map(String)` |
| 冗余 `as number` | ProductRepository.ets toBool() | typeof守卫后已收窄，移除冗余断言 |

### 端到端API测试

- 创建 `server/scripts/e2e-test.js` 自动化测试脚本
- 测试结果：**26/26 全部通过**
  - 验证码 ✅ | 登录 ✅ | 商品列表 ✅ | 商品详情 ✅
  - 分类过滤 ✅ | 关键词搜索 ✅ | 用户Profile ✅ | OBS上传凭证 ✅
  - 收藏列表 ✅ | 健康检查 ✅ | 分类规格 ✅ | 我的发布 ✅

### 后端启动方式更新

- 使用 `ts-node-transpile-only` 替代 `npx ts-node --transpile-only`
- 完整路径：`node server/node_modules/ts-node/dist/bin-transpile.js src/index.ts`
- 创建 `server/start.ps1` 启动脚本

---

## 待办事项

- [x] 配置OBS环境变量（AK/SK/Endpoint/Bucket）
- [x] 种子数据填充（20条商品）
- [x] 端到端API联调测试（26/26通过）
- [ ] 替换 `ic_publish_icon.svg` 发布按钮中心图标
- [ ] 替换 `ic_search.svg` 搜索框放大镜图标
- [ ] 替换 `foreground.png`/`background.png`/`startIcon.png` APP 图标
- [ ] 11 处 `app.media.startIcon` 商品/Banner 占位图替换为实际图片
- [ ] V6 管理后台部署与联调
- [ ] 功能测试（AI 识别、图片选择、弹窗动画、碳积分计算）
- [ ] 登录注册端到端联调测试（前端DevEco Studio编译后真机测试）
- [ ] 推荐引擎 RecommendationEngine 重构为异步API（当前仍用同步Mock）
- [ ] WidgetDataProvider 改为异步API（当前仍用同步Mock）
- [ ] ProfilePageView 收藏数改为异步API获取
- [ ] 前端DevEco Studio编译验证（静态检查已通过，需实际编译确认）