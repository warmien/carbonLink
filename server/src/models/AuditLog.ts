export enum AuditAction {
  LOGIN = 'LOGIN',
  QUERY = 'QUERY',
  EXPORT = 'EXPORT',
  CONFIG_UPDATE = 'CONFIG_UPDATE',
  DELETE = 'DELETE'
}

export interface AuditLog {
  id: number;
  adminId: number;
  action: AuditAction;
  target: string;
  timestamp: number;
  detail: string;
}