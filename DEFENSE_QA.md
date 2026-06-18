# 碳易链（CarbonLink）答辩问题预测与代码定位

---

## Q1: 为什么选择 HarmonyOS NEXT 而不是 React Native / Flutter？

**回答要点**：
- HarmonyOS NEXT 是纯原生开发，ArkTS 类型安全，ArkUI 声明式范式性能最优
- 可直接调用 HarmonyOS 系统能力（分布式、卡片、安全沙箱）
- 校园场景适合华为手机用户群

**代码定位**：
- ArkUI 声明式UI范式：`entry/src/main/ets/pages/Index.ets` — 整个页面结构
- ArkTS 类型安全：`entry/src/main/ets/models/` — 所有模型类
- Stage Model 生命周期：`entry/src/main/ets/entryability/EntryAbility.ets`

---

## Q2: 碳积分是怎么计算的？数据来源是什么？

**回答要点**：
- 三维计算模型：商品类别 × 子类别 × 成色等级
- 碳减排量 = (minReduction + maxReduction) / 2 × conditionFactor
- 数据来源：参考了电子废弃物回收碳排放研究文献，不同品类有不同范围值
- 成色越好系数越高，因为延长了产品完整使用寿命

**代码定位**：
- 碳积分计算表：`entry/src/main/ets/config/CarbonCreditTable.ets` — calculate() 方法
- 成色系数：同文件 conditionFactor 映射
- 后端计算：`server/src/services/ProductService.ts:281` — calculateCarbonCredits()
- 前端调用入口：`entry/src/main/ets/engine/CreditEngine.ets:14` — calculateProductCredits()

---

## Q3: JWT双Token认证是怎么工作的？为什么不只用一个Token？

**回答要点**：
- 单Token方案：要么安全（短有效期，频繁登录）要么方便（长有效期，被盗风险高）
- 双Token方案：AccessToken短(2h)保安全，RefreshToken长(7d)保体验
- 无感刷新：AccessToken过期时用RefreshToken自动获取新Token对，用户无感知
- 登出时将Token加入黑名单，防止已泄露Token继续使用

**代码定位**：
- 后端Token生成：`server/src/services/UserAuthService.ts` — generateTokenPair()
- 后端认证中间件：`server/src/middleware/userAuth.ts` — userAuthMiddleware()
- 前端Token管理：`entry/src/main/ets/services/TokenManager.ets` — 存储和刷新
- 前端启动认证：`entry/src/main/ets/services/AuthManager.ets` — checkAuthOnStartup()
- Token黑名单：`server/src/services/UserAuthService.ts` — logout() 写入token_blacklist表

---

## Q4: WebSocket断连了怎么办？怎么保证消息不丢？

**回答要点**：
- 心跳机制：定时发送ping，3次无pong响应判定断连
- 重连策略：指数退避，避免服务器压力
- 消息不丢保障：消息持久化到SQLite数据库，重连后从API拉取历史消息
- WebSocket仅做实时推送，不依赖它做消息存储

**代码定位**：
- 前端WebSocket服务：`entry/src/main/ets/services/WsChatService.ets` — connect()/reconnect()
- 心跳检测：同文件 — startHeartbeat()，missedPongs计数
- 后端WebSocket处理：`server/src/index.ts` — wss.on('connection')
- 消息持久化：`server/src/services/ChatService.ts` — sendMessage() 事务写入

---

## Q5: 订单创建怎么保证数据一致性？比如库存扣减和订单创建必须同时成功？

**回答要点**：
- 使用SQLite数据库事务（db.transaction()）
- 事务内包含：插入订单 + SKU下架 + SPU状态更新 + 卖家计数+1
- 任一步骤失败则全部回滚
- 取消订单时事务恢复SKU和SPU状态

**代码定位**：
- 创建订单事务：`server/src/services/OrderService.ts:74-94` — db.transaction()
- 取消订单恢复库存：`server/src/services/OrderService.ts` — cancelOrder()
- 订单状态机：`entry/src/main/ets/pages/OrderCenterPage.ets` — 待付款→付款→发货→收货→完成

---

## Q6: 图片为什么直传OBS而不是经过后端中转？

**回答要点**：
- 后端中转：前端→后端→OBS，后端带宽压力大，上传速度受限于后端
- 直传方案：后端只生成签名URL(30分钟有效)，前端直接PUT到OBS
- 安全性：签名URL有时效，后端不暴露OBS密钥给前端
- 后端只存公开URL，不存敏感凭证

**代码定位**：
- 后端签名URL生成：`server/src/services/ObsService.ts` — generateUploadCredential()
- 前端直传OBS：`entry/src/main/ets/services/ObsService.ets` — uploadImage()
- 沙箱拷贝(media URI)：同文件 — copyToSandbox()
- 后端签名路由：`server/src/routes/obs.ts` — POST /upload-credential

---

## Q7: 轮播图推荐算法是怎么设计的？为什么这样设计权重？

**回答要点**：
- 公式：score = viewCount × 0.3 + favoriteCount × 2.0 + recency × 10
- viewCount权重低：浏览是被动行为，信号弱
- favoriteCount权重高：收藏是主动意愿，信号强
- recency权重最高：校园场景下新品时效性强，7天内的商品优先展示
- 每10秒刷新，保持推荐新鲜度

**代码定位**：
- 推荐评分：`entry/src/main/ets/components/BannerView.ets` — bannerScore()
- 时效性计算：同文件 — recency = max(0, 1 - age/7天)
- 排序逻辑：同文件 — loadBannerProducts() 冒泡排序
- 定时刷新：同文件 — setInterval(10000)

---

## Q8: 积分系统怎么防止重复发放？

**回答要点**：
- 每笔积分操作都有唯一的relatedId
- 写入前先查询是否已存在该relatedId的记录
- 例如：交易奖励用 trade_buyer_{orderId} 和 trade_seller_{orderId}
- 即使前端重复调用，后端也会去重

**代码定位**：
- 去重检查：`server/src/services/CreditService.ts` — existsByRelatedId()
- 交易奖励幂等：同文件 — onTradeCompleted() 中先检查再写入
- 各场景relatedId格式：同文件 — 如 `publish_{productId}`, `achievement_{id}`

---

## Q9: MVVM架构在项目中是怎么体现的？

**回答要点**：
- Model：数据模型层，定义数据结构（SPU, Order, CreditAccount等）
- ViewModel/Repository：数据仓库层，封装API调用和数据转换
- View：ArkUI声明式页面，只负责UI渲染和用户交互
- Engine：业务引擎层，封装核心业务逻辑（CreditEngine, AchievementDetector）
- 好处：UI和数据解耦，Repository可替换数据源（Mock→API）

**代码定位**：
- Model层：`entry/src/main/ets/models/` — SPU.ets, Order.ets, CreditAccount.ets
- Repository层：`entry/src/main/ets/repository/` — ProductRepository, OrderRepository, CreditAccountRepository
- Engine层：`entry/src/main/ets/engine/` — CreditEngine, AchievementDetector
- View层：`entry/src/main/ets/pages/` — Index.ets, ProductDetailPage.ets, OrderCenterPage.ets

---

## Q10: 密码安全是怎么做的？

**回答要点**：
- bcrypt哈希加密，salt rounds = 10
- 数据库不存明文密码，只存哈希值
- 登录时bcrypt.compare()比对
- 连续5次登录失败锁定账号15分钟
- 图形验证码防止暴力破解

**代码定位**：
- bcrypt注册加密：`server/src/services/UserAuthService.ts` — register() 中 bcrypt.hash()
- bcrypt登录比对：同文件 — login() 中 bcrypt.compare()
- 账号锁定：同文件 — checkAccountLock()，MAX_LOGIN_ATTEMPTS = 5
- 验证码：`server/src/routes/userAuth.ts` — GET /captcha (svg-captcha)

---

## Q11: 聊天会话是怎么设计的？同一对用户怎么区分不同商品的聊天？

**回答要点**：
- 会话表按 (user1_id, user2_id, product_id) 唯一标识
- 两个用户ID排序后存储（较小的为user1），保证同一对用户只有一种排列
- 不同商品 = 不同会话，因为买家可能对同一卖家的不同商品分别咨询
- 消息表存储完整聊天记录，支持文本和图片类型

**代码定位**：
- 会话创建/去重：`server/src/services/ChatService.ts` — findOrCreateConversation()
- 用户ID排序：同文件 — smallerId/largerId 逻辑
- 消息发送：同文件 — sendMessage() 事务写入
- 已读标记：同文件 — markAsRead()

---

## Q12: 前后端数据交互的ApiResponse格式为什么要这样设计？

**回答要点**：
- 统一响应格式：{code, message, data}
- code=0表示成功，非0表示各类错误
- data类型为 Record<string, string | number | object> | null
- ArkTS类型安全要求：不能用any/unknown，不能用Object大写类型
- 这导致后端返回数组时必须包装在对象中（如 {list: [...], total: 100}）

**代码定位**：
- ApiResponse类型定义：`entry/src/main/ets/services/HttpService.ets` — ApiResponse接口
- 后端统一响应：`server/src/routes/` — 所有路由都返回 {code, message, data}
- 数组包装：`server/src/routes/order.ts` — GET /buyer 返回 data为数组
- 前端类型转换：`entry/src/main/ets/repository/OrderRepository.ets` — object→数组中间转换

---

## Q13: 项目中遇到了哪些ArkTS限制？怎么解决的？

**回答要点**：
- 禁止any/unknown：所有变量必须显式类型
- 禁止Object.keys()：用for循环遍历替代
- 禁止as number从object转换：用typeof守卫函数（toNum/toStr/toLevel）
- 禁止Partial<T>：手动定义完整类型
- build()方法禁止let/for：用ForEach和@Builder替代
- 禁止未类型化对象字面量：定义class替代{}字面量

**代码定位**：
- 类型守卫函数：`entry/src/main/ets/repository/CreditAccountRepository.ets` — toNum()/toStr()/toLevel()
- 枚举转换：同文件 — toLevel() 替代 as UserLevel
- 对象字面量→类：`entry/src/main/ets/repository/CreditTransactionRepository.ets` — TransactionListResult类
- build()中用ForEach：`entry/src/main/ets/pages/Index.ets` — 所有列表渲染

---

## Q14: 碳积分等级为什么基于累计获得而不是当前余额？

**回答要点**：
- 基于余额：用户兑换商品后积分减少，等级下降，体验差
- 基于累计获得：等级只升不降，激励用户持续参与
- 类似游戏经验值系统：花完金币不会掉级
- 余额用于兑换，等级用于展示身份

**代码定位**：
- 等级计算：`server/src/services/CreditService.ts` — getLevelByTotalEarned()
- 等级阈值：`entry/src/main/ets/pages/CreditCenterPage.ets` — thresholds = [0, 100, 500, 2000, 5000]
- 等级枚举：`entry/src/main/ets/models/CreditAccount.ets` — UserLevel枚举

---

## Q15: 项目中用到了哪些设计模式？

**回答要点**：
- 单例模式：Repository层导出单例实例（creditAccountRepository, orderRepository）
- 观察者模式：@State/@Watch 装饰器，数据变化自动触发UI刷新
- 策略模式：碳积分计算中不同成色对应不同系数（conditionFactor策略）
- 工厂模式：mapOrder/mapSPU 函数将API数据转换为模型对象
- 中间件模式：Express的userAuthMiddleware，洋葱模型

**代码定位**：
- 单例：`entry/src/main/ets/repository/OrderRepository.ets:155` — export const orderRepository
- 观察者：`entry/src/main/ets/pages/Index.ets` — @State productCount 等
- 策略：`entry/src/main/ets/config/CarbonCreditTable.ets` — conditionFactor映射
- 工厂：`entry/src/main/ets/repository/OrderRepository.ets` — mapOrder()
- 中间件：`server/src/middleware/userAuth.ts` — userAuthMiddleware()