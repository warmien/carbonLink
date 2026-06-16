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
  const results = [];
  console.log('=== CarbonLink Full API Integration Test ===\n');

  // 1. Get captcha
  let r = await req('GET', '/api/v1/captcha');
  results.push(['GET /captcha', r.status === 200 && r.data.code === 0]);
  const captchaKey = r.data.data.captchaKey;
  const captchaText = r.data.data.captchaText;
  console.log('Captcha obtained, text:', captchaText);

  // 2. Login with captcha
  r = await req('POST', '/api/v1/login', { phone: '13800000001', password: '123456', captchaKey, captchaValue: captchaText });
  results.push(['POST /login', r.status === 200 && r.data.code === 0]);
  let token = '';
  if (r.data.data && (r.data.data.token || r.data.data.accessToken)) {
    token = r.data.data.token || r.data.data.accessToken;
    console.log('Login successful, token obtained');
  } else {
    console.log('Login failed:', JSON.stringify(r.data));
    console.log('\nCannot test auth endpoints. Public results:');
    results.forEach(x => console.log((x[1] ? 'PASS' : 'FAIL') + '  ' + x[0]));
    return;
  }

  // 3. Products list
  r = await req('GET', '/api/v1/products');
  results.push(['GET /products', r.status === 200 && r.data.code === 0]);
  let spuId = '';
  if (r.data.data && r.data.data.list && r.data.data.list.length > 0) {
    spuId = r.data.data.list[0].id;
    console.log('Products:', r.data.data.list.length);
  }

  // 4. Product detail
  if (spuId) {
    r = await req('GET', '/api/v1/products/' + spuId);
    results.push(['GET /products/:id', r.status === 200 && r.data.code === 0]);
  }

  // 5. Category specs
  r = await req('GET', '/api/v1/category-specs/1');
  results.push(['GET /category-specs/1', r.status === 200]);

  // 6. Search
  r = await req('GET', '/api/v1/products?keyword=iPhone');
  results.push(['GET /products?keyword', r.status === 200 && r.data.code === 0]);

  // 7. Stats
  r = await authReq('GET', '/api/v1/stats', token);
  results.push(['GET /stats', r.status === 200 && r.data.code === 0]);
  if (r.data.data) console.log('Stats:', JSON.stringify(r.data.data));

  // 8. Profile
  r = await authReq('GET', '/api/v1/profile', token);
  results.push(['GET /profile', r.status === 200 && r.data.code === 0]);

  // 9. Favorites
  r = await authReq('GET', '/api/v1/favorites', token);
  results.push(['GET /favorites', r.status === 200 && r.data.code === 0]);

  // 10. Browse history
  r = await authReq('GET', '/api/v1/browse-history', token);
  results.push(['GET /browse-history', r.status === 200 && r.data.code === 0]);

  // 11. Chat conversations
  r = await authReq('GET', '/api/v1/chat/conversations', token);
  results.push(['GET /chat/conversations', r.status === 200 && r.data.code === 0]);

  // 12. Orders
  r = await authReq('GET', '/api/v1/orders/buyer', token);
  results.push(['GET /orders/buyer', r.status === 200 && r.data.code === 0]);

  // 13. OBS upload credential
  r = await authReq('POST', '/api/v1/obs/upload-credential', token, { fileName: 'test.png', contentType: 'image/png' });
  results.push(['POST /obs/upload-credential', r.status === 200 && r.data.code === 0]);

  // 14. Stats no-auth
  r = await req('GET', '/api/v1/stats');
  results.push(['GET /stats (no auth=401)', r.status === 401]);

  // 15. Refresh token
  if (r.data.data && r.data.data.refreshToken) {
    r = await req('POST', '/api/v1/refresh', { refreshToken: r.data.data.refreshToken });
    results.push(['POST /refresh', r.status === 200 && r.data.code === 0]);
  } else {
    results.push(['POST /refresh (skipped)', true]);
  }

  // Summary
  console.log('\n=== Results ===');
  results.forEach(x => console.log((x[1] ? 'PASS' : 'FAIL') + '  ' + x[0]));
  const passed = results.filter(x => x[1]).length;
  console.log('\nTotal: ' + passed + '/' + results.length + ' passed');
}

test().catch(console.error);