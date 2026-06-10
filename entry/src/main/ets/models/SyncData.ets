export class SyncData {
  dataType: SyncDataType = SyncDataType.FAVORITES;
  deviceId: string = '';
  timestamp: number = Date.now();
  payload: string = '';
  syncStatus: SyncStatus = SyncStatus.PENDING;
}

export enum SyncDataType {
  FAVORITES = 'FAVORITES',
  BROWSE_HISTORY = 'BROWSE_HISTORY',
  CREDIT_DATA = 'CREDIT_DATA',
  USER_PROFILE = 'USER_PROFILE'
}

export enum SyncStatus {
  PENDING = 'PENDING',
  SYNCED = 'SYNCED',
  FAILED = 'FAILED'
}