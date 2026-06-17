# CarbonLink 开发历程记录

## 项目概述

**项目名称**：碳易链（CarbonLink）  
**项目定位**：HarmonyOS NEXT 原生应用 — 校园二手闲置交易平台  
**技术栈**：ArkTS + ArkUI + Stage Model + MVVM  
**仓库地址**：https://github.com/warmien/carbonLink.git  
**当前版本**：V13 积分系统后端化

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

## V9.2：购买流程实现（商品下架+支付方式选择）

### 后端修改

| 文件 | 变更 |
|------|------|
| `server/src/businessDatabase.ts` | orders表外键修复：`product_id` REFERENCES `spu(id)`（原为products(id)） |
| `server/src/services/OrderService.ts` | **新建** 订单服务：创建订单+SKU标记sold_out+SPU全部售完标记sold_out+卖家sold_count+1 |
| `server/src/routes/order.ts` | **新建** 订单路由：POST / 创建订单、GET /buyer 买家订单、GET /seller 卖家订单、PUT /:id/confirm 确认收货、PUT /:id/ship 发货 |
| `server/src/index.ts` | 注册 `/api/v1/orders` 路由 |

### 前端修改

| 文件 | 变更 |
|------|------|
| `entry/src/main/ets/pages/ProductDetailPage.ets` | "立即购买"按钮：点击弹出支付方式选择弹窗（微信/支付宝）；调用POST /orders API；购买成功后商品状态改为sold_out+按钮变"已售出"灰显；不能购买自己商品校验；已下架商品禁用购买 |

### 购买流程

1. 点击"立即购买" → 弹出支付方式选择（微信支付/支付宝）
2. 选择支付方式 → 调用 `POST /api/v1/orders`
3. 后端事务：创建订单 + SKU状态→sold_out + 若所有SKU售完则SPU状态→sold_out + 卖家sold_count+1
4. 前端：购买成功后刷新商品状态，按钮变为"已售出"灰显不可点击
5. 校验：不能购买自己发布的商品、商品不存在或已下架报错

---

## V9.1：个人中心统计项功能完善

### 后端修改

| 文件 | 变更 |
|------|------|
| `server/src/models/User.ts` | UserPublicProfile 新增 `favoriteCount` 字段 |
| `server/src/services/UserAuthService.ts` | `getPublicProfile()` 查询 favorites 表获取收藏数 |
| `server/src/routes/userAuth.ts` | 新增3个浏览记录API：`POST /browse` 记录浏览、`GET /browse-history` 浏览历史列表、`GET /browse-count` 浏览计数 |

### 前端修改

| 文件 | 变更 |
|------|------|
| `entry/src/main/ets/models/User.ets` | User 新增 `favoriteCount` 字段 |
| `entry/src/main/ets/services/AuthManager.ets` | `getCurrentUser()` 解析 favoriteCount；`updateUserProfile()` 序列化 favoriteCount |
| `entry/src/main/ets/pages/Index.ets` | ProfilePageView：新增 `browseCount` 状态+`loadBrowseCount()` 异步获取；`favoriteCount` 从API获取（非硬编码0）；"浏览记录"显示 `browseCount`（非 followerCount）；"我的发布"点击跳转 MyProductsPage；"我的收藏"点击跳转 MyFavoritesPage；"浏览记录"点击跳转 BrowseHistoryPage；导入 HttpService |
| `entry/src/main/ets/pages/ProductDetailPage.ets` | 商品详情加载时调用 `POST /browse` 记录浏览行为；导入 HttpService/AuthManager |
| `entry/src/main/ets/pages/BrowseHistoryPage.ets` | **新建** 浏览记录页面，调用 `/browse-history` API，展示商品列表+点击跳转详情 |
| `entry/src/main/ets/constants/AppConstants.ets` | 新增 `ROUTE_BROWSE_HISTORY` 路由常量 |
| `entry/src/main/ets/router/RouterManager.ets` | 新增 `toBrowseHistory()` 路由方法 |
| `entry/src/main/resources/base/profile/main_pages.json` | 注册 BrowseHistoryPage |

### 四个统计项功能说明

| 统计项 | 数据来源 | 点击跳转 |
|--------|----------|----------|
| 我的发布 | `user.productCount`（后端users表） | MyProductsPage |
| 已售出 | `user.soldCount`（后端users表） | 无跳转 |
| 我的收藏 | `user.favoriteCount`（后端favorites表COUNT） | MyFavoritesPage |
| 浏览记录 | `/browse-count` API（后端user_behaviors表COUNT） | BrowseHistoryPage |

---

## GitHub 提交记录

| 时间 | Commit | 说明 |
|------|--------|------|
| 2026-06-10 | 570d202 | UI优化与编译修复 |
| 2026-06-11 | 8758287 | 发布减碳前端开发完毕版 |
| 2026-06-15 | d6c27b2 | V9 SPU/SKU重构+登录注册+OBS图片上传+种子数据+端到端联调 |

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

## V10：OBS图片上传修复 + 图片显示重构

### 问题根因

1. **OBS上传失败**：`fs.openSync()` 无法直接打开 PhotoViewPicker 返回的 `file://media/` 格式URI，需要先拷贝到沙箱目录
2. **种子数据SVG不显示**：HarmonyOS Image组件不支持SVG格式
3. **编辑页图片添加无响应**：`ImagePickerService` 缺少错误日志，无法定位问题
4. **商品详情页图片空白**：SVG URL直接传给Image组件无法渲染
5. **库存为0时购买按钮未禁用**：仅检查spu.status，未检查sku.availableStock

### 修改文件

| 文件 | 变更 |
|------|------|
| `entry/src/main/ets/services/ObsService.ets` | 新增 `context`/`init()`/`copyToSandbox()`；`uploadFileToObs()` 判断媒体URI自动拷贝到沙箱再上传；上传后清理临时文件 |
| `entry/src/main/ets/entryability/EntryAbility.ets` | `onWindowStageCreate` 中调用 `ObsService.init(this.context)` |
| `entry/src/main/ets/services/ImagePickerService.ets` | 添加 hilog 日志，记录选图结果和错误信息 |
| `entry/src/main/ets/components/ImagePickerPanel.ets` | 新增 `ImageDisplayUtil` 工具类统一图片显示逻辑；支持远程URL/本地URI/SVG过滤；添加按钮改为图标+文字 |
| `entry/src/main/ets/pages/EditProductPage.ets` | 全面重构：使用 `ImageDisplayUtil` 显示图片；`handlePickImages()` 手动构建新数组（避免concat）；`removeImage()` 手动构建数组；添加按钮缩放反馈动画 |
| `entry/src/main/ets/pages/ProductDetailPage.ets` | Swiper图片使用 `ImageDisplayUtil.getDisplaySrc()`；新增 `getAvailableStock()` 方法；购买按钮增加库存检查（库存0显示"已售罄"灰显） |
| `entry/src/main/ets/pages/Index.ets` | 发布页：部分图片上传失败时提示已上传数量；`uploadedUrls.length === 0` 阻止提交 |
| `entry/src/main/ets/components/ProductCard.ets` | `getDisplayImage()` SVG图片返回占位图而非SVG URL |
| `entry/src/main/ets/components/RecommendProductCard.ets` | `getDisplayImage()` 返回 `string \| Resource`，SVG返回占位图 |
| `entry/src/main/ets/pages/BrowseHistoryPage.ets` | `getDisplayImage()` SVG返回占位图 |
| `entry/src/main/ets/widget/WidgetDataProvider.ets` | `getDisplayImage()` SVG返回空字符串；`this.getDisplayImage()` → `WidgetDataProvider.getDisplayImage()` |
| `server/scripts/seed-direct.js` | 种子数据图片URL从 `.svg` 改为 `.png` |

### 数据库变更

- 20条种子商品图片从SVG替换为PNG占位图（已上传OBS并更新数据库）
- 删除3条错误测试数据（images为 `["img1.jpg","img2.jpg"]`）
- 删除2条空图片测试数据

### OBS上传修复方案

1. PhotoViewPicker 返回 `file://media/Photo/xxx` 格式URI
2. `copyToSandbox()` 使用 `fs.copyFileSync()` 将媒体文件拷贝到 `context.cacheDir`
3. 从沙箱路径读取文件内容并上传到OBS
4. 上传完成后 `fs.unlinkSync()` 清理临时文件
5. 非媒体URI（如沙箱路径）直接读取上传

---

## 待办事项

- [x] 配置OBS环境变量（AK/SK/Endpoint/Bucket）
- [x] 种子数据填充（20条商品）
- [x] 端到端API联调测试（26/26通过）
- [x] OBS图片上传修复（媒体URI拷贝到沙箱+签名URL上传）
- [x] 种子数据SVG→PNG替换
- [x] 图片显示重构（ImageDisplayUtil统一处理+SVG过滤）
- [x] 库存为0时购买按钮禁用
- [x] WidgetDataProvider `this` → 类名调用修复
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

---

## V11：实时聊天功能

**完成日期**：2026-06-16

### 新增功能
- 后端聊天服务（ChatService + Chat HTTP路由 + WebSocket服务）
- 前端WebSocket客户端（WsChatService单例，心跳+自动重连+消息分发）
- 会话管理：创建/获取会话、会话列表、未读计数
- 消息收发：HTTP发送 + WebSocket实时推送
- 标记已读、离线消息拉取
- 商品详情页"联系卖家"对接后端API

### 文件变更

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | `server/src/services/ChatService.ts` | 聊天业务逻辑（会话管理+消息收发+已读标记+WS推送） |
| 新建 | `server/src/routes/chat.ts` | 聊天HTTP路由（5个REST接口） |
| 新建 | `server/src/websocket/WsChatServer.ts` | WebSocket服务（连接管理+Token认证+心跳+消息推送） |
| 修改 | `server/src/index.ts` | 注册chat路由+WebSocket服务 |
| 新建 | `entry/src/main/ets/services/WsChatService.ets` | WebSocket客户端（连接管理+心跳+自动重连+消息分发） |
| 新建 | `entry/src/main/ets/views/message/ConversationItem.ets` | 会话列表项组件 |
| 修改 | `entry/src/main/ets/models/Message.ets` | 新增WsMessageType/WsConnectionState/WsMessage/PagedMessages/ConversationItem |
| 修改 | `entry/src/main/ets/constants/AppConstants.ets` | 新增WS_URL/WS_PING_INTERVAL/WS_RECONNECT_DELAYS/CHAT_PAGE_SIZE |
| 修改 | `entry/src/main/ets/router/RouterManager.ets` | toChat方法增加productTitle/productImage/targetUserAvatar参数 |
| 修改 | `entry/src/main/ets/services/AuthManager.ets` | 登录/退出/启动时管理WS连接 |
| 修改 | `entry/src/main/ets/repository/MessageRepository.ets` | 从Mock改为HTTP API调用+WS消息监听 |
| 修改 | `entry/src/main/ets/pages/Index.ets` | MessagePageView对接真实API+WS实时更新+下拉刷新 |
| 修改 | `entry/src/main/ets/pages/ChatPage.ets` | 全面对接后端+WS实时消息+分页加载+安全区域+键盘适配+动画 |
| 修改 | `entry/src/main/ets/pages/ProductDetailPage.ets` | "联系卖家"改为调用后端API创建会话 |

### 待办事项更新
- [x] T1-T17 聊天功能编码任务全部完成
- [ ] T18 集成测试与验证（需DevEco Studio编译+真机测试）
- [ ] 前端DevEco Studio编译验证

---

## V11.1：Bug修复与功能完善

**完成日期**：2026-06-16

### 修复内容

| # | 问题 | 修复 | 文件 |
|---|------|------|------|
| 1 | 商品详情页弹窗被商品内容遮挡 | Column改为Stack布局，弹窗覆盖在内容之上 | `ProductDetailPage.ets` |
| 2 | 个人中心统计数据为静态mock值 | 新增`GET /stats` API，前端`loadUserStats()`从API获取 | `userAuth.ts` + `Index.ets` |
| 3 | 卖家不能联系自己 | isOwner判断隐藏"联系卖家"按钮 | `ProductDetailPage.ets` |
| 4 | 卖家不能购买自己商品 | isOwner判断禁用"立即购买"按钮 | `ProductDetailPage.ets` |
| 5 | 商品详情页位置信息改为碳减排/碳积分 | 显示SKU的carbonReduction和carbonCredits | `ProductDetailPage.ets` |
| 6 | 卖家头像不显示 | SQL JOIN users表实时获取sellerAvatar | `ProductService.ts` |
| 7 | WebSocket消息延迟 | 合并seq+data为单一payload（wsNewMessagePayload） | `WsChatService.ets` + `ChatPage.ets` + `Index.ets` |
| 8 | 消息已读但未读气泡不消失 | markAsRead后推送conversation_update | `ChatService.ts` + `WsChatServer.ts` |
| 9 | 不同商品创建不同聊天会话 | conversations表UNIQUE约束含product_id | `ChatService.ts` + `businessDatabase.ts` |
| 10 | 前端stats API路径错误 | `/auth/stats` → `/stats` | `Index.ets` |

### 后端新增API

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/v1/stats` | GET | 获取用户统计（productCount/soldCount/favoriteCount/browseCount），需JWT认证 |

### 后端API验证结果

- `GET /api/v1/stats` ✅ 返回 productCount=11, soldCount=4, favoriteCount=2, browseCount=18
- `GET /api/v1/browse-history` ✅ 返回 total=18
- 后端服务正常运行在 http://localhost:3001

---

## V12：图标替换 + 推荐引擎异步化 + Widget异步化 + 管理后台联调

**完成日期**：2026-06-17

### 图标替换

| 替换项 | 原始 | 替换为 | 文件 |
|--------|------|--------|------|
| 发布按钮中心图标 | `Image($r('app.media.ic_publish_icon'))` | `SymbolGlyph($r('sys.symbol.plus'))` | `Index.ets` |
| 搜索框放大镜 | `Image($r('app.media.ic_search'))` | `SymbolGlyph($r('sys.symbol.magnifyingglass'))` | `AISearchBar.ets` |
| Banner背景图 | `Image($r('app.media.startIcon'))` × 3 | 渐变色Column（3种绿色渐变） | `BannerView.ets` |
| 碳减排图标 | `Image($r('app.media.startIcon'))` × 2 | `SymbolGlyph($r('sys.symbol.leaf_fill'))` | `ProductDetailPage.ets` |

### 推荐引擎异步化

| 文件 | 变更 |
|------|------|
| `engine/RecommendationEngine.ets` | 全部方法改为 `async`；移除 `UserProfile`/`BehaviorRepository` 依赖；改用 `productRepository.fetchProducts()` 异步API；SPU模型替代Product模型 |

### Widget异步化

| 文件 | 变更 |
|------|------|
| `widget/WidgetDataProvider.ets` | 新增 `refreshCache()`/`refreshProductCache()`/`refreshCreditCache()` 异步方法；`getProductRecommendData()`/`getCreditOverviewData()` 改为从缓存读取；`refreshProductCache` 调用 `fetchProducts()` API；`refreshCreditCache` 调用 `/stats` API |
| `entryability/EntryAbility.ets` | 启动时调用 `WidgetDataProvider.refreshCache()` 预加载缓存 |

### 后端Stats API增强

| 文件 | 变更 |
|------|------|
| `server/src/routes/userAuth.ts` | `GET /stats` 新增 `creditBalance`/`totalEarned`/`creditLevel` 字段（从credit_accounts表查询） |

### 管理后台联调

| 文件 | 变更 |
|------|------|
| `admin/vite.config.ts` | 代理配置改为分别代理 `/api/v1`、`/api/admin`、`/api/auth` |
| `admin/src/api/index.ts` | baseURL 改为空字符串（使用完整路径） |
| `admin/src/api/auth.ts` | 请求路径 `/auth/*` → `/api/auth/*` |
| `admin/src/api/analytics.ts` | 请求路径 `/dashboard/*` → `/api/admin/dashboard/*`，`/analytics/*` → `/api/admin/*` |

### API集成测试结果

**15/15 全部通过**

| 接口 | 结果 |
|------|------|
| GET /captcha | PASS |
| POST /login | PASS |
| GET /products | PASS |
| GET /products/:id | PASS |
| GET /category-specs/1 | PASS |
| GET /products?keyword | PASS |
| GET /stats (含creditBalance/totalEarned/creditLevel) | PASS |
| GET /profile | PASS |
| GET /favorites | PASS |
| GET /browse-history | PASS |
| GET /chat/conversations | PASS |
| GET /orders/buyer | PASS |
| POST /obs/upload-credential | PASS |
| GET /stats (no auth=401) | PASS |
| POST /refresh | PASS |

### 待办事项更新
- [x] 替换 `ic_publish_icon.svg` 发布按钮中心图标 → SymbolGlyph plus
- [x] 替换 `ic_search.svg` 搜索框放大镜图标 → SymbolGlyph magnifyingglass
- [x] Banner占位图替换为渐变色背景
- [x] 商品详情页碳减排图标替换为SymbolGlyph leaf_fill
- [x] 推荐引擎异步化 — RecommendationEngine 改为异步API
- [x] Widget异步化 — WidgetDataProvider 改为异步API + 缓存机制
- [x] 后端Stats API增强（碳积分数据）
- [x] V6管理后台部署联调（API路径修正 + 代理配置）
- [x] API集成测试 15/15 通过
- [ ] 替换 `foreground.png`/`background.png`/`startIcon.png` APP 图标
- [ ] 前端DevEco Studio编译验证（需在IDE中编译）
- [ ] 真机/模拟器功能测试

---

## V12.1：Bug修复 + 功能完善

**完成日期**：2026-06-17

### 变更文件清单

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `entry/src/main/ets/components/BannerView.ets` | 修改 | 重写为从API获取在售商品数据展示，点击跳转详情 |
| `entry/src/main/ets/constants/AppConstants.ets` | 修改 | WS_URL → ws://115.190.158.215:3001/ws/chat |
| `entry/src/main/ets/pages/CreditCenterPage.ets` | 修改 | 快捷入口图标 → doc_text_fill/leaf_fill/gift_fill |
| `entry/src/main/ets/pages/Index.ets` | 修改 | 删除"碳积分中心"标题行；skuItem添加carbonReduction/carbonCredits |
| `entry/src/main/ets/pages/SettingsPage.ets` | 修改 | 全面重写：账号区+通用区+支持区+退出登录 |
| `entry/src/main/ets/services/HttpService.ets` | 修改 | BASE_URL → http://115.190.158.215:3001/api/v1 |
| `server/src/services/ProductService.ts` | 修改 | calculateCarbonCredits支持子分类精确匹配+大类平均值兜底 |
| `server/scripts/seed-carbon-credit.js` | 新增 | 插入60条carbon_credit_table种子数据 |
| `server/scripts/fix-carbon-credits.js` | 新增 | 更新已有SKU的碳积分数据 |

### 核心变更说明

1. **GradientDirection修复** — `BottomRight` → `RightBottom`
2. **碳积分为0根因修复** — carbon_credit_table为空 → 插入60条种子数据；后端支持子分类精确匹配；前端发布时传递carbonReduction/carbonCredits
3. **设置页重写** — 账号区(头像+修改密码)、通用区(通知/位置/缓存/语言)、支持区(协议/隐私/反馈/关于)、退出登录
4. **轮播图改为展示数据库商品** — BannerView从API获取在售商品，展示图片+标题+价格+卖家，点击跳转详情
5. **前端BASE_URL/WS_URL更新** — 指向云服务器 115.190.158.215:3001
6. **云服务器部署** — Ubuntu 22.04 + Node.js v20 + pm2 + 后端服务运行成功

### 云服务器信息

| 参数 | 值 |
|------|-----|
| IP | 115.190.158.215 |
| API地址 | http://115.190.158.215:3001/api/v1 |
| WebSocket | ws://115.190.158.215:3001/ws/chat |
| 后端路径 | /root/carbonLink/server |
| pm2进程名 | carbonlink |

### 待办事项更新
- [x] GradientDirection.BottomRight → RightBottom 修复
- [x] 碳积分中心快捷入口图标替换
- [x] 碳积分为0根因修复（种子数据+子分类匹配+前端传参）
- [x] 设置页全面重写
- [x] 轮播图改为展示数据库商品
- [x] 前端BASE_URL/WS_URL指向云服务器
- [x] 云服务器后端部署
- [ ] 服务器pm2 ecosystem.config.js守护进程配置
- [ ] 服务器防火墙开放3001端口
- [ ] 服务器碳积分种子数据重新插入
- [ ] 服务器fix-carbon-credits.js重新执行
- [ ] 前端DevEco Studio编译验证
- [ ] 真机/模拟器功能测试
- [ ] 轮播图功能验证

---

## V13：积分系统后端化

**完成日期**：2026-06-18

### 变更概述

将碳积分系统从前端本地内存实现（CreditEngine/CreditAccountRepository/CreditTransactionRepository 均为内存Map）迁移到后端API + SQLite持久化，实现积分数据跨设备同步和持久存储。

### 文件变更清单

| 文件路径 | 类型 | 变更说明 |
|----------|------|----------|
| `server/src/services/CreditService.ts` | 新增 | 完整积分服务：onTradeCompleted/onProductPublished/onDonation/onReform/onAchievementReward/transferCredits/onViolation/exchangeCredits/getAccount/getTransactions/getStats等 |
| `server/src/routes/credit.ts` | 新增 | 积分API路由（11个端点：GET /account, GET /transactions, GET /stats, POST /publish-reward, POST /trade-reward, POST /achievement-reward, POST /donation-reward, POST /reform-reward, POST /transfer, POST /exchange） |
| `server/src/index.ts` | 修改 | 注册credit路由 `/api/v1/credits` |
| `entry/src/main/ets/repository/CreditAccountRepository.ets` | 重写 | 从内存Map改为API调用（getAccount/getBalance/getStats），添加toLevel函数替代as UserLevel |
| `entry/src/main/ets/repository/CreditTransactionRepository.ets` | 重写 | 从内存数组改为API调用（getByUserId返回{list,total}），添加toTxType/toObjArr函数 |
| `entry/src/main/ets/engine/CreditEngine.ets` | 重写 | 所有方法改为async，调用后端API；移除未使用import；ExchangeResult类定义 |
| `entry/src/main/ets/engine/AchievementDetector.ets` | 重写 | 改为async，使用creditAccountRepository.getStats()；移除as number类型断言 |
| `entry/src/main/ets/pages/CreditMallPage.ets` | 修改 | aboutToAppear和doExchange改为async |
| `entry/src/main/ets/pages/CreditCenterPage.ets` | 修改 | loadCreditData改为async，使用getAccount+getStats |
| `entry/src/main/ets/pages/CreditLedgerPage.ets` | 修改 | loadTransactions和loadMore改为async |
| `entry/src/main/ets/pages/OrderCenterPage.ets` | 修改 | onTradeCompleted参数修复（0→order.carbonCredits）；router.getParams()类型安全修复 |

### 核心变更说明

1. **积分系统后端化** — CreditService.ts提供完整的积分增减逻辑，支持交易奖励(20%)、发布奖励(+10)、捐赠奖励(1.5x)、改造奖励(2x)、成就奖励、转账(10%手续费)、违规扣除(2x)、积分兑换
2. **前端API对接** — CreditAccountRepository/CreditTransactionRepository/CreditEngine全部改为async+API调用
3. **ArkTS兼容性修复** — 移除`as UserLevel`/`as CreditTransactionType`类型断言，改用toLevel/toTxType守卫函数；移除`as number`从object类型转换；router.getParams()类型安全修复
4. **后端路由Bug修复** — credit.ts中`(req as any).user.userId` → `(req as any).userId`（与userAuthMiddleware一致）
5. **云服务器部署** — 积分系统已部署到115.190.158.215:3001，API测试全部通过

### API测试结果

```
1. Captcha: OK
2. Login: OK
3. Credit Account: {"balance":150,"totalEarned":200,"totalSpent":50,"level":"环保达人"}
4. Credit Stats: {"balance":150,"totalEarned":200,"totalSpent":50,"level":"环保达人","todayEarned":0,"totalReduction":0,"tradeCount":0}
5. Transactions total: 0
6. Publish reward: OK +10
7. After publish: {"balance":160,"totalEarned":210,"totalSpent":50,"level":"环保达人"}
```

### 待办事项更新
- [x] 后端CreditService.ts积分服务
- [x] 后端credit.ts路由（11个API端点）
- [x] 前端CreditAccountRepository API对接
- [x] 前端CreditTransactionRepository API对接
- [x] 前端CreditEngine async化
- [x] 前端AchievementDetector async化
- [x] 前端页面async适配
- [x] ArkTS兼容性修复（类型断言/未使用import）
- [x] 后端路由Bug修复（user.userId → userId）
- [x] 云服务器部署+API测试
- [ ] 前端DevEco Studio编译验证
- [ ] 真机/模拟器功能测试
- [ ] 积分流水页面实际数据验证