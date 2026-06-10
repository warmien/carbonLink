import { Router, Request, Response } from 'express';
import { DataExportService, ExportFormat } from '../services/DataExportService';
import { authMiddleware } from '../middleware/auth';

const router = Router();

router.use(authMiddleware);

router.get('/:reportType', (req: Request, res: Response): void => {
  const { reportType } = req.params;
  const format = (req.query.format as ExportFormat) || 'xlsx';
  const { startDate, endDate } = req.query;

  if (format !== 'csv' && format !== 'xlsx') {
    res.status(400).json({ error: '不支持的导出格式，请使用 csv 或 xlsx' });
    return;
  }

  try {
    const buffer = DataExportService.exportReport(reportType, format, startDate as string, endDate as string);
    const filename = DataExportService.getFilename(reportType, format);
    const mimeType = format === 'csv' ? 'text/csv' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    res.setHeader('Content-Type', mimeType);
    res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(filename)}"`);
    res.send(buffer);
  } catch (e) {
    res.status(500).json({ error: '导出失败' });
  }
});

export default router;