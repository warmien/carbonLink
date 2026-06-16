const db = require('better-sqlite3')('C:/Users/warminen/DevEcoStudioProjects/CarbonLink/server/data/carbonlink.db');
console.log('=== favorites table ===');
db.prepare("PRAGMA table_info(favorites)").all().forEach(col => console.log(col.name, col.type));
console.log('count:', db.prepare("SELECT COUNT(*) as c FROM favorites").get().c);
db.prepare("SELECT * FROM favorites LIMIT 3").all().forEach(r => console.log(JSON.stringify(r)));

console.log('\n=== users table product_count/sold_count ===');
db.prepare("SELECT id, nickname, product_count, sold_count FROM users LIMIT 5").all().forEach(r => console.log(JSON.stringify(r)));

console.log('\n=== spu count by seller ===');
db.prepare("SELECT seller_id, COUNT(*) as c FROM spu WHERE status='on_sale' GROUP BY seller_id").all().forEach(r => console.log(JSON.stringify(r)));

console.log('\n=== sku sold count ===');
db.prepare("SELECT spu.seller_id, COUNT(*) as c FROM sku JOIN spu ON sku.spu_id=spu.id WHERE sku.status='sold' GROUP BY spu.seller_id").all().forEach(r => console.log(JSON.stringify(r)));

db.close();
