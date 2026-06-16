-- CarbonLink 业务数据库初始化脚本
-- 数据库: carbonlink.db
-- 用法: sqlite3 carbonlink.db < init.sql

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ========== 用户表 ==========
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    phone TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    nickname TEXT NOT NULL,
    avatar TEXT DEFAULT '',
    gender TEXT DEFAULT '',
    bio TEXT DEFAULT '',
    credit_score INTEGER DEFAULT 100,
    credit_level TEXT DEFAULT '良好',
    product_count INTEGER DEFAULT 0,
    sold_count INTEGER DEFAULT 0,
    follower_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    join_date TEXT NOT NULL,
    location TEXT DEFAULT '',
    status TEXT DEFAULT 'active',
    lock_until INTEGER DEFAULT 0,
    login_fail_count INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- ========== 商品表 ==========
CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    price REAL NOT NULL,
    original_price REAL DEFAULT 0,
    images TEXT DEFAULT '[]',
    category TEXT NOT NULL,
    sub_category TEXT DEFAULT '',
    condition TEXT NOT NULL,
    carbon_reduction REAL DEFAULT 0,
    carbon_credits REAL DEFAULT 0,
    brand TEXT DEFAULT '',
    location TEXT DEFAULT '',
    distance TEXT DEFAULT '',
    seller_id TEXT NOT NULL,
    seller_name TEXT NOT NULL,
    seller_avatar TEXT DEFAULT '',
    view_count INTEGER DEFAULT 0,
    favorite_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'selling',
    tags TEXT DEFAULT '[]',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (seller_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category, status);
CREATE INDEX IF NOT EXISTS idx_products_seller ON products(seller_id);
CREATE INDEX IF NOT EXISTS idx_products_created ON products(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_products_search ON products(title, description);

-- ========== 订单表 ==========
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    product_id TEXT NOT NULL,
    product_title TEXT NOT NULL,
    product_image TEXT DEFAULT '',
    price REAL NOT NULL,
    buyer_id TEXT NOT NULL,
    seller_id TEXT NOT NULL,
    buyer_name TEXT NOT NULL,
    seller_name TEXT NOT NULL,
    status TEXT DEFAULT 'pending_payment',
    created_at INTEGER NOT NULL,
    paid_at INTEGER DEFAULT 0,
    shipped_at INTEGER DEFAULT 0,
    received_at INTEGER DEFAULT 0,
    completed_at INTEGER DEFAULT 0,
    shipping_method TEXT DEFAULT '',
    tracking_number TEXT DEFAULT '',
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (seller_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_orders_buyer ON orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_orders_seller ON orders(seller_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_product ON orders(product_id);

-- ========== 会话表 ==========
CREATE TABLE IF NOT EXISTS conversations (
    id TEXT PRIMARY KEY,
    user1_id TEXT NOT NULL,
    user2_id TEXT NOT NULL,
    target_user_id TEXT NOT NULL,
    target_user_name TEXT NOT NULL,
    target_user_avatar TEXT DEFAULT '',
    last_message TEXT DEFAULT '',
    last_message_time INTEGER DEFAULT 0,
    unread_count_user1 INTEGER DEFAULT 0,
    unread_count_user2 INTEGER DEFAULT 0,
    product_title TEXT DEFAULT '',
    product_image TEXT DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user1_id) REFERENCES users(id),
    FOREIGN KEY (user2_id) REFERENCES users(id),
    UNIQUE(user1_id, user2_id)
);
CREATE INDEX IF NOT EXISTS idx_conversations_user1 ON conversations(user1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user2 ON conversations(user2_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_time ON conversations(last_message_time DESC);

-- ========== 消息表 ==========
CREATE TABLE IF NOT EXISTS messages (
    id TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    sender_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    sender_avatar TEXT DEFAULT '',
    content TEXT DEFAULT '',
    msg_type TEXT DEFAULT 'text',
    image_url TEXT DEFAULT '',
    product_card TEXT DEFAULT '',
    timestamp INTEGER NOT NULL,
    is_read INTEGER DEFAULT 0,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id),
    FOREIGN KEY (sender_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(conversation_id, is_read);

-- ========== 碳积分账户表 ==========
CREATE TABLE IF NOT EXISTS credit_accounts (
    user_id TEXT PRIMARY KEY,
    balance REAL DEFAULT 0,
    total_earned REAL DEFAULT 0,
    total_spent REAL DEFAULT 0,
    level TEXT DEFAULT '环保新手',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ========== 碳积分流水表 ==========
CREATE TABLE IF NOT EXISTS credit_transactions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    type TEXT NOT NULL,
    amount REAL NOT NULL,
    balance_after REAL NOT NULL,
    related_id TEXT DEFAULT '',
    carbon_reduction REAL DEFAULT 0,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user ON credit_transactions(user_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_type ON credit_transactions(type);

-- ========== 收藏表 ==========
CREATE TABLE IF NOT EXISTS favorites (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE(user_id, product_id)
);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_product ON favorites(product_id);

-- ========== 验证码记录表 ==========
CREATE TABLE IF NOT EXISTS captcha_records (
    id TEXT PRIMARY KEY,
    captcha_key TEXT UNIQUE NOT NULL,
    captcha_value TEXT NOT NULL,
    type TEXT NOT NULL,
    phone TEXT DEFAULT '',
    expires_at INTEGER NOT NULL,
    used INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_captcha_key ON captcha_records(captcha_key);
CREATE INDEX IF NOT EXISTS idx_captcha_expires ON captcha_records(expires_at);

-- ========== Token黑名单表 ==========
CREATE TABLE IF NOT EXISTS token_blacklist (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token_jti TEXT UNIQUE NOT NULL,
    expires_at INTEGER NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_token_blacklist_jti ON token_blacklist(token_jti);

-- ========== 分类表 ==========
CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    icon TEXT DEFAULT '',
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_categories_sort ON categories(sort_order);

-- ========== 子分类表 ==========
CREATE TABLE IF NOT EXISTS sub_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parent_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE(parent_id, name)
);
CREATE INDEX IF NOT EXISTS idx_sub_categories_parent ON sub_categories(parent_id, sort_order);

-- ========== 积分商城商品表 ==========
CREATE TABLE IF NOT EXISTS mall_products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    image TEXT DEFAULT '',
    required_credits REAL NOT NULL,
    stock INTEGER NOT NULL,
    description TEXT DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- ========== 兑换记录表 ==========
CREATE TABLE IF NOT EXISTS exchange_records (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    credits_spent REAL NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES mall_products(id)
);
CREATE INDEX IF NOT EXISTS idx_exchange_records_user ON exchange_records(user_id);

-- ========== 环保成就表 ==========
CREATE TABLE IF NOT EXISTS eco_achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    icon TEXT DEFAULT '',
    target_value REAL NOT NULL,
    reward_credits REAL NOT NULL,
    created_at INTEGER NOT NULL
);

-- ========== 用户成就表 ==========
CREATE TABLE IF NOT EXISTS user_achievements (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    achievement_id TEXT NOT NULL,
    unlocked INTEGER DEFAULT 0,
    progress REAL DEFAULT 0,
    unlocked_at INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (achievement_id) REFERENCES eco_achievements(id),
    UNIQUE(user_id, achievement_id)
);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);

-- ========== 用户行为表 ==========
CREATE TABLE IF NOT EXISTS user_behaviors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    behavior_type TEXT NOT NULL,
    target_id TEXT NOT NULL,
    target_category TEXT DEFAULT '',
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_behaviors_user ON user_behaviors(user_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_behaviors_type ON user_behaviors(behavior_type);

-- ========== 用户画像表 ==========
CREATE TABLE IF NOT EXISTS user_profiles (
    user_id TEXT PRIMARY KEY,
    preferred_categories TEXT DEFAULT '[]',
    price_range_preference TEXT DEFAULT '{"min":0,"max":99999}',
    condition_preference TEXT DEFAULT '[]',
    last_updated INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ========== 碳积分核算表 ==========
CREATE TABLE IF NOT EXISTS carbon_credit_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL,
    name TEXT NOT NULL,
    min_reduction REAL NOT NULL,
    max_reduction REAL NOT NULL,
    min_credits REAL NOT NULL,
    max_credits REAL NOT NULL,
    UNIQUE(category, name)
);
CREATE INDEX IF NOT EXISTS idx_carbon_credit_category ON carbon_credit_table(category);

-- ========== 成色系数表 ==========
CREATE TABLE IF NOT EXISTS condition_factors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    factor REAL NOT NULL
);