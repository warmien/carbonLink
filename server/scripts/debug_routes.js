const inventory = require('../dist/routes/inventory.js');
const migration = require('../dist/routes/migration.js');
const spec = require('../dist/routes/spec.js');

console.log('spec.default type:', typeof spec.default);
console.log('spec.default isRouter:', spec.default && spec.default.stack !== undefined);
console.log('inventory.default type:', typeof inventory.default);
console.log('inventory.default isRouter:', inventory.default && inventory.default.stack !== undefined);
console.log('migration.default type:', typeof migration.default);
console.log('migration.default isRouter:', migration.default && migration.default.stack !== undefined);

if (inventory.default && inventory.default.stack) {
  console.log('inventory routes:', inventory.default.stack.length);
  inventory.default.stack.forEach(l => {
    if (l.route) console.log('  -', Object.keys(l.route.methods).join(',').toUpperCase(), l.route.path);
  });
}

if (migration.default && migration.default.stack) {
  console.log('migration routes:', migration.default.stack.length);
  migration.default.stack.forEach(l => {
    if (l.route) console.log('  -', Object.keys(l.route.methods).join(',').toUpperCase(), l.route.path);
  });
}