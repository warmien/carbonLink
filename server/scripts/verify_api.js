const http = require('http');

function request(method, path, data, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3001,
      path: '/api/v1' + path,
      method: method,
      headers: { 'Content-Type': 'application/json' }
    };
    if (token) options.headers['Authorization'] = 'Bearer ' + token;

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', c => body += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, data: JSON.parse(body) }); }
        catch(e) { resolve({ status: res.statusCode, data: body }); }
      });
    });
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function main() {
  console.log('=== API端点验证 ===\n');
  let token = '';
  let spuId = '';
  let skuId = '';

  // 1. 验证码
  console.log('1. GET /captcha');
  let r = await request('GET', '/captcha');
  console.log('   status:', r.status, 'code:', r.data.code, 'captchaKey:', r.data.data ? r.data.data.captchaKey ? 'OK' : 'FAIL' : 'FAIL');

  // 2. 登录
  console.log('\n2. POST /login');
  const captchaResp = await request('GET', '/captcha');
  r = await request('POST', '/login', {
    phone: '13800000001', password: '123456',
    captchaKey: captchaResp.data.data.captchaKey,
    captchaValue: captchaResp.data.data.captchaText
  });
  token = r.data.data ? r.data.data.token : '';
  console.log('   status:', r.status, 'code:', r.data.code, 'token:', token ? 'OK' : 'FAIL');

  // 3. 规格名列表
  console.log('\n3. GET /spec-names');
  r = await request('GET', '/spec-names');
  console.log('   status:', r.status, 'code:', r.data.code, 'count:', r.data.data ? r.data.data.length : 0);

  // 4. 分类规格树
  console.log('\n4. GET /category-specs/1');
  r = await request('GET', '/category-specs/1');
  console.log('   status:', r.status, 'code:', r.data.code, 'specGroups:', r.data.data ? r.data.data.length : 0);
  if (r.data.data) r.data.data.forEach(g => console.log('   -', g.specName, ':', g.values.length, '个值'));

  // 5. 属性名列表
  console.log('\n5. GET /attribute-names');
  r = await request('GET', '/attribute-names');
  console.log('   status:', r.status, 'code:', r.data.code, 'count:', r.data.data ? r.data.data.length : 0);

  // 6. 分类属性
  console.log('\n6. GET /category-attributes/1');
  r = await request('GET', '/category-attributes/1');
  console.log('   status:', r.status, 'code:', r.data.code, 'count:', r.data.data ? r.data.data.length : 0);
  if (r.data.data) r.data.data.forEach(a => console.log('   -', a.attributeName, '(必填:', a.isRequired, ')'));

  // 7. 商品列表(空)
  console.log('\n7. GET /products');
  r = await request('GET', '/products');
  console.log('   status:', r.status, 'code:', r.data.code, 'total:', r.data.data ? r.data.data.total : 0);

  // 8. 发布商品
  console.log('\n8. POST /products (发布商品)');
  r = await request('POST', '/products', {
    title: 'iPhone 15 Pro 256GB',
    description: '去年11月购入，一直带壳使用',
    images: ['img1.jpg', 'img2.jpg'],
    categoryId: 1,
    subCategoryId: 1,
    brand: 'Apple',
    sellerId: 'u_test_001',
    sellerName: '测试用户小王',
    location: '深圳·南山区',
    distance: '1.2km',
    tags: ['iPhone', '5G'],
    attributes: [
      { attributeNameId: 1, value: 'Apple' },
      { attributeNameId: 2, value: 'iPhone 15 Pro' }
    ],
    skus: [
      { price: 6800, originalPrice: 8999, condition: 'B级-99成新', stock: 1, specValueIds: [2, 11] },
      { price: 5800, originalPrice: 8999, condition: 'C级-95成新', stock: 1, specValueIds: [3, 10] }
    ]
  }, token);
  console.log('   status:', r.status, 'code:', r.data.code);
  if (r.data.code === 0 && r.data.data) {
    spuId = r.data.data.spu.id;
    console.log('   spuId:', spuId);
    console.log('   skuCount:', r.data.data.skus.length);
    skuId = r.data.data.skus[0].id;
    console.log('   skuId[0]:', skuId);
    console.log('   attributes:', r.data.data.attributes.length);
    console.log('   minPrice:', r.data.data.spu.minPrice);
    console.log('   sku[0] specValues:', r.data.data.skus[0].specValues.length);
    console.log('   sku[1] specValues:', r.data.data.skus[1].specValues.length);
  }

  // 9. 商品列表(有数据)
  console.log('\n9. GET /products (有数据)');
  r = await request('GET', '/products');
  console.log('   status:', r.status, 'code:', r.data.code, 'total:', r.data.data ? r.data.data.total : 0);

  // 10. 商品详情
  console.log('\n10. GET /products/' + spuId);
  r = await request('GET', '/products/' + spuId);
  console.log('   status:', r.status, 'code:', r.data.code);
  if (r.data.code === 0 && r.data.data) {
    console.log('   spu.title:', r.data.data.spu.title);
    console.log('   spu.categoryName:', r.data.data.spu.categoryName);
    console.log('   spu.subCategoryName:', r.data.data.spu.subCategoryName);
    console.log('   spu.minPrice:', r.data.data.spu.minPrice);
    console.log('   skus:', r.data.data.skus.length);
    console.log('   attributes:', r.data.data.attributes.length);
    console.log('   viewCount:', r.data.data.spu.viewCount);
  }

  // 11. 更新SPU
  console.log('\n11. PUT /products/' + spuId);
  r = await request('PUT', '/products/' + spuId, { title: 'iPhone 15 Pro 256GB (已更新)' }, token);
  console.log('   status:', r.status, 'code:', r.data.code);
  if (r.data.code === 0 && r.data.data) console.log('   newTitle:', r.data.data.spu.title);

  // 12. 上下架
  console.log('\n12. PUT /products/' + spuId + '/status (下架)');
  r = await request('PUT', '/products/' + spuId + '/status', { status: 'off_sale' }, token);
  console.log('   status:', r.status, 'code:', r.data.code);

  console.log('\n13. PUT /products/' + spuId + '/status (上架)');
  r = await request('PUT', '/products/' + spuId + '/status', { status: 'on_sale' }, token);
  console.log('   status:', r.status, 'code:', r.data.code);

  // 14. 更新SKU
  console.log('\n14. PUT /skus/' + skuId);
  r = await request('PUT', '/skus/' + skuId, { price: 6500 }, token);
  console.log('   status:', r.status, 'code:', r.data.code);
  if (r.data.code === 0 && r.data.data) console.log('   newPrice:', r.data.data.price);

  // 15. 库存查询
  console.log('\n15. GET /inventory/' + skuId);
  r = await request('GET', '/inventory/' + skuId);
  console.log('   status:', r.status, 'code:', r.data.code);
  if (r.data.code === 0 && r.data.data) console.log('   availableStock:', r.data.data.availableStock);

  // 16. 库存锁定
  console.log('\n16. POST /inventory/lock');
  r = await request('POST', '/inventory/lock', { skuId: skuId, quantity: 1 }, token);
  console.log('   status:', r.status, 'code:', r.data.code, 'message:', r.data.message);

  // 17. 库存解锁
  console.log('\n17. POST /inventory/unlock');
  r = await request('POST', '/inventory/unlock', { skuId: skuId, quantity: 1 }, token);
  console.log('   status:', r.status, 'code:', r.data.code, 'message:', r.data.message);

  // 18. 迁移状态
  console.log('\n18. GET /migration/status');
  r = await request('GET', '/migration/status');
  console.log('   status:', r.status, 'code:', r.data.code);
  if (r.data.code === 0 && r.data.data) console.log('   migrated:', r.data.data.migrated, 'spuCount:', r.data.data.spuCount, 'skuCount:', r.data.data.skuCount);

  // 19. 分类筛选
  console.log('\n19. GET /products?categoryId=1');
  r = await request('GET', '/products?categoryId=1');
  console.log('   status:', r.status, 'code:', r.data.code, 'total:', r.data.data ? r.data.data.total : 0);

  // 20. 价格筛选
  console.log('\n20. GET /products?minPrice=6000&maxPrice=7000');
  r = await request('GET', '/products?minPrice=6000&maxPrice=7000');
  console.log('   status:', r.status, 'code:', r.data.code, 'total:', r.data.data ? r.data.data.total : 0);

  // 21. 删除商品
  console.log('\n21. DELETE /products/' + spuId);
  r = await request('DELETE', '/products/' + spuId, null, token);
  console.log('   status:', r.status, 'code:', r.data.code);

  // 22. 验证删除后列表
  console.log('\n22. GET /products (删除后)');
  r = await request('GET', '/products');
  console.log('   status:', r.status, 'code:', r.data.code, 'total:', r.data.data ? r.data.data.total : 0);

  console.log('\n=== API验证完成 ===');
}

main().catch(console.error);