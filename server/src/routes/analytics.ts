import { Router, Request, Response } from 'express';
import { DataQueryService } from '../services/DataQueryService';
import { authMiddleware } from '../middleware/auth';

const router = Router();

router.use(authMiddleware);

router.get('/dashboard/overview', (req: Request, res: Response): void => {
  const data = DataQueryService.getDashboardOverview();
  res.json(data);
});

router.get('/dashboard/trend', (req: Request, res: Response): void => {
  const days = parseInt(req.query.days as string) || 7;
  const data = DataQueryService.getDashboardTrend(days);
  res.json(data);
});

router.get('/user/growth', (req: Request, res: Response): void => {
  const { startDate, endDate } = req.query;
  const data = DataQueryService.getUserGrowth(startDate as string, endDate as string);
  res.json(data);
});

router.get('/user/active', (_req: Request, res: Response): void => {
  const data = DataQueryService.getUserActive();
  res.json(data);
});

router.get('/user/retention', (_req: Request, res: Response): void => {
  const data = DataQueryService.getUserRetention();
  res.json(data);
});

router.get('/user/level-distribution', (_req: Request, res: Response): void => {
  const data = DataQueryService.getUserLevelDistribution();
  res.json(data);
});

router.get('/user/funnel', (_req: Request, res: Response): void => {
  const data = DataQueryService.getUserFunnel();
  res.json(data);
});

router.get('/user/list', (req: Request, res: Response): void => {
  const page = parseInt(req.query.page as string) || 1;
  const pageSize = parseInt(req.query.pageSize as string) || 20;
  const data = DataQueryService.getUserList(page, pageSize);
  res.json(data);
});

router.get('/product/trend', (req: Request, res: Response): void => {
  const { startDate, endDate } = req.query;
  const data = DataQueryService.getProductTrend(startDate as string, endDate as string);
  res.json(data);
});

router.get('/product/transaction', (_req: Request, res: Response): void => {
  const data = DataQueryService.getProductTransaction();
  res.json(data);
});

router.get('/product/category-distribution', (_req: Request, res: Response): void => {
  const data = DataQueryService.getProductCategoryDistribution();
  res.json(data);
});

router.get('/product/price-distribution', (_req: Request, res: Response): void => {
  const data = DataQueryService.getProductPriceDistribution();
  res.json(data);
});

router.get('/product/condition-distribution', (_req: Request, res: Response): void => {
  const data = DataQueryService.getProductConditionDistribution();
  res.json(data);
});

router.get('/product/hot-ranking', (req: Request, res: Response): void => {
  const metric = (req.query.metric as string) || 'viewCount';
  const limit = parseInt(req.query.limit as string) || 10;
  const data = DataQueryService.getProductHotRanking(metric, limit);
  res.json(data);
});

router.get('/product/list', (req: Request, res: Response): void => {
  const page = parseInt(req.query.page as string) || 1;
  const pageSize = parseInt(req.query.pageSize as string) || 20;
  const data = DataQueryService.getProductList(page, pageSize);
  res.json(data);
});

router.get('/carbon/credit-trend', (req: Request, res: Response): void => {
  const { startDate, endDate } = req.query;
  const data = DataQueryService.getCarbonCreditTrend(startDate as string, endDate as string);
  res.json(data);
});

router.get('/carbon/reduction-estimate', (_req: Request, res: Response): void => {
  const data = DataQueryService.getCarbonReductionEstimate();
  res.json(data);
});

router.get('/carbon/credit-source', (_req: Request, res: Response): void => {
  const data = DataQueryService.getCarbonCreditSource();
  res.json(data);
});

router.get('/carbon/exchange-stats', (_req: Request, res: Response): void => {
  const data = DataQueryService.getCarbonExchangeStats();
  res.json(data);
});

router.get('/carbon/achievement-distribution', (_req: Request, res: Response): void => {
  const data = DataQueryService.getCarbonAchievementDistribution();
  res.json(data);
});

router.get('/carbon/ranking', (req: Request, res: Response): void => {
  const limit = parseInt(req.query.limit as string) || 10;
  const data = DataQueryService.getCarbonRanking(limit);
  res.json(data);
});

export default router;