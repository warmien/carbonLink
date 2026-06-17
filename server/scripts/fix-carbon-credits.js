const Database = require('better-sqlite3');
const db = new Database('C:/Users/warminen/DevEcoStudioProjects/CarbonLink/server/data/carbonlink.db');

const skus = db.prepare(`
  SELECT k.id, k.condition, k.carbon_reduction, k.carbon_credits, s.category_id, s.sub_category_id
  FROM sku k JOIN spu s ON k.spu_id = s.id
`).all();

const categories = {};
const catRows = db.prepare('SELECT id, name FROM categories').all();
catRows.forEach(r => { categories[r.id] = r.name; });

const subCategories = {};
const subCatRows = db.prepare('SELECT id, name FROM sub_categories').all();
subCatRows.forEach(r => { subCategories[r.id] = r.name; });

const carbonTable = db.prepare('SELECT category, name, min_reduction, max_reduction, min_credits, max_credits FROM carbon_credit_table').all();
const conditionFactors = db.prepare('SELECT name, factor FROM condition_factors').all();
const factorMap = {};
conditionFactors.forEach(r => { factorMap[r.name] = r.factor; });

function calculate(categoryId, condition, subCategoryId) {
  const catName = categories[categoryId];
  if (!catName) return { carbonReduction: 0, carbonCredits: 0 };

  let row = null;
  if (subCategoryId && subCategories[subCategoryId]) {
    const subName = subCategories[subCategoryId];
    row = carbonTable.find(r => r.category === catName && r.name === subName);
  }

  if (!row) {
    const rows = carbonTable.filter(r => r.category === catName);
    if (rows.length === 0) return { carbonReduction: 0, carbonCredits: 0 };
    const avgMinR = rows.reduce((s, r) => s + r.min_reduction, 0) / rows.length;
    const avgMaxR = rows.reduce((s, r) => s + r.max_reduction, 0) / rows.length;
    const avgMinC = rows.reduce((s, r) => s + r.min_credits, 0) / rows.length;
    const avgMaxC = rows.reduce((s, r) => s + r.max_credits, 0) / rows.length;
    row = { min_reduction: avgMinR, max_reduction: avgMaxR, min_credits: avgMinC, max_credits: avgMaxC };
  }

  const factor = factorMap[condition] || 0.5;
  const avgR = (row.min_reduction + row.max_reduction) / 2;
  const avgC = (row.min_credits + row.max_credits) / 2;
  return {
    carbonReduction: Math.round(avgR * factor * 100) / 100,
    carbonCredits: Math.round(avgC * factor * 100) / 100
  };
}

const update = db.prepare('UPDATE sku SET carbon_reduction = ?, carbon_credits = ? WHERE id = ?');

const tx = db.transaction(() => {
  let updated = 0;
  for (const sku of skus) {
    const c = calculate(sku.category_id, sku.condition, sku.sub_category_id);
    if (c.carbonReduction !== sku.carbon_reduction || c.carbonCredits !== sku.carbon_credits) {
      update.run(c.carbonReduction, c.carbonCredits, sku.id);
      updated++;
    }
  }
  return updated;
});

const count = tx();
console.log('Updated ' + count + ' SKUs with carbon credits');

const verify = db.prepare(`
  SELECT k.id, s.title, k.condition, k.carbon_reduction, k.carbon_credits
  FROM sku k JOIN spu s ON k.spu_id = s.id
  LIMIT 10
`).all();
verify.forEach(r => console.log(r.title + ' (' + r.condition + '): reduction=' + r.carbon_reduction + ' credits=' + r.carbon_credits));

db.close();