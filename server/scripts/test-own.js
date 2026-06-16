const http = require('http');
function request(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const options = { hostname: 'localhost', port: 3001, path, method, headers: { 'Content-Type': 'application/json' } };
    if (token) options.headers['Authorization'] = 'Bearer ' + token;
    const req = http.request(options, (res) => { let data = ''; res.on('data', chunk => data += chunk); res.on('end', () => { try { resolve(JSON.parse(data)); } catch (e) { reject(e); } }); });
    req.on('error', reject); if (body) req.write(JSON.stringify(body)); req.end();
  });
}
async function test() {
  const captcha = await request('GET', '/api/v1/captcha');
  const login = await request('POST', '/api/v1/login', { phone: '13800000001', password: '123456', captchaKey: captcha.data.captchaKey, captchaValue: captcha.data.captchaText });
  const token = login.data.token;
  // spu_seed_006 is owned by u_test_003, so u_test_001 can buy it
  const buy = await request('POST', '/api/v1/orders', { spuId: 'spu_seed_006', paymentMethod: 'alipay' }, token);
  console.log('Buy others product:', buy.code, buy.message);
  // spu_seed_004 is owned by u_test_001, should fail
  const buyOwn = await request('POST', '/api/v1/orders', { spuId: 'spu_seed_004', paymentMethod: 'wechat' }, token);
  console.log('Buy own product:', buyOwn.code, buyOwn.message);
}
test().catch(e => console.error(e.message));