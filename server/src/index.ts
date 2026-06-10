import express from 'express';
import cors from 'cors';
import cron from 'node-cron';
import { DataAggregationService } from './services/DataAggregationService';
import authRoutes from './routes/auth';
import analyticsRoutes from './routes/analytics';
import exportRoutes from './routes/export';
import { auditMiddleware } from './middleware/audit';

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());
app.use(auditMiddleware);

app.use('/api/auth', authRoutes);
app.use('/api', analyticsRoutes);
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

app.listen(PORT, () => {
  console.log(`CarbonLink Admin Server running on http://localhost:${PORT}`);
  console.log(`默认管理员账号: admin / admin123`);
});