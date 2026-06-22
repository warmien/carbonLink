const Database = require('better-sqlite3');
const db = new Database('./data/carbonlink.db');
db.prepare("ALTER TABLE conversations ADD COLUMN product_id TEXT NOT NULL DEFAULT ''").run();
console.log('Added product_id column');

// Update existing conversations with product_id from product_title
const convs = db.prepare('SELECT id, product_title FROM conversations').all();
const products = db.prepare('SELECT id, title FROM spu').all();
for (const conv of convs) {
  for (const p of products) {
    if (conv.product_title === p.title) {
      db.prepare('UPDATE conversations SET product_id = ? WHERE id = ?').run(p.id, conv.id);
      console.log(`Updated conv ${conv.id} with product_id ${p.id}`);
      break;
    }
  }
}
console.log('Migration complete');