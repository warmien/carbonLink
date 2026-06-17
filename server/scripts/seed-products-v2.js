const ObsClient = require('esdk-obs-nodejs');
const path = require('path');
const db = require('better-sqlite3')(path.join(__dirname, '..', 'data', 'carbonlink.db'));

const OBS_CONFIG = {
  accessKeyId: process.env.OBS_ACCESS_KEY_ID || 'your_obs_access_key_id',
  secretAccessKey: process.env.OBS_SECRET_ACCESS_KEY || 'your_obs_secret_access_key',
  server: 'obs.cn-north-4.myhuaweicloud.com',
  bucket: 'carbon-link',
};

const obsClient = new ObsClient({
  access_key_id: OBS_CONFIG.accessKeyId,
  secret_access_key: OBS_CONFIG.secretAccessKey,
  server: OBS_CONFIG.server,
});

const PUBLIC_DOMAIN = `https://${OBS_CONFIG.bucket}.${OBS_CONFIG.server}`;

function uploadToObs(objectKey, buffer, contentType) {
  return new Promise((resolve, reject) => {
    obsClient.putObject({
      Bucket: OBS_CONFIG.bucket,
      Key: objectKey,
      Body: buffer,
      ContentType: contentType,
    }, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });
}

const COLORS = ['#1890FF', '#FAAD14', '#FF6B35', '#52C41A', '#722ED1', '#13C2C2', '#597EF7', '#F759AB', '#FF4D4F', '#8C8C8C'];

const PRODUCTS = [
  { title: 'iPhone 13 128G 绿色', categoryId: 1, price: 2999, originalPrice: 5999, condition: 'B级-99成新', desc: '自用iPhone 13，绿色128G，电池健康度92%，无维修记录，屏幕完好无划痕。原装充电器数据线齐全。', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: 'iPad Air 5 64G', categoryId: 1, price: 2599, originalPrice: 4799, condition: 'C级-95成新', desc: 'iPad Air 5 紫色64G WiFi版，配Apple Pencil二代，轻微使用痕迹，功能正常。', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: 'AirPods Pro 2代', categoryId: 1, price: 899, originalPrice: 1899, condition: 'B级-99成新', desc: 'AirPods Pro 第二代 USB-C版，降噪效果优秀，使用3个月，成色很新。', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '高等数学同济第七版', categoryId: 2, price: 15, originalPrice: 48, condition: 'D级-9成新', desc: '高等数学上下册，有部分笔记和标注，不影响阅读，考研复习用完。', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '考研英语真题十年', categoryId: 2, price: 25, originalPrice: 68, condition: 'C级-95成新', desc: '考研英语一真题2015-2024，解析详细，有少量铅笔标注可擦除。', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '优衣库羽绒服黑色L码', categoryId: 3, price: 199, originalPrice: 599, condition: 'C级-95成新', desc: '优衣库轻薄羽绒服，黑色L码，只穿过一个冬天，清洗后存放，无破损。', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: 'Nike Air Force 1 白色42码', categoryId: 3, price: 299, originalPrice: 799, condition: 'D级-9成新', desc: '经典空军一号纯白42码，鞋底有正常磨损，鞋面干净无发黄。', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '小米台灯Pro', categoryId: 4, price: 59, originalPrice: 179, condition: 'B级-99成新', desc: '小米智能台灯Pro，支持手机调光调色温，用了一学期，功能完好。', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '小熊电煮锅1.5L', categoryId: 4, price: 35, originalPrice: 89, condition: 'D级-9成新', desc: '小熊宿舍电煮锅，1.5L容量，煮面煮粥都可以，毕业出。', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '兰蔻小黑瓶精华50ml', categoryId: 5, price: 280, originalPrice: 760, condition: 'B级-99成新', desc: '兰蔻小黑瓶精华肌底液50ml，用了约1/3，保质期到2027年，正品保证。', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: 'MAC口红3支套装', categoryId: 5, price: 120, originalPrice: 360, condition: 'C级-95成新', desc: 'MAC热门色号3支：Ruby Woo/Chili/See Sheer，各用过2-3次。', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '李宁跑步鞋43码', categoryId: 6, price: 159, originalPrice: 399, condition: 'D级-9成新', desc: '李宁超轻19跑鞋，43码黑红配色，跑了约200公里，缓震依然不错。', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '瑜伽垫加厚10mm', categoryId: 6, price: 29, originalPrice: 79, condition: 'C级-95成新', desc: '加厚防滑瑜伽垫10mm，紫色，带收纳袋，使用半年。', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '得力文具套装', categoryId: 7, price: 18, originalPrice: 45, condition: 'B级-99成新', desc: '得力文具套装：中性笔5支+荧光笔3支+笔记本2本+便利贴，全新未拆封。', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '卡西欧计算器fx-991CNX', categoryId: 7, price: 89, originalPrice: 159, condition: 'B级-99成新', desc: '卡西欧科学计算器，考研/高数必备，功能正常，屏幕清晰。', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '尤克里里23寸', categoryId: 8, price: 129, originalPrice: 298, condition: 'C级-95成新', desc: 'Tom尤克里里23寸桃花心木，音色好听，送教程书和调音器。', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '手绘帆布包', categoryId: 8, price: 35, originalPrice: 68, condition: 'B级-99成新', desc: '手工绘制帆布包，原创设计，独一无二，适合日常出行。', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '网易云音乐年卡', categoryId: 9, price: 68, originalPrice: 158, condition: 'A级-全新未用', desc: '网易云音乐黑胶VIP年卡，未激活，有效期至2027年12月。', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '考研网课账号政治+英语', categoryId: 9, price: 99, originalPrice: 299, condition: 'A级-全新未用', desc: '某知名考研机构2026政治+英语双科网课账号，可看回放至考试结束。', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '宿舍收纳架三层', categoryId: 10, price: 25, originalPrice: 69, condition: 'D级-9成新', desc: '铁艺三层收纳架，放书放杂物都方便，毕业出，自提。', sellerId: 'u_test_002', sellerName: '测试用户小李' },
];

async function seedProducts() {
  console.log('Seeding products with OBS images...\n');

  const insertSpu = db.prepare(`INSERT INTO spu (id, title, description, images, category_id, sub_category_id, brand, seller_id, seller_name, seller_avatar, location, distance, view_count, favorite_count, status, tags, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`);
  const insertSku = db.prepare(`INSERT INTO sku (id, spu_id, price, original_price, condition, carbon_reduction, carbon_credits, status, sku_code, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`);

  for (let i = 0; i < PRODUCTS.length; i++) {
    const p = PRODUCTS[i];
    const color = COLORS[i % COLORS.length];
    const objectKey = `carbonlink/seed/${Date.now()}-${i}.png`;

    const pngBuffer = Buffer.from(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      'base64'
    );

    let publicUrl = `${PUBLIC_DOMAIN}/${objectKey}`;
    try {
      await uploadToObs(objectKey, pngBuffer, 'image/png');
      console.log(`[${i + 1}/${PRODUCTS.length}] Image uploaded: OK`);
    } catch (err) {
      console.error(`[${i + 1}] Image upload failed:`, err.message);
      publicUrl = '';
    }

    const spuId = `spu_seed_${String(i + 1).padStart(3, '0')}`;
    const now = Date.now();

    try {
      insertSpu.run(
        spuId, p.title, p.desc, JSON.stringify(publicUrl ? [publicUrl] : []),
        p.categoryId, null, '', p.sellerId, p.sellerName, '',
        '北京海淀区', '1.2km',
        Math.floor(Math.random() * 200) + 10,
        Math.floor(Math.random() * 20),
        'on_sale', '[]', now, now
      );

      const skuId = `sku_seed_${String(i + 1).padStart(3, '0')}`;
      insertSku.run(
        skuId, spuId, p.price, p.originalPrice, p.condition,
        0, 0, 'on_sale', `SKU-${String(i + 1).padStart(4, '0')}`, now, now
      );

      console.log(`  Product created: ${p.title} (${p.price}yuan)`);
    } catch (err) {
      console.error(`  Product creation failed: ${p.title} - ${err.message}`);
    }

    await new Promise((r) => setTimeout(r, 100));
  }

  const spuCount = db.prepare('SELECT COUNT(*) as c FROM spu').get();
  console.log(`\nSeed data created! SPU total: ${spuCount.c}`);
  db.close();
}

seedProducts().catch(console.error);