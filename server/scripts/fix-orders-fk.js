const db = require('better-sqlite3')('C:/Users/warminen/DevEcoStudioProjects/CarbonLink/server/data/carbonlink.db');
db.pragma('foreign_keys = OFF');

db.exec('DROP TABLE IF EXISTS orders');

db.exec(`
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
    FOREIGN KEY (product_id) REFERENCES spu(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (seller_id) REFERENCES users(id)
  )
`);

db.exec('CREATE INDEX IF NOT EXISTS idx_orders_buyer ON orders(buyer_id)');
db.exec('CREATE INDEX IF NOT EXISTS idx_orders_seller ON orders(seller_id)');
db.exec('CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status)');
db.exec('CREATE INDEX IF NOT EXISTS idx_orders_product ON orders(product_id)');

db.pragma('foreign_keys = ON');

const info = db.prepare("PRAGMA foreign_key_list(orders)").all();
info.forEach(fk => console.log(`from: ${fk.from} -> table: ${fk.table} to: ${fk.to}`));
console.log('Orders table recreated successfully!');
db.close();