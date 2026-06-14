const http = require('http');

function request(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3001,
      path: path,
      method: method,
      headers: { 'Content-Type': 'application/json' }
    };
    if (token) options.headers['Authorization'] = 'Bearer ' + token;
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch (e) { reject(e); }
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function test() {
  let passed = 0, failed = 0;

  function check(name, condition) {
    if (condition) { console.log(`  PASS: ${name}`); passed++; }
    else { console.log(`  FAIL: ${name}`); failed++; }
  }

  console.log('=== 1. 验证码 ===');
  const captcha = await request('GET', '/api/v1/captcha');
  check('captcha code=0', captcha.code === 0);
  check('has captchaKey', !!captcha.data?.captchaKey);

  console.log('\n=== 2. 登录 ===');
  const login = await request('POST', '/api/v1/login', {
    phone: '13800000001',
    password: '123456',
    captchaKey: captcha.data.captchaKey,
    captchaValue: captcha.data.captchaText
  });
  check('login code=0', login.code === 0);
  check('has token', !!login.data?.token);
  check('has user info', !!login.data?.user?.id);
  const token = login.data?.token;

  console.log('\n=== 3. 商品列表 ===');
  const products = await request('GET', '/api/v1/products?page=1&pageSize=5');
  check('products code=0', products.code === 0);
  check('has list', products.data?.list?.length > 0);
  check('total >= 20', products.data?.total >= 20);

  console.log('\n=== 4. 商品详情 ===');
  const firstId = products.data?.list?.[0]?.id;
  if (firstId) {
    const detail = await request('GET', '/api/v1/products/' + firstId);
    check('detail code=0', detail.code === 0);
    check('has spu', !!detail.data?.spu);
    check('has skus', detail.data?.skus?.length > 0);
    check('images is array', Array.isArray(detail.data?.spu?.images));
  }

  console.log('\n=== 5. 分类过滤 ===');
  const digitalProducts = await request('GET', '/api/v1/products?categoryId=1&page=1&pageSize=3');
  check('digital products code=0', digitalProducts.code === 0);
  check('digital products found', digitalProducts.data?.total > 0);

  console.log('\n=== 6. 关键词搜索 ===');
  const searchResult = await request('GET', '/api/v1/products?keyword=iPhone&page=1&pageSize=3');
  check('search code=0', searchResult.code === 0);
  check('search found', searchResult.data?.total > 0);

  console.log('\n=== 7. 用户Profile (需认证) ===');
  const profile = await request('GET', '/api/v1/profile', null, token);
  check('profile code=0', profile.code === 0);
  check('has user id', !!profile.data?.id);

  console.log('\n=== 8. OBS上传凭证 ===');
  const obs = await request('POST', '/api/v1/obs/upload-credential', { fileName: 'test.jpg', contentType: 'image/jpeg' }, token);
  check('obs code=0', obs.code === 0);
  check('has uploadUrl', !!obs.data?.uploadUrl);
  check('has publicUrl', !!obs.data?.publicUrl);

  console.log('\n=== 9. 收藏列表 ===');
  const favs = await request('GET', '/api/v1/favorites?page=1&pageSize=5', null, token);
  check('favorites code=0', favs.code === 0);

  console.log('\n=== 10. 健康检查 ===');
  const health = await request('GET', '/api/health');
  check('health ok', health.status === 'ok');

  console.log('\n=== 11. 分类规格 ===');
  const specs = await request('GET', '/api/v1/category-specs/1');
  check('specs code=0', specs.code === 0);

  console.log('\n=== 12. 我的发布 ===');
  const myProducts = await request('GET', '/api/v1/products?sellerId=u_test_001&page=1&pageSize=5', null, token);
  check('my products code=0', myProducts.code === 0);
  check('my products found', myProducts.data?.total > 0);

  console.log(`\n========== RESULTS: ${passed} passed, ${failed} failed ==========`);
}

test().catch(e => console.error('Test error:', e.message));
