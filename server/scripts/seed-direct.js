const db = require('better-sqlite3')('C:/Users/warminen/DevEcoStudioProjects/CarbonLink/server/data/carbonlink.db');
db.pragma('foreign_keys = OFF');

const PUBLIC_DOMAIN = 'https://carbon-link.obs.cn-north-4.myhuaweicloud.com';

const PRODUCTS = [
  { title: 'iPhone 13 128G 绿色', categoryId: 1, price: 2999, originalPrice: 5999, condition: 'B级-99成新', desc: '自用iPhone 13，绿色128G，电池健康度92%，无维修记录。', color: '#1890FF', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: 'iPad Air 5 64G', categoryId: 1, price: 2599, originalPrice: 4799, condition: 'C级-95成新', desc: 'iPad Air 5 紫色64G WiFi版，配Apple Pencil二代。', color: '#40A9FF', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: 'AirPods Pro 2代', categoryId: 1, price: 899, originalPrice: 1899, condition: 'B级-99成新', desc: 'AirPods Pro 第二代 USB-C版，降噪效果优秀。', color: '#69C0FF', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '高等数学同济第七版', categoryId: 2, price: 15, originalPrice: 48, condition: 'D级-9成新', desc: '高等数学上下册，有部分笔记标注，考研复习用完。', color: '#FAAD14', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '考研英语真题十年', categoryId: 2, price: 25, originalPrice: 68, condition: 'C级-95成新', desc: '考研英语一真题2015-2024，解析详细。', color: '#FFC53D', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '优衣库羽绒服黑色L码', categoryId: 3, price: 199, originalPrice: 599, condition: 'C级-95成新', desc: '优衣库轻薄羽绒服，黑色L码，只穿过一个冬天。', color: '#FF6B35', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: 'Nike Air Force 1 白色42码', categoryId: 3, price: 299, originalPrice: 799, condition: 'D级-9成新', desc: '经典空军一号纯白42码，鞋底有正常磨损。', color: '#FF85C0', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '小米台灯Pro', categoryId: 4, price: 59, originalPrice: 179, condition: 'B级-99成新', desc: '小米智能台灯Pro，支持手机调光调色温。', color: '#52C41A', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '小熊电煮锅1.5L', categoryId: 4, price: 35, originalPrice: 89, condition: 'D级-9成新', desc: '小熊宿舍电煮锅，1.5L容量，毕业出。', color: '#73D13D', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '兰蔻小黑瓶精华50ml', categoryId: 5, price: 280, originalPrice: 760, condition: 'B级-99成新', desc: '兰蔻小黑瓶精华肌底液50ml，用了约1/3。', color: '#722ED1', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: 'MAC口红3支套装', categoryId: 5, price: 120, originalPrice: 360, condition: 'C级-95成新', desc: 'MAC热门色号3支，各用过2-3次。', color: '#9254DE', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '李宁跑步鞋43码', categoryId: 6, price: 159, originalPrice: 399, condition: 'D级-9成新', desc: '李宁超轻19跑鞋，43码黑红配色。', color: '#13C2C2', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '瑜伽垫加厚10mm', categoryId: 6, price: 29, originalPrice: 79, condition: 'C级-95成新', desc: '加厚防滑瑜伽垫10mm，紫色，带收纳袋。', color: '#36CFC9', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '得力文具套装', categoryId: 7, price: 18, originalPrice: 45, condition: 'B级-99成新', desc: '得力文具套装，全新未拆封。', color: '#597EF7', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '卡西欧计算器fx-991CNX', categoryId: 7, price: 89, originalPrice: 159, condition: 'B级-99成新', desc: '卡西欧科学计算器，考研/高数必备。', color: '#85A5FF', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '尤克里里23寸', categoryId: 8, price: 129, originalPrice: 298, condition: 'C级-95成新', desc: 'Tom尤克里里23寸桃花心木，送教程书和调音器。', color: '#F759AB', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '手绘帆布包', categoryId: 8, price: 35, originalPrice: 68, condition: 'B级-99成新', desc: '手工绘制帆布包，原创设计。', color: '#FF85C0', sellerId: 'u_test_002', sellerName: '测试用户小李' },
  { title: '网易云音乐年卡', categoryId: 9, price: 68, originalPrice: 158, condition: 'A级-全新未用', desc: '网易云音乐黑胶VIP年卡，未激活。', color: '#FF4D4F', sellerId: 'u_test_003', sellerName: '测试用户小张' },
  { title: '考研网课账号政治+英语', categoryId: 9, price: 99, originalPrice: 299, condition: 'A级-全新未用', desc: '某知名考研机构2026政治+英语双科网课账号。', color: '#FF7875', sellerId: 'u_test_001', sellerName: '测试用户小王' },
  { title: '宿舍收纳架三层', categoryId: 10, price: 25, originalPrice: 69, condition: 'D级-9成新', desc: '铁艺三层收纳架，毕业出。', color: '#8C8C8C', sellerId: 'u_test_002', sellerName: '测试用户小李' },
];

const insertSpu = db.prepare(`INSERT INTO spu (id, title, description, category_id, seller_id, seller_name, seller_avatar, location, distance, images, status, view_count, favorite_count, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`);
const insertSku = db.prepare(`INSERT INTO sku (id, spu_id, price, original_price, condition, carbon_reduction, carbon_credits, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`);

const transaction = db.transaction(() => {
  let count = 0;
  for (let i = 0; i < PRODUCTS.length; i++) {
    const p = PRODUCTS[i];
    const spuId = `spu_seed_${String(i + 1).padStart(3, '0')}`;
    const now = Date.now();
    const imageUrl = `${PUBLIC_DOMAIN}/carbonlink/seed/placeholder_${i}.png`;

    insertSpu.run(
      spuId, p.title, p.desc, p.categoryId, p.sellerId, p.sellerName, '',
      '北京海淀区', '1.2km', JSON.stringify([imageUrl]),
      'on_sale', Math.floor(Math.random() * 200) + 10, Math.floor(Math.random() * 20),
      now, now
    );

    const skuId = `sku_seed_${String(i + 1).padStart(3, '0')}`;
    const carbonCredits = Math.round(p.price * 0.1);
    const carbonReduction = Math.round(p.price * 0.05 * 100) / 100;
    insertSku.run(
      skuId, spuId, p.price, p.originalPrice, p.condition, carbonReduction, carbonCredits, 'on_sale', now, now
    );

    console.log(`[${i + 1}] ${p.title} (${p.price}元)`);
    count++;
  }
  return count;
});

try {
  const count = transaction();
  const spuCount = db.prepare('SELECT COUNT(*) as c FROM spu').get();
  console.log(`\n完成！新增${count}条，SPU总数: ${spuCount.c}`);
} catch (err) {
  console.error('失败:', err.message);
}

db.close();
