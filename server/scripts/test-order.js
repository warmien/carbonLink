const http = require('http');

function request(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost', port: 3001, path, method,
      headers: { 'Content-Type': 'application/json' }
    };
    if (token) options.headers['Authorization'] = 'Bearer ' + token;
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch (e) { reject(e); } });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function test() {
  // Login as buyer (user 2)
  const captcha = await request('GET', '/api/v1/captcha');
  const login = await request('POST', '/api/v1/login', {
    phone: '13800000002', password: '123456',
    captchaKey: captcha.data.captchaKey, captchaValue: captcha.data.captchaText
  });
  const token = login.data.token;
  console.log('1. Login OK');

  // Buy product (spu_seed_001 is owned by user 1)
  const buyResult = await request('POST', '/api/v1/orders', {
    spuId: 'spu_seed_001', paymentMethod: 'wechat'
  }, token);
  console.log('2. Buy result:', buyResult.code, buyResult.message);
  if (buyResult.data) {
    console.log('   Order ID:', buyResult.data.id);
    console.log('   Status:', buyResult.data.status);
    console.log('   Price:', buyResult.data.price);
  }

  // Check product status
  const product = await request('GET', '/api/v1/products/spu_seed_001');
  console.log('3. Product status after buy:', product.data?.spu?.status);

  // Try buying own product (should fail)
  const captcha2 = await request('GET', '/api/v1/captcha');
  const login2 = await request('POST', '/api/v1/login', {
    phone: '13800000001', password: '123456',
    captchaKey: captcha2.data.captchaKey, captchaValue: captcha2.data.captchaText
  });
  const token2 = login2.data.token;
  const buyOwn = await request('POST', '/api/v1/orders', {
    spuId: 'spu_seed_002', paymentMethod: 'wechat'
  }, token2);
  console.log('4. Buy own product:', buyOwn.code, buyOwn.message);

  // Check buyer orders
  const buyerOrders = await request('GET', '/api/v1/orders/buyer', null, token);
  console.log('5. Buyer orders count:', buyerOrders.data?.length);

  console.log('\nAll tests done!');
}

test().catch(e => console.error(e.message));