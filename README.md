<div align="center">

# 🌿 碳易链 CarbonLink

**校园二手闲置交易平台 · HarmonyOS NEXT 原生应用**

*让闲置流转，让减碳发生*

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT%205.0-blue.svg)](https://developer.huawei.com/)
[![ArkTS](https://img.shields.io/badge/ArkTS-Stage%20Model-green.svg)](https://developer.huawei.com/)
[![Node.js](https://img.shields.io/badge/Node.js-v20.x-339933.svg)](https://nodejs.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 📖 项目简介

碳易链是一款基于 **HarmonyOS NEXT** 开发的校园二手闲置交易平台，核心理念是将二手交易与**碳减排**相结合。每笔交易不仅让闲置物品重新流转，还能量化其碳减排贡献，让用户在交易的同时践行绿色生活。

### ✨ 核心亮点

- 🤖 **AI 智能识别** — 拍照即识别商品，自动填充名称、分类、成色、建议售价
- 🌱 **碳积分体系** — 基于商品品类和成色自动核算碳减排量和碳积分
- 💬 **实时聊天** — WebSocket 驱动的即时通讯，买卖双方在线沟通
- 📱 **HarmonyOS 原生** — 纯 ArkTS + ArkUI 开发，流畅的原生体验
- ☁️ **云服务器部署** — 后端独立部署，支持多用户并发访问

---

## 🏗️ 技术架构

```
┌─────────────────────────────────────────────┐
│              HarmonyOS NEXT 客户端            │
│  ┌─────────┐ ┌──────────┐ ┌───────────────┐ │
│  │  ArkUI   │ │  ArkTS   │ │  Stage Model  │ │
│  │  声明式UI │ │  类型安全  │ │   应用模型     │ │
│  └─────────┘ └──────────┘ └───────────────┘ │
│  ┌─────────────────────────────────────────┐ │
│  │           MVVM 架构                      │ │
│  │  Model ← Repository ← ViewModel ← View │ │
│  └─────────────────────────────────────────┘ │
└────────────────────┬────────────────────────┘
                     │ HTTP / WebSocket
┌────────────────────▼────────────────────────┐
│              Node.js 后端服务                  │
│  ┌──────┐ ┌───────┐ ┌──────┐ ┌───────────┐ │
│  │Express│ │SQLite │ │ JWT  │ │ 华为云OBS  │ │
│  │  路由  │ │ 数据库 │ │ 认证  │ │  图片存储  │ │
│  └──────┘ └───────┘ └──────┘ └───────────┘ │
└─────────────────────────────────────────────┘
```

### 技术栈详情

| 层级 | 技术 | 说明 |
|------|------|------|
| 前端框架 | ArkTS + ArkUI | HarmonyOS NEXT 声明式开发框架 |
| 架构模式 | MVVM | Model-ViewModel-View 分层 |
| 网络请求 | @kit.NetworkKit | HarmonyOS 原生 HTTP 客户端 |
| 实时通信 | WebSocket | 聊天功能即时通讯 |
| 后端框架 | Express.js | Node.js Web 框架 |
| 数据库 | better-sqlite3 | 嵌入式 SQLite，零配置 |
| 认证方案 | JWT 双 Token | Access Token (2h) + Refresh Token (7d) |
| 图片存储 | 华为云 OBS | 对象存储服务，前端直传 |
| AI 服务 | 豆包 / 通义千问 | 商品识别、智能估价、描述生成 |

---

## 📱 功能展示

### 首页 & 商品浏览
- 轮播图展示热门商品
- 分类导航（10 大品类）
- 智能推荐商品列表
- 下拉刷新 & 关键词搜索

### AI 智能发布
- 拍照自动识别商品信息
- AI 自动填充：名称、分类、成色、描述、建议售价
- 碳减排量和碳积分自动核算
- 图片直传华为云 OBS

### 实时聊天
- WebSocket 即时通讯
- 消息已读/未读状态
- 商品卡片关联聊天
- 在线状态指示

### 碳积分体系
- A-F 六级成色 × 10 大品类碳减排核算
- 碳积分账户 & 流水记录
- 碳积分商城兑换
- 环保成就系统

### 个人中心
- 发布/售出/收藏/浏览统计
- 订单管理（待付款/待发货/待收货/已完成/已取消）
- 设置页（账号/通用/支持）

---

## 🚀 快速开始

### 环境要求

| 工具 | 版本要求 | 下载地址 |
|------|----------|----------|
| DevEco Studio | 5.0+ | [华为开发者联盟](https://developer.huawei.com/consumer/cn/deveco-studio/) |
| Node.js | v20.x | [Node.js 官网](https://nodejs.org/) |
| npm | 随 Node.js 安装 | — |

### 第一步：克隆项目

```bash
git clone https://github.com/warmien/carbonLink.git
cd carbonLink
git checkout public
```

### 第二步：配置后端

#### 2.1 安装后端依赖

```bash
cd server
npm install
```

> 💡 如果下载缓慢，使用国内镜像：`npm install --registry=https://registry.npmmirror.com`

#### 2.2 创建环境配置

复制示例配置文件并填写你的信息：

```bash
cp .env.example .env
```

编辑 `server/.env`，填入你的配置：

```env
# 服务器端口
PORT=3001

# JWT密钥（请修改为自己的随机字符串，越长越安全）
JWT_SECRET=your_jwt_secret_here
JWT_REFRESH_SECRET=your_refresh_secret_here

# 华为云OBS配置（用于图片存储）
# 注册华为云 → 开通OBS → 创建桶 → 获取AK/SK
OBS_ACCESS_KEY_ID=your_obs_access_key_id
OBS_SECRET_ACCESS_KEY=your_obs_secret_access_key
OBS_ENDPOINT=obs.cn-north-4.myhuaweicloud.com
OBS_BUCKET=your_bucket_name
```

> 📌 **华为云 OBS 配置指南**：
> 1. 注册 [华为云账号](https://www.huaweicloud.com/)
> 2. 进入「对象存储服务 OBS」，创建一个桶
> 3. 桶策略设为「公共读」（让图片可通过 URL 直接访问）
> 4. 在「我的凭证」中获取 Access Key ID 和 Secret Access Key

#### 2.3 初始化数据库

后端启动时会自动创建所有数据表，无需手动操作。

如需插入测试数据：

```bash
# 插入碳积分核算表（60条）
node scripts/seed-carbon-credit.js

# 插入测试商品（20条，需要OBS配置）
node scripts/seed-products-v2.js

# 更新SKU碳积分数据
node scripts/fix-carbon-credits.js
```

#### 2.4 启动后端

```bash
# 开发模式（推荐）
npx ts-node --transpile-only src/index.ts

# 或者用 pm2 守护进程（生产环境）
npm install -g pm2
pm2 start "npx ts-node --transpile-only src/index.ts" --name carbonlink
```

启动成功后会看到：

```
CarbonLink Server running on http://localhost:3001
  用户API: http://localhost:3001/api/v1/
  商品API: http://localhost:3001/api/v1/products
  ...
```

### 第三步：配置前端

#### 3.1 修改服务器地址

打开 `entry/src/main/ets/services/HttpService.ets`，将 `BASE_URL` 改为你的服务器地址：

```typescript
private static readonly BASE_URL: string = 'http://YOUR_SERVER_IP:3001/api/v1';
```

打开 `entry/src/main/ets/constants/AppConstants.ets`，将 `WS_URL` 改为你的服务器地址：

```typescript
static readonly WS_URL: string = 'ws://YOUR_SERVER_IP:3001/ws/chat';
```

> ⚠️ 如果使用模拟器测试，`YOUR_SERVER_IP` 可以用 `localhost` 或 `10.0.2.2`（Android模拟器）。
> 如果使用真机，需要填电脑的局域网 IP（如 `192.168.x.x`）。

#### 3.2 配置 AI 服务（可选）

打开 `entry/src/main/ets/constants/AiBackendConfig.ets`，填入你的 AI API Key：

```typescript
// 方案一：豆包（字节跳动）
static readonly DOUBAO_API_KEY: string = 'your_doubao_api_key';

// 方案二：通义千问（阿里云）
static readonly DASHSCOPE_API_KEY: string = 'your_dashscope_api_key';
```

> 💡 不配置 AI Key 不影响其他功能，仅 AI 识别/估价/描述功能不可用。

#### 3.3 编译运行

1. 用 DevEco Studio 打开项目根目录
2. 等待项目索引完成（首次可能需要几分钟）
3. 连接 HarmonyOS 真机或启动模拟器
4. 点击 ▶️ Run 运行

---

## ☁️ 云服务器部署

### 部署到 Linux 服务器（Ubuntu 示例）

#### 1. 服务器环境准备

```bash
# 安装 Node.js v20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 pm2 进程管理器
sudo npm install -g pm2

# 安装 ts-node（用于直接运行 TypeScript）
sudo npm install -g ts-node typescript
```

#### 2. 上传代码

```bash
# 在本地打包
cd server
tar -czf ../server-deploy.tar.gz --exclude=node_modules --exclude=data .

# 上传到服务器
scp ../server-deploy.tar.gz root@YOUR_SERVER_IP:/root/carbonLink/

# 在服务器上解压
ssh root@YOUR_SERVER_IP
cd /root/carbonLink
mkdir -p server
cd server
tar -xzf ../server-deploy.tar.gz
```

#### 3. 安装依赖 & 配置

```bash
cd /root/carbonLink/server
npm install --registry=https://registry.npmmirror.com
mkdir -p data

# 创建 .env 配置文件
cp .env.example .env
nano .env  # 填入你的配置
```

#### 4. 启动服务

```bash
# 用 pm2 启动（推荐）
pm2 start "npx ts-node --transpile-only src/index.ts" --name carbonlink

# 查看日志
pm2 logs carbonlink

# 设置开机自启
pm2 startup
pm2 save
```

#### 5. 开放防火墙端口

```bash
# 开放 3001 端口
sudo ufw allow 3001

# 如果是华为云 ECS，还需要在安全组中添加入方向规则：
# 协议: TCP | 端口: 3001 | 源地址: 0.0.0.0/0
```

#### 6. 验证部署

```bash
curl http://YOUR_SERVER_IP:3001/api/health
# 返回 {"status":"ok","timestamp":...} 即成功
```

---

## 📂 项目结构

```
CarbonLink/
├── entry/                          # HarmonyOS 前端应用
│   └── src/main/ets/
│       ├── pages/                  # 页面
│       │   ├── Index.ets           # 主页（首页/分类/发布/消息/我的）
│       │   ├── LoginPage.ets       # 登录页
│       │   ├── RegisterPage.ets    # 注册页
│       │   ├── ProductDetailPage.ets # 商品详情
│       │   ├── EditProductPage.ets # 发布/编辑商品
│       │   ├── ChatPage.ets        # 聊天页
│       │   ├── CreditCenterPage.ets# 碳积分中心
│       │   ├── SettingsPage.ets    # 设置页
│       │   └── ...
│       ├── components/             # 通用组件
│       │   ├── BannerView.ets      # 轮播图
│       │   ├── ProductCard.ets     # 商品卡片
│       │   ├── AISearchBar.ets     # AI搜索栏
│       │   └── ...
│       ├── models/                 # 数据模型
│       ├── repository/             # 数据仓库（API调用）
│       ├── services/               # 业务服务
│       ├── constants/              # 常量配置
│       ├── theme/                  # 主题样式
│       ├── router/                 # 路由管理
│       ├── engine/                 # 业务引擎（推荐/碳积分）
│       └── utils/                  # 工具类
│
├── server/                         # Node.js 后端
│   ├── src/
│   │   ├── index.ts                # 入口文件
│   │   ├── routes/                 # API 路由
│   │   │   ├── userAuth.ts         # 用户认证 API
│   │   │   ├── product.ts          # 商品 API
│   │   │   ├── chat.ts             # 聊天 API
│   │   │   ├── obs.ts              # OBS 上传 API
│   │   │   └── ...
│   │   ├── services/               # 业务逻辑
│   │   ├── middleware/             # 中间件（JWT/审计）
│   │   └── websocket/             # WebSocket 服务
│   ├── scripts/                    # 种子数据脚本
│   ├── .env.example                # 环境配置模板
│   └── package.json
│
└── admin/                          # 管理后台（Vue3）
    └── ...
```

---

## 🔑 API 接口一览

| 分类 | 接口 | 方法 | 说明 |
|------|------|------|------|
| 认证 | `/api/v1/captcha` | GET | 获取验证码 |
| 认证 | `/api/v1/login` | POST | 登录 |
| 认证 | `/api/v1/register` | POST | 注册 |
| 认证 | `/api/v1/refresh` | POST | 刷新 Token |
| 用户 | `/api/v1/profile` | GET | 获取个人信息 |
| 用户 | `/api/v1/stats` | GET | 获取统计数据 |
| 用户 | `/api/v1/phone-avatar` | GET | 根据手机号获取头像 |
| 商品 | `/api/v1/products` | GET | 商品列表 |
| 商品 | `/api/v1/products/:id` | GET | 商品详情 |
| 商品 | `/api/v1/products` | POST | 发布商品 |
| 收藏 | `/api/v1/favorites/toggle` | POST | 切换收藏 |
| 聊天 | `/api/v1/chat/conversations` | GET | 会话列表 |
| 聊天 | `/api/v1/chat/messages/:convId` | GET | 聊天记录 |
| OBS | `/api/v1/obs/upload-credential` | POST | 获取上传签名 |

---

## 🔒 安全设计

- **JWT 双 Token 认证** — Access Token (2小时) + Refresh Token (7天)
- **Token 黑名单** — 退出登录即时失效
- **账号锁定** — 连续5次密码错误锁定30分钟
- **bcrypt 密码加密** — 密码不可逆加密存储
- **验证码机制** — svg-captcha 图形验证码防暴力破解
- **OBS 签名上传** — 前端直传，后端签名，30分钟有效期

---

## 🧪 测试账号

| 手机号 | 密码 | 昵称 |
|--------|------|------|
| 13800000001 | 123456 | 测试用户小王 |
| 13800000002 | 123456 | 测试用户小李 |
| 13800000003 | 123456 | 测试用户小张 |

> ⚠️ 测试账号仅在种子数据初始化后可用。

---

## 📋 开发路线

- [x] **V1-V3** — 基础框架 + 核心功能 + AI集成
- [x] **V4-V6** — SPU/SKU重构 + 用户认证 + OBS图片 + 管理后台
- [x] **V7-V9** — 发布流程优化 + 碳积分体系 + 端到端联调
- [x] **V10-V11** — OBS修复 + 实时聊天 + Bug修复
- [x] **V12** — 图标替换 + 异步化 + 云服务器部署
- [x] **V12.1** — Bug修复 + 设置页重写 + 轮播图API化
- [x] **V12.2** — 登录页头像识别 + 游客模式修复 + 请求日志

---

## 📄 许可证

本项目仅用于学习和展示目的。

---

<div align="center">

**Made with 💚 by [warmien](https://github.com/warmien)**

</div>