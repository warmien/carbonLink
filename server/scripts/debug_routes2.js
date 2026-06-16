const express = require('express');
const cors = require('cors');
const userAuth = require('../dist/routes/userAuth');
const product = require('../dist/routes/product');
const spec = require('../dist/routes/spec');
const inventory = require('../dist/routes/inventory');
const migration = require('../dist/routes/migration');

const app = express();
app.use(cors({ origin: '*', methods: ['GET','POST','PUT','DELETE','OPTIONS'], allowedHeaders: ['Content-Type','Authorization'] }));
app.use(express.json());

app.use('/api/v1', userAuth.default);
app.use('/api/v1/products', product.default);
app.use('/api/v1/skus', product.skuRouter);
app.use('/api/v1', spec.default);
app.use('/api/v1', inventory.default);
app.use('/api/v1', migration.default);

function printRoutes(stack, prefix) {
  for (const layer of stack) {
    if (layer.route) {
      const methods = Object.keys(layer.route.methods).join(',').toUpperCase();
      console.log(methods, prefix + layer.route.path);
    } else if (layer.name === 'router' && layer.handle && layer.handle.stack) {
      printRoutes(layer.handle.stack, prefix);
    }
  }
}

console.log('\n=== All registered routes ===\n');
printRoutes(app._router.stack, '');

app.listen(3003, () => {
  console.log('\nTest server on port 3003');
  setTimeout(() => {
    const http = require('http');
    http.get('http://localhost:3003/api/v1/migration/status', r => {
      let d = '';
      r.on('data', c => d += c);
      r.on('end', () => console.log('\nmigration/status:', r.statusCode, d.substring(0, 150)));
    });
    http.get('http://localhost:3003/api/v1/inventory/test', r => {
      let d = '';
      r.on('data', c => d += c);
      r.on('end', () => console.log('inventory/test:', r.statusCode, d.substring(0, 150)));
    });
    http.get('http://localhost:3003/api/v1/spec-names', r => {
      let d = '';
      r.on('data', c => d += c);
      r.on('end', () => console.log('spec-names:', r.statusCode, d.substring(0, 100)));
    });
  }, 500);
});