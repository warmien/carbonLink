const http = require('http');

function request(method, path, body) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3001,
      path: path,
      method: method,
      headers: { 'Content-Type': 'application/json' }
    };
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
    phone: '13800000001',
    password: '123456',
    captchaKey: captcha.data.captchaKey,
    captchaValue: captcha.data.captchaText
  });
  console.log('Full login response:', JSON.stringify(login, null, 2));
}

test().catch(e => console.error(e.message));