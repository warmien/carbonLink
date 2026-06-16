const Database = require('better-sqlite3');
const db = new Database('data/carbonlink.db');

console.log('=== 数据迁移功能验证 ===');
console.log();

const spuCount = db.prepare('SELECT COUNT(*) as c FROM spu').get();
const skuCount = db.prepare('SELECT COUNT(*) as c FROM sku').get();
const invCount = db.prepare('SELECT COUNT(*) as c FROM inventory').get();
console.log('1. 当前SPU/SKU数据:');
console.log('   - SPU:', spuCount.c, '条');
console.log('   - SKU:', skuCount.c, '条');
console.log('   - Inventory:', invCount.c, '条');

const productsCount = db.prepare('SELECT COUNT(*) as c FROM products').get();
console.log('   - Products(旧表):', productsCount.c, '条');

console.log();
console.log('2. 外键约束验证:');
const testSpuId = db.prepare('SELECT id FROM spu LIMIT 1').get();
if (testSpuId) {
  const relatedSkuCount = db.prepare('SELECT COUNT(*) as c FROM sku WHERE spu_id = ?').get(testSpuId.id);
  const relatedInvCount = db.prepare('SELECT COUNT(*) as c FROM inventory WHERE sku_id IN (SELECT id FROM sku WHERE spu_id = ?)').get(testSpuId.id);
  const relatedAttrCount = db.prepare('SELECT COUNT(*) as c FROM product_attributes WHERE spu_id = ?').get(testSpuId.id);
  const relatedSpecCount = db.prepare('SELECT COUNT(*) as c FROM sku_spec_values WHERE sku_id IN (SELECT id FROM sku WHERE spu_id = ?)').get(testSpuId.id);
  console.log('   - SPU', testSpuId.id, '关联:');
  console.log('     - SKU:', relatedSkuCount.c, '条');
  console.log('     - Inventory:', relatedInvCount.c, '条');
  console.log('     - Attributes:', relatedAttrCount.c, '条');
  console.log('     - SKU规格值:', relatedSpecCount.c, '条');
}

console.log();
console.log('3. 兼容视图v_products:');
try {
  const vData = db.prepare('SELECT * FROM v_products LIMIT 5').all();
  console.log('   - 查询成功，记录数:', vData.length);
  if (vData.length > 0) {
    console.log('   - 字段:', Object.keys(vData[0]).join(', '));
    console.log('   - 示例:', JSON.stringify(vData[0]).substring(0, 200));
  }
} catch(e) {
  console.log('   - 查询失败:', e.message);
}

console.log();
console.log('4. 库存防超卖验证:');
const inv = db.prepare('SELECT * FROM inventory LIMIT 1').get();
if (inv) {
  console.log('   - SKU:', inv.sku_id);
  console.log('   - total_stock:', inv.total_stock);
  console.log('   - available_stock:', inv.available_stock);
  console.log('   - locked_stock:', inv.locked_stock);
}

console.log();
console.log('5. SPU状态枚举验证:');
const statuses = db.prepare('SELECT status, COUNT(*) as c FROM spu GROUP BY status').all();
statuses.forEach(s => console.log('   -', s.status, ':', s.c, '条'));

console.log();
console.log('6. SKU规格值详情:');
const skuSpecs = db.prepare('SELECT k.id as sku_id, k.price, sv.value as spec_value FROM sku k JOIN sku_spec_values ssv ON ssv.sku_id = k.id JOIN spec_values sv ON sv.id = ssv.spec_value_id LIMIT 10').all();
skuSpecs.forEach(s => console.log('   - SKU:', s.sku_id.substring(0,8) + '...', '价格:', s.price, '规格:', s.spec_value));

db.close();
console.log();
console.log('=== 验证完成 ===');