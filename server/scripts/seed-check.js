const db = require('better-sqlite3')('C:/Users/warminen/DevEcoStudioProjects/CarbonLink/server/data/carbonlink.db');
const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").all();
console.log('Tables:', tables.map(t => t.name).join(', '));

try {
  const cats = db.prepare('SELECT id, name FROM categories ORDER BY id').all();
  console.log('Categories:', JSON.stringify(cats));
} catch(e) { console.log('No categories table'); }

try {
  const users = db.prepare('SELECT id, phone, nickname FROM users ORDER BY id').all();
  console.log('Users:', JSON.stringify(users));
} catch(e) { console.log('No users table'); }

try {
  const spuCount = db.prepare('SELECT COUNT(*) as c FROM spu').get();
  console.log('SPU count:', spuCount.c);
} catch(e) { console.log('No spu table'); }

db.close();
