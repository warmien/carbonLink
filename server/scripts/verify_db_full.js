const Database = require('better-sqlite3');
const db = new Database('data/carbonlink.db');

console.log('=== 数据库完整性验证 ===');
console.log();

const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").all();
console.log('1. 表数量:', tables.length);
tables.forEach(t => console.log('   -', t.name));

const views = db.prepare("SELECT name FROM sqlite_master WHERE type='view' ORDER BY name").all();
console.log();
console.log('2. 视图数量:', views.length);
views.forEach(v => console.log('   -', v.name));

const indexes = db.prepare("SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%' ORDER BY name").all();
console.log();
console.log('3. 索引数量:', indexes.length);
indexes.forEach(i => console.log('   -', i.name));

const newTables = ['spu','spec_names','spec_values','sku','sku_spec_values','category_spec_names','attribute_names','category_attributes','product_attributes','inventory'];
console.log();
console.log('4. SPU/SKU新表验证:');
newTables.forEach(t => {
  const exists = tables.some(x => x.name === t);
  console.log('   -', t, ':', exists ? 'OK' : 'MISSING');
});

console.log();
console.log('5. 兼容视图v_products:');
try {
  const vData = db.prepare('SELECT COUNT(*) as c FROM v_products').get();
  console.log('   - 可查询: OK (记录数:', vData.c, ')');
} catch(e) {
  console.log('   - 可查询: FAIL', e.message);
}

console.log();
console.log('6. 种子数据验证:');
const specNameCount = db.prepare('SELECT COUNT(*) as c FROM spec_names').get();
console.log('   - 规格名:', specNameCount.c, '条');
const specValueCount = db.prepare('SELECT COUNT(*) as c FROM spec_values').get();
console.log('   - 规格值:', specValueCount.c, '条');
const catSpecCount = db.prepare('SELECT COUNT(*) as c FROM category_spec_names').get();
console.log('   - 分类-规格名关联:', catSpecCount.c, '条');
const attrNameCount = db.prepare('SELECT COUNT(*) as c FROM attribute_names').get();
console.log('   - 属性名:', attrNameCount.c, '条');
const catAttrCount = db.prepare('SELECT COUNT(*) as c FROM category_attributes').get();
console.log('   - 分类-属性关联:', catAttrCount.c, '条');

console.log();
console.log('7. 规格名详情:');
const specNames = db.prepare('SELECT * FROM spec_names ORDER BY sort_order').all();
specNames.forEach(sn => {
  const svCount = db.prepare('SELECT COUNT(*) as c FROM spec_values WHERE spec_name_id = ?').get(sn.id);
  console.log('   -', sn.name, '(id:'+sn.id+', 值数:'+svCount.c+')');
});

console.log();
console.log('8. 属性名详情:');
const attrNames = db.prepare('SELECT * FROM attribute_names ORDER BY sort_order').all();
attrNames.forEach(an => {
  console.log('   -', an.name, '(id:'+an.id+', 类型:'+an.input_type+')');
});

console.log();
console.log('9. 分类-规格名关联:');
const catSpecs = db.prepare('SELECT c.name as cat, sn.name as spec FROM category_spec_names csn JOIN categories c ON c.id=csn.category_id JOIN spec_names sn ON sn.id=csn.spec_name_id ORDER BY c.name, sn.sort_order').all();
catSpecs.forEach(r => console.log('   -', r.cat, '->', r.spec));

console.log();
console.log('10. 分类-属性关联:');
const catAttrs = db.prepare('SELECT c.name as cat, an.name as attr, ca.is_required as req FROM category_attributes ca JOIN categories c ON c.id=ca.category_id JOIN attribute_names an ON an.id=ca.attribute_name_id ORDER BY c.name, an.sort_order').all();
catAttrs.forEach(r => console.log('   -', r.cat, '->', r.attr, '(必填:', r.req ? '是' : '否', ')'));

console.log();
console.log('11. 外键约束:');
const fkStatus = db.pragma('foreign_keys');
console.log('   - foreign_keys:', fkStatus[0].foreign_keys ? '已启用' : '未启用');

console.log();
console.log('12. WAL模式:');
const journalMode = db.pragma('journal_mode');
console.log('   - journal_mode:', journalMode[0].journal_mode);

console.log();
console.log('13. SPU/SKU表结构验证:');
const spuCols = db.prepare("PRAGMA table_info(spu)").all();
console.log('   - spu表字段数:', spuCols.length);
spuCols.forEach(c => console.log('     ', c.name, c.type, c.pk ? 'PK' : '', c.notnull ? 'NOT NULL' : ''));

const skuCols = db.prepare("PRAGMA table_info(sku)").all();
console.log('   - sku表字段数:', skuCols.length);
skuCols.forEach(c => console.log('     ', c.name, c.type, c.pk ? 'PK' : '', c.notnull ? 'NOT NULL' : ''));

const invCols = db.prepare("PRAGMA table_info(inventory)").all();
console.log('   - inventory表字段数:', invCols.length);
invCols.forEach(c => console.log('     ', c.name, c.type, c.pk ? 'PK' : ''));

db.close();
console.log();
console.log('=== 验证完成 ===');