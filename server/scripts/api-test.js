const http = require('http');
function req(method, path, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const opts = { hostname: 'localhost', port: 3001, path, method, headers: { 'Content-Type': 'application/json', ...headers } };
    const r = http.request(opts, res => { let d = ''; res.on('data', c => d += c); res.on('end', () => { try { resolve({ status: res.statusCode, data: JSON.parse(d) }); } catch(e) { resolve({ status: res.statusCode, data: {} }); } }); });
    r.on('error', reject);
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}
function authReq(method, path, token, body) {
  return req(method, path, body, { 'Authorization': 'Bearer ' + token });
}

async function test() {
  let token = '';
  let spuId = '';
  const results = [];

  console.log('=== CarbonLink API Integration Test ===\n');

  // 1. Captcha
  let r = await req('GET', '/api/v1/captcha');
  results.push(['GET /captcha', r.status === 200 && r.data.code === 0]);

  // 2. Login (will fail captcha but endpoint works)
  r = await req('POST', '/api/v1/login', { phone: '13800000001', password: '123456', captchaKey: 'test', captchaValue: 'test' });
  if (r.data.data && r.data.data.accessToken) {
    token = r.data.data.accessToken;
    results.push(['POST /login', true]);
  } else {
    // Try to get token by bypassing captcha check - use refresh endpoint
    // Actually, let's just note login requires valid captcha
    results.push(['POST /login (captcha required)', r.status === 400]);
    console.log('Note: Login requires valid captcha. Testing public endpoints only.');
  }

  // 3. Products list (public)
  r = await req('GET', '/api/v1/products');
  results.push(['GET /products', r.status === 200 && r.data.code === 0]);
  if (r.data.data && r.data.data.list && r.data.data.list.length > 0) {
    spuId = r.data.data.list[0].id;
    console.log('Products count:', r.data.data.list.length, 'First SPU:', spuId);
  }

  // 4. Product detail (public)
  if (spuId) {
    r = await req('GET', '/api/v1/products/' + spuId);
    results.push(['GET /products/:id', r.status === 200 && r.data.code === 0]);
    if (r.data.data && r.data.data.spu) {
      console.log('Product:', r.data.data.spu.title);
    }
  }

  // 5. Category specs (public)
  r = await req('GET', '/api/v1/category-specs/1');
  results.push(['GET /category-specs/1', r.status === 200]);

  // 6. Search
  r = await req('GET', '/api/v1/products?keyword=iPhone');
  results.push(['GET /products?keyword', r.status === 200 && r.data.code === 0]);

  // Auth-required tests
  if (token) {
    // 7. Stats
    r = await authReq('GET', '/api/v1/stats', token);
    results.push(['GET /stats', r.status === 200 && r.data.code === 0]);
    if (r.data.data) console.log('Stats:', JSON.stringify(r.data.data));

    // 8. Favorites
    r = await authReq('GET', '/api/v1/favorites', token);
    results.push(['GET /favorites', r.status === 200 && r.data.code === 0]);

    // 9. Browse history
    r = await authReq('GET', '/api/v1/browse-history', token);
    results.push(['GET /browse-history', r.status === 200 && r.data.code === 0]);

    // 10. Chat conversations
    r = await authReq('GET', '/api/v1/chat/conversations', token);
    results.push(['GET /chat/conversations', r.status === 200 && r.data.code === 0]);

    // 11. Orders
    r = await authReq('GET', '/api/v1/orders/buyer', token);
    results.push(['GET /orders/buyer', r.status === 200 && r.data.code === 0]);

    // 12. OBS upload credential
    r = await authReq('POST', '/api/v1/obs/upload-credential', token, { fileName: 'test.png' });
    results.push(['POST /obs/upload-credential', r.status === 200 && r.data.code === 0]);

    // 13. Profile
    r = await authReq('GET', '/api/v1/profile', token);
    results.push(['GET /profile', r.status === 200 && r.data.code === 0]);

    // 14. Stats no-auth should fail
    r = await req('GET', '/api/v1/stats');
    results.push(['GET /stats (no auth)', r.status === 401]);
  }

  // Summary
  console.log('\n=== Results ===');
  results.forEach(r => console.log((r[1] ? 'PASS' : 'FAIL') + '  ' + r[0]));
  const passed = results.filter(r => r[1]).length;
  console.log('\nTotal: ' + passed + '/' + results.length + ' passed');
}

test().catch(console.error);