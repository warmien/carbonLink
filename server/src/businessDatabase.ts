import Database, { Database as DatabaseType } from 'better-sqlite3';
import bcrypt from 'bcryptjs';
import path from 'path';

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'data', 'carbonlink.db');

const db: DatabaseType = new Database(DB_PATH);

db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

db.exec(`
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

  CREATE TABLE IF NOT EXISTS favorites (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES spu(id),
    UNIQUE(user_id, product_id)
  );

  CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
  CREATE INDEX IF NOT EXISTS idx_favorites_product ON favorites(product_id);

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

  CREATE TABLE IF NOT EXISTS token_blacklist (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token_jti TEXT UNIQUE NOT NULL,
    expires_at INTEGER NOT NULL,
    created_at INTEGER NOT NULL
  );

  CREATE INDEX IF NOT EXISTS idx_token_blacklist_jti ON token_blacklist(token_jti);

  CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    icon TEXT DEFAULT '',
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );

  CREATE INDEX IF NOT EXISTS idx_categories_sort ON categories(sort_order);

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

  CREATE TABLE IF NOT EXISTS eco_achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    icon TEXT DEFAULT '',
    target_value REAL NOT NULL,
    reward_credits REAL NOT NULL,
    created_at INTEGER NOT NULL
  );

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

  CREATE TABLE IF NOT EXISTS user_profiles (
    user_id TEXT PRIMARY KEY,
    preferred_categories TEXT DEFAULT '[]',
    price_range_preference TEXT DEFAULT '{"min":0,"max":99999}',
    condition_preference TEXT DEFAULT '[]',
    last_updated INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
  );

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

  CREATE TABLE IF NOT EXISTS condition_factors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    factor REAL NOT NULL
  );

  CREATE TABLE IF NOT EXISTS spu (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    images TEXT DEFAULT '[]',
    category_id INTEGER NOT NULL,
    sub_category_id INTEGER DEFAULT 0,
    brand TEXT DEFAULT '',
    seller_id TEXT NOT NULL,
    seller_name TEXT NOT NULL,
    seller_avatar TEXT DEFAULT '',
    location TEXT DEFAULT '',
    distance TEXT DEFAULT '',
    view_count INTEGER DEFAULT 0,
    favorite_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'on_sale' CHECK(status IN ('on_sale', 'off_sale', 'sold_out', 'deleted')),
    tags TEXT DEFAULT '[]',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (sub_category_id) REFERENCES sub_categories(id),
    FOREIGN KEY (seller_id) REFERENCES users(id)
  );

  CREATE INDEX IF NOT EXISTS idx_spu_status ON spu(status);
  CREATE INDEX IF NOT EXISTS idx_spu_category ON spu(category_id, status);
  CREATE INDEX IF NOT EXISTS idx_spu_sub_category ON spu(sub_category_id);
  CREATE INDEX IF NOT EXISTS idx_spu_seller ON spu(seller_id);
  CREATE INDEX IF NOT EXISTS idx_spu_created ON spu(created_at DESC);
  CREATE INDEX IF NOT EXISTS idx_spu_search ON spu(title, description);

  CREATE TABLE IF NOT EXISTS spec_names (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );

  CREATE INDEX IF NOT EXISTS idx_spec_names_sort ON spec_names(sort_order);

  CREATE TABLE IF NOT EXISTS spec_values (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    spec_name_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (spec_name_id) REFERENCES spec_names(id) ON DELETE CASCADE,
    UNIQUE(spec_name_id, value)
  );

  CREATE INDEX IF NOT EXISTS idx_spec_values_name ON spec_values(spec_name_id);

  CREATE TABLE IF NOT EXISTS sku (
    id TEXT PRIMARY KEY,
    spu_id TEXT NOT NULL,
    price REAL NOT NULL CHECK(price > 0),
    original_price REAL DEFAULT 0,
    condition TEXT NOT NULL,
    carbon_reduction REAL DEFAULT 0,
    carbon_credits REAL DEFAULT 0,
    status TEXT DEFAULT 'on_sale' CHECK(status IN ('on_sale', 'off_sale', 'sold_out')),
    sku_code TEXT DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (spu_id) REFERENCES spu(id) ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_sku_spu ON sku(spu_id);
  CREATE INDEX IF NOT EXISTS idx_sku_status ON sku(status);
  CREATE INDEX IF NOT EXISTS idx_sku_condition ON sku(condition);
  CREATE INDEX IF NOT EXISTS idx_sku_price ON sku(price);

  CREATE TABLE IF NOT EXISTS sku_spec_values (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku_id TEXT NOT NULL,
    spec_value_id INTEGER NOT NULL,
    FOREIGN KEY (sku_id) REFERENCES sku(id) ON DELETE CASCADE,
    FOREIGN KEY (spec_value_id) REFERENCES spec_values(id) ON DELETE CASCADE,
    UNIQUE(sku_id, spec_value_id)
  );

  CREATE INDEX IF NOT EXISTS idx_sku_spec_values_sku ON sku_spec_values(sku_id);

  CREATE TABLE IF NOT EXISTS category_spec_names (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    spec_name_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (spec_name_id) REFERENCES spec_names(id) ON DELETE CASCADE,
    UNIQUE(category_id, spec_name_id)
  );

  CREATE INDEX IF NOT EXISTS idx_category_spec_names_cat ON category_spec_names(category_id);

  CREATE TABLE IF NOT EXISTS attribute_names (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    input_type TEXT DEFAULT 'text' CHECK(input_type IN ('text', 'number', 'select')),
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );

  CREATE TABLE IF NOT EXISTS category_attributes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    attribute_name_id INTEGER NOT NULL,
    is_required INTEGER DEFAULT 0 CHECK(is_required IN (0, 1)),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_name_id) REFERENCES attribute_names(id) ON DELETE CASCADE,
    UNIQUE(category_id, attribute_name_id)
  );

  CREATE INDEX IF NOT EXISTS idx_category_attributes_cat ON category_attributes(category_id);

  CREATE TABLE IF NOT EXISTS product_attributes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    spu_id TEXT NOT NULL,
    attribute_name_id INTEGER NOT NULL,
    attribute_value TEXT DEFAULT '',
    FOREIGN KEY (spu_id) REFERENCES spu(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_name_id) REFERENCES attribute_names(id),
    UNIQUE(spu_id, attribute_name_id)
  );

  CREATE INDEX IF NOT EXISTS idx_product_attributes_spu ON product_attributes(spu_id);

  CREATE TABLE IF NOT EXISTS inventory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku_id TEXT UNIQUE NOT NULL,
    total_stock INTEGER DEFAULT 1,
    available_stock INTEGER DEFAULT 1 CHECK(available_stock >= 0),
    locked_stock INTEGER DEFAULT 0 CHECK(locked_stock >= 0),
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (sku_id) REFERENCES sku(id) ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_inventory_sku ON inventory(sku_id);

  CREATE VIEW IF NOT EXISTS v_products AS
    SELECT
      s.id, s.title, s.description, k.price, k.original_price, s.images,
      c.name AS category, sc.name AS sub_category, k.condition,
      k.carbon_reduction, k.carbon_credits, s.brand, s.location, s.distance,
      s.seller_id, s.seller_name, s.seller_avatar, s.view_count, s.favorite_count,
      CASE s.status
        WHEN 'on_sale' THEN 'selling'
        WHEN 'sold_out' THEN 'sold'
        WHEN 'off_sale' THEN 'removed'
        ELSE s.status
      END AS status,
      s.tags, s.created_at, s.updated_at
    FROM spu s
    JOIN sku k ON k.spu_id = s.id AND k.price = (
      SELECT MIN(k2.price) FROM sku k2 WHERE k2.spu_id = s.id
    )
    LEFT JOIN categories c ON c.id = s.category_id
    LEFT JOIN sub_categories sc ON sc.id = s.sub_category_id;
`);

const categoryCount = db.prepare('SELECT COUNT(*) as count FROM categories').get() as { count: number };
if (categoryCount.count === 0) {
  const now = Date.now();
  const insertCategory = db.prepare(
    'INSERT INTO categories (name, icon, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?)'
  );
  const insertSubCategory = db.prepare(
    'INSERT INTO sub_categories (parent_id, name, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?)'
  );

  const categories: [string, string[]][] = [
    ['电子数码', ['旧手机', '平板电脑', '蓝牙耳机', '有线耳机', '充电宝', '智能手表', '鼠标', '键盘', '显示器', '吹风机', '46级耳机', '46级收音机', '插座']],
    ['图书教材', ['书籍', '笔记本', '考研网课账号']],
    ['服装鞋帽', ['外套', '包', '帽子', '袜子类', '丝巾类']],
    ['家居生活', ['小电煮锅', '台灯', '散热架', '收纳用品', '开水瓶', '鞋架', '小风扇', '挂钩', '衣架', '体重秤', '小桌板', '手机支架', '小刀', '剪刀', '鞋子除臭喷雾']],
    ['美妆护肤', ['面部护肤类', '面膜类', '防晒类', '卸妆清洁类', '底妆类', '眼妆类', '唇妆类', '面部彩妆类', '美甲类', '身体洗护类', '身体护理类', '手部护理类', '头发洗护类', '美发造型类', '美发饰品类', '美妆工具类', '香水香氛类', '美妆收纳盒类', '化妆包类', '美妆家居类', '颈部配饰类', '耳部配饰类', '手部配饰类', '服饰配饰类', '美妆小家电类', '女士护理类']],
    ['运动户外', ['羽毛球', '羽毛球拍', '乒乓球', '乒乓球拍', '篮球', '跳绳', '自行车', '电动车', '健身卡', '水卡']],
    ['文具办公', ['文具', '计算器', '背书椅']],
    ['乐器文创', ['二手乐器', '文创产品', '绿植']],
    ['虚拟服务', ['考研网课账号', '健身卡', '水卡']],
    ['其他闲置', []]
  ];

  const insertAll = db.transaction(() => {
    for (let i = 0; i < categories.length; i++) {
      const catName = categories[i][0];
      const subs = categories[i][1];
      insertCategory.run(catName, '', i, now, now);
      const parentId = (db.prepare('SELECT last_insert_rowid() as id').get() as { id: number }).id;
      for (let j = 0; j < subs.length; j++) {
        insertSubCategory.run(parentId, subs[j], j, now, now);
      }
    }
  });
  insertAll();
}

const factorCount = db.prepare('SELECT COUNT(*) as count FROM condition_factors').get() as { count: number };
if (factorCount.count === 0) {
  const insertFactor = db.prepare('INSERT INTO condition_factors (name, factor) VALUES (?, ?)');
  const insertAllFactors = db.transaction(() => {
    insertFactor.run('A级-全新未用', 1.0);
    insertFactor.run('B级-99成新', 0.85);
    insertFactor.run('C级-95成新', 0.7);
    insertFactor.run('D级-9成新', 0.55);
    insertFactor.run('E级-8成新', 0.4);
    insertFactor.run('F级-7成新', 0.25);
  });
  insertAllFactors();
}


const specNameCount = db.prepare('SELECT COUNT(*) as count FROM spec_names').get() as { count: number };
if (specNameCount.count === 0) {
  const now = Date.now();
  const insertSpecName = db.prepare('INSERT INTO spec_names (name, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?)');
  const insertSpecValue = db.prepare('INSERT INTO spec_values (spec_name_id, value, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?)');
  const insertCategorySpecName = db.prepare('INSERT INTO category_spec_names (category_id, spec_name_id) VALUES (?, ?)');

  const insertAllSpecs = db.transaction(() => {
    const specNameIds: number[] = [];
    const specNames = ['成色', '容量', '版本', '颜色', '尺寸', '型号'];
    for (let i = 0; i < specNames.length; i++) {
      insertSpecName.run(specNames[i], i, now, now);
      const id = (db.prepare('SELECT last_insert_rowid() as id').get() as { id: number }).id;
      specNameIds.push(id);
    }

    const conditionValues = ['A级-全新未用', 'B级-99成新', 'C级-95成新', 'D级-9成新', 'E级-8成新', 'F级-7成新'];
    for (let i = 0; i < conditionValues.length; i++) {
      insertSpecValue.run(specNameIds[0], conditionValues[i], i, now, now);
    }

    const capacityValues = ['16G', '32G', '64G', '128G', '256G', '512G', '1T'];
    for (let i = 0; i < capacityValues.length; i++) {
      insertSpecValue.run(specNameIds[1], capacityValues[i], i, now, now);
    }

    insertCategorySpecName.run(1, specNameIds[0]);
    insertCategorySpecName.run(1, specNameIds[1]);
    insertCategorySpecName.run(1, specNameIds[2]);
    for (let i = 2; i <= 10; i++) {
      insertCategorySpecName.run(i, specNameIds[0]);
    }
  });
  insertAllSpecs();
  console.log('[CarbonLink] 已插入规格名/规格值初始数据');
}

const attributeNameCount = db.prepare('SELECT COUNT(*) as count FROM attribute_names').get() as { count: number };
if (attributeNameCount.count === 0) {
  const now = Date.now();
  const insertAttrName = db.prepare('INSERT INTO attribute_names (name, input_type, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?)');
  const insertCategoryAttr = db.prepare('INSERT INTO category_attributes (category_id, attribute_name_id, is_required) VALUES (?, ?, ?)');

  const insertAllAttrs = db.transaction(() => {
    const attrNameIds: number[] = [];
    const attrs: [string, string][] = [['品牌', 'text'], ['型号', 'text'], ['作者', 'text'], ['出版社', 'text'], ['ISBN', 'text']];
    for (let i = 0; i < attrs.length; i++) {
      insertAttrName.run(attrs[i][0], attrs[i][1], i, now, now);
      const id = (db.prepare('SELECT last_insert_rowid() as id').get() as { id: number }).id;
      attrNameIds.push(id);
    }

    insertCategoryAttr.run(1, attrNameIds[0], 1);
    insertCategoryAttr.run(1, attrNameIds[1], 0);
    insertCategoryAttr.run(2, attrNameIds[2], 0);
    insertCategoryAttr.run(2, attrNameIds[3], 0);
    insertCategoryAttr.run(2, attrNameIds[4], 0);
  });
  insertAllAttrs();
  console.log('[CarbonLink] 已插入属性名初始数据');
}

const userCount = db.prepare('SELECT COUNT(*) as count FROM users').get() as { count: number };
if (userCount.count === 0) {
  const now = Date.now();
  const bcrypt = require('bcryptjs');
  const insertUser = db.prepare(`
    INSERT INTO users (id, phone, password, nickname, avatar, gender, bio, credit_score, credit_level,
      product_count, sold_count, follower_count, following_count, join_date, location, status, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  const insertCreditAccount = db.prepare(`
    INSERT INTO credit_accounts (user_id, balance, total_earned, total_spent, level, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);
  const insertUserProfile = db.prepare(`
    INSERT INTO user_profiles (user_id, last_updated) VALUES (?, ?)
  `);

  const testUsers = [
    {
      id: 'u_test_001', phone: '13800000001', password: '123456', nickname: '测试用户小王',
      avatar: '', gender: 'male', bio: '热爱环保的校园达人', credit_score: 280, credit_level: '良好',
      product_count: 5, sold_count: 3, follower_count: 12, following_count: 8,
      join_date: '2026-01-15', location: '北京海淀', balance: 150, total_earned: 200, total_spent: 50, level: '环保达人'
    },
    {
      id: 'u_test_002', phone: '13800000002', password: '123456', nickname: '测试用户小李',
      avatar: '', gender: 'female', bio: '闲置物品循环利用', credit_score: 520, credit_level: '优秀',
      product_count: 12, sold_count: 8, follower_count: 35, following_count: 15,
      join_date: '2025-09-01', location: '上海杨浦', balance: 380, total_earned: 500, total_spent: 120, level: '环保先锋'
    },
    {
      id: 'u_test_003', phone: '13800000003', password: '123456', nickname: '测试用户小张',
      avatar: '', gender: 'male', bio: '低碳生活从我做起', credit_score: 100, credit_level: '一般',
      product_count: 2, sold_count: 1, follower_count: 3, following_count: 5,
      join_date: '2026-03-20', location: '广州天河', balance: 30, total_earned: 50, total_spent: 20, level: '环保新手'
    }
  ];

  const insertAllUsers = db.transaction(() => {
    for (const u of testUsers) {
      const hashedPassword = bcrypt.hashSync(u.password, 10);
      insertUser.run(u.id, u.phone, hashedPassword, u.nickname, u.avatar, u.gender, u.bio,
        u.credit_score, u.credit_level, u.product_count, u.sold_count, u.follower_count,
        u.following_count, u.join_date, u.location, 'active', now, now);
      insertCreditAccount.run(u.id, u.balance, u.total_earned, u.total_spent, u.level, now, now);
      insertUserProfile.run(u.id, now);
    }
  });
  insertAllUsers();
  console.log('[CarbonLink] 已插入3条测试用户数据');
}

try {
  const favFk = db.prepare("SELECT sql FROM sqlite_master WHERE type='table' AND name='favorites'").get() as { sql: string } | undefined;
  if (favFk && favFk.sql.indexOf('REFERENCES products') !== -1) {
    db.exec('DROP TABLE IF EXISTS favorites');
    db.exec(`
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES spu(id),
        UNIQUE(user_id, product_id)
      )
    `);
    db.exec('CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id)');
    db.exec('CREATE INDEX IF NOT EXISTS idx_favorites_product ON favorites(product_id)');
    console.log('[CarbonLink] favorites表外键已迁移: products -> spu');
  }
} catch (e) {
  console.log('[CarbonLink] favorites表迁移检查跳过:', (e as Error).message);
}

export default db;