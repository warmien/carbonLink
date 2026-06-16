import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import cron from 'node-cron';
import { DataAggregationService } from './services/DataAggregationService';
import authRoutes from './routes/auth';
import userAuthRoutes from './routes/userAuth';
import analyticsRoutes from './routes/analytics';
import exportRoutes from './routes/export';
import productRoutes, { skuRouter } from './routes/product';
import specRoutes from './routes/spec';
import inventoryRoutes from './routes/inventory';
import migrationRoutes from './routes/migration';
import favoriteRoutes from './routes/favorite';
import orderRoutes from './routes/order';
import obsRoutes from './routes/obs';
import chatRoutes from './routes/chat';
import { auditMiddleware } from './middleware/audit';
import businessDb from './businessDatabase';
import { initObsFromEnv } from './services/ObsService';
import { initWsChatServer } from './websocket/WsChatServer';

console.log('[CarbonLink] 业务数据库已初始化，表数量:',
  (businessDb.prepare("SELECT count(*) as c FROM sqlite_master WHERE type='table'").get() as { c: number }).c);

initObsFromEnv();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use(auditMiddleware);

app.use('/api/auth', authRoutes);
app.use('/api/v1', userAuthRoutes);
app.use('/api/v1/products', productRoutes);
app.use('/api/v1/skus', skuRouter);
app.use('/api/v1', specRoutes);
app.use('/api/v1/inventory', inventoryRoutes);
app.use('/api/v1/migration', migrationRoutes);
app.use('/api/v1/favorites', favoriteRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/obs', obsRoutes);
app.use('/api/v1/chat', chatRoutes);
app.use('/api/admin', analyticsRoutes);
app.use('/api/export', exportRoutes);

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

DataAggregationService.aggregateAll();

cron.schedule('0 * * * *', () => {
  try {
    DataAggregationService.aggregateAll();
    console.log(`[${new Date().toISOString()}] 数据聚合完成`);
  } catch (e) {
    console.error(`[${new Date().toISOString()}] 数据聚合失败:`, e);
  }
});

cron.schedule('*/10 * * * *', () => {
  try {
    const now = Date.now();
    businessDb.prepare('DELETE FROM captcha_records WHERE expires_at < ?').run(now);
    businessDb.prepare('DELETE FROM token_blacklist WHERE expires_at < ?').run(now);
    console.log(`[${new Date().toISOString()}] 过期验证码和Token黑名单已清理`);
  } catch (e) {
    console.error(`[${new Date().toISOString()}] 清理失败:`, e);
  }
});

const server = app.listen(PORT, () => {
  console.log(`CarbonLink Server running on http://localhost:${PORT}`);
  console.log(`  用户API: http://localhost:${PORT}/api/v1/`);
  console.log(`  商品API: http://localhost:${PORT}/api/v1/products`);
  console.log(`  规格API: http://localhost:${PORT}/api/v1/spec-names`);
  console.log(`  库存API: http://localhost:${PORT}/api/v1/inventory`);
  console.log(`  迁移API: http://localhost:${PORT}/api/v1/migration`);
  console.log(`  聊天API: http://localhost:${PORT}/api/v1/chat/conversations`);
  console.log(`  管理API: http://localhost:${PORT}/api/auth/`);
  console.log(`  OBS上传: http://localhost:${PORT}/api/v1/obs/upload-credential`);
  console.log(`  WebSocket: ws://localhost:${PORT}/ws/chat`);
  console.log(`  默认管理员: admin / admin123`);
});

initWsChatServer(server);
