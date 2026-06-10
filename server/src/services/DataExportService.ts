import { DataQueryService } from './DataQueryService';
import XLSX from 'xlsx';

export type ExportFormat = 'csv' | 'xlsx';

export class DataExportService {
  static exportReport(reportType: string, format: ExportFormat, startDate?: string, endDate?: string): Buffer {
    let data: Record<string, unknown>;

    switch (reportType) {
      case 'user_growth':
        data = DataQueryService.getUserGrowth(startDate, endDate);
        break;
      case 'product_trend':
        data = DataQueryService.getProductTrend(startDate, endDate);
        break;
      case 'carbon_credit':
        data = DataQueryService.getCarbonCreditTrend(startDate, endDate);
        break;
      case 'transaction':
        data = DataQueryService.getProductTransaction();
        break;
      default:
        data = DataQueryService.getDashboardOverview();
    }

    const flatData = DataExportService.flattenData(data);

    if (format === 'csv') {
      return DataExportService.toCSV(flatData);
    }
    return DataExportService.toXLSX(flatData);
  }

  private static flattenData(data: Record<string, unknown>): Record<string, unknown>[] {
    if (Array.isArray(data)) {
      return data as Record<string, unknown>[];
    }

    const trend = data.trend || data.ranking || data.distribution || data.achievements;
    if (Array.isArray(trend)) {
      return trend as Record<string, unknown>[];
    }

    return [data];
  }

  private static toCSV(rows: Record<string, unknown>[]): Buffer {
    if (rows.length === 0) {
      return Buffer.from('', 'utf-8');
    }

    const headers = Object.keys(rows[0]);
    const lines: string[] = [headers.join(',')];

    for (const row of rows) {
      const values = headers.map(h => {
        const val = row[h];
        const str = val === null || val === undefined ? '' : String(val);
        return str.includes(',') || str.includes('"') ? `"${str.replace(/"/g, '""')}"` : str;
      });
      lines.push(values.join(','));
    }

    return Buffer.from('\uFEFF' + lines.join('\n'), 'utf-8');
  }

  private static toXLSX(rows: Record<string, unknown>[]): Buffer {
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.json_to_sheet(rows);
    XLSX.utils.book_append_sheet(wb, ws, 'Sheet1');
    const buf = XLSX.write(wb, { type: 'buffer', bookType: 'xlsx' });
    return Buffer.from(buf);
  }

  static getFilename(reportType: string, format: ExportFormat): string {
    const dateStr = new Date().toISOString().slice(0, 10);
    const ext = format === 'csv' ? 'csv' : 'xlsx';
    return `carbonlink_${reportType}_${dateStr}.${ext}`;
  }
}