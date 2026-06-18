const http = require('http');

function request(method, path, data, token) {
  return new Promise((resolve, reject) => {
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers['Authorization'] = 'Bearer ' + token;
    const body = data ? JSON.stringify(data) : '';
    if (data) headers['Content-Length'] = body.length;
    const req = http.request({ hostname: 'localhost', port: 3001, path, method, headers }, res => {
      let b = '';
      res.on('data', c => b += c);
      res.on('end', () => {
        try { resolve(JSON.parse(b)); } catch { resolve({ raw: b.substring(0, 200) }); }
      });
    });
    req.on('error', reject);
    if (data) req.write(body);
    req.end();
  });
}

async function test() {
  console.log('=== 聊天功能集成测试 ===\n');

  // 1. 获取验证码
  console.log('1. 获取验证码...');
  const captchaRes = await request('GET', '/api/v1/captcha');
  if (!captchaRes.data) { console.log('验证码获取失败:', captchaRes); return; }
  const captchaKey = captchaRes.data.captchaKey;
  const captchaText = captchaRes.data.captchaText;
  console.log('   验证码Key:', captchaKey, '文本:', captchaText);

  // 2. 登录用户1
  console.log('\n2. 登录用户1 (13800000001)...');
  const login1 = await request('POST', '/api/v1/login', { phone: '13800000001', password: '123456', captchaKey, captchaValue: captchaText });
  if (!login1.data) { console.log('登录失败:', login1); return; }
  const token1 = login1.data.token;
  console.log('   Token1:', token1.substring(0, 30) + '...');

  // 3. 获取验证码并登录用户2
  console.log('\n3. 登录用户2 (13800000002)...');
  const captcha2 = await request('GET', '/api/v1/captcha');
  const login2 = await request('POST', '/api/v1/login', { phone: '13800000002', password: '123456', captchaKey: captcha2.data.captchaKey, captchaValue: captcha2.data.captchaText });
  if (!login2.data) { console.log('登录2失败:', login2); return; }
  const token2 = login2.data.token;
  console.log('   Token2:', token2.substring(0, 30) + '...');

  // 4. 用户1创建/查找与用户2的会话
  console.log('\n4. 用户1(买家)创建与用户2(卖家)的会话...');
  const conv1 = await request('POST', '/api/v1/chat/conversations', { sellerId: 'u_test_002', productId: '030536dd-6e22-4f9d-ba97-38e219fb08a3' }, token1);
  console.log('   结果:', JSON.stringify(conv1).substring(0, 300));

  // 5. 用户2创建与用户1的会话（应返回同一个会话）
  console.log('\n5. 用户2(买家)创建与用户1(卖家)的会话（应返回同一会话）...');
  const conv2 = await request('POST', '/api/v1/chat/conversations', { sellerId: 'u_test_001', productId: '030536dd-6e22-4f9d-ba97-38e219fb08a3' }, token2);
  console.log('   结果:', JSON.stringify(conv2).substring(0, 300));

  if (conv1.data && conv2.data) {
    const id1 = conv1.data.id || conv1.data.conversationId;
    const id2 = conv2.data.id || conv2.data.conversationId;
    console.log('   会话ID相同?', id1 === id2 ? '✅ 是' : '❌ 否 (' + id1 + ' vs ' + id2 + ')');
  }

  // 6. 获取会话列表
  console.log('\n6. 用户1获取会话列表...');
  const convs = await request('GET', '/api/v1/chat/conversations', null, token1);
  console.log('   结果:', JSON.stringify(convs).substring(0, 500));

  // 7. 用户1发送消息
  console.log('\n7. 用户1发送消息...');
  const convId = conv1.data ? (conv1.data.id || conv1.data.conversationId) : null;
  if (!convId) { console.log('   无会话ID，跳过'); return; }
  const msg1 = await request('POST', '/api/v1/chat/messages', { conversationId: convId, content: '你好，这个商品还在吗？' }, token1);
  console.log('   结果:', JSON.stringify(msg1).substring(0, 300));

  // 8. 获取消息列表
  console.log('\n8. 获取消息列表...');
  const msgs = await request('GET', '/api/v1/chat/messages/' + convId, null, token1);
  console.log('   结果:', JSON.stringify(msgs).substring(0, 500));

  // 9. 用户2获取会话列表（检查未读数）
  console.log('\n9. 用户2获取会话列表（检查未读数）...');
  const convs2 = await request('GET', '/api/v1/chat/conversations', null, token2);
  console.log('   结果:', JSON.stringify(convs2).substring(0, 500));

  // 10. 用户2标记已读
  console.log('\n10. 用户2标记已读...');
  const readRes = await request('PUT', '/api/v1/chat/conversations/' + convId + '/read', null, token2);
  console.log('   结果:', JSON.stringify(readRes).substring(0, 200));

  // 11. 再次检查用户2未读数
  console.log('\n11. 再次检查用户2未读数...');
  const convs3 = await request('GET', '/api/v1/chat/conversations', null, token2);
  console.log('   结果:', JSON.stringify(convs3).substring(0, 500));

  console.log('\n=== 测试完成 ===');
}

test().catch(err => console.error('测试出错:', err.message));