export enum AdminRole {
  SUPER_ADMIN = 'SUPER_ADMIN',
  DATA_ANALYST = 'DATA_ANALYST',
  OPERATOR = 'OPERATOR'
}

export enum AdminStatus {
  ACTIVE = 'ACTIVE',
  LOCKED = 'LOCKED'
}

export interface AdminAccount {
  id: number;
  username: string;
  password: string;
  role: AdminRole;
  status: AdminStatus;
  lastLoginTime: number | null;
  loginFailCount: number;
  lockedUntil: number | null;
}