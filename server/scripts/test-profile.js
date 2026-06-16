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
  const captcha = await request('GET', '/api/v1/captcha');
  const login = await request('POST', '/api/v1/login', {
    phone: '13800000001', password: '123456',
    captchaKey: captcha.data.captchaKey, captchaValue: captcha.data.captchaText
  });
  const token = login.data.token;
  console.log('1. Login OK, token:', token ? 'yes' : 'no');

  const profile = await request('GET', '/api/v1/profile', null, token);
  console.log('2. Profile favoriteCount:', profile.data?.favoriteCount);
  console.log('   productCount:', profile.data?.productCount);
  console.log('   soldCount:', profile.data?.soldCount);

  await request('POST', '/api/v1/browse', { targetId: 'spu_seed_001', targetCategory: '电子数码' }, token);
  await request('POST', '/api/v1/browse', { targetId: 'spu_seed_002', targetCategory: '电子数码' }, token);
  await request('POST', '/api/v1/browse', { targetId: 'spu_seed_005', targetCategory: '图书教材' }, token);
  console.log('3. Browse records inserted');

  const browseCount = await request('GET', '/api/v1/browse-count', null, token);
  console.log('4. Browse count:', browseCount.data?.count);

  const browseHistory = await request('GET', '/api/v1/browse-history?page=1&pageSize=5', null, token);
  console.log('5. Browse history total:', browseHistory.data?.total);
  browseHistory.data?.list?.forEach((item, i) => console.log(`   ${i+1}. ${item.title} (${item.targetId})`));

  console.log('\nAll tests done!');
}

test().catch(e => console.error(e.message));