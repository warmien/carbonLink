require('ts-node').register({transpileOnly:true});
require('./src/index.ts');

const http = require('http');
function req(m, p, d, t) {
  return new Promise((r, j) => {
    const h = { 'Content-Type': 'application/json' };
    if (t) h['Authorization'] = 'Bearer ' + t;
    const b = d ? JSON.stringify(d) : '';
    const o = http.request({ hostname: 'localhost', port: 3001, path: p, method: m, headers: h }, res => {
      let body = '';
      res.on('data', c => body += c);
      res.on('end', () => { try { r(JSON.parse(body)); } catch (e) { r({ raw: body.substring(0, 300), status: res.statusCode }); } });
    });
    o.on('error', j);
    if (d) o.write(b);
    o.end();
  });
}

setTimeout(async () => {
  try {
    console.log('=== Test captcha only ===');
    const c = await req('GET', '/api/v1/captcha');
    console.log('captcha:', c.code === 0 ? 'OK' : 'FAIL', 'key:', c.data?.captchaKey?.substring(0, 8));
    process.exit(0);
  } catch (e) {
    console.error('ERR:', e.message);
    process.exit(1);
  }
}, 5000);