import { SyncDataStore } from './SyncDataStore';
import { SyncDataType, SyncStatus } from '../models/SyncData';

export class DistributedDataManager {
  private static stores: Map<string, SyncDataStore> = new Map();
  private static initialized: boolean = false;

  static async init(context: Context): Promise<void> {
    if (DistributedDataManager.initialized) return;
    const types = [SyncDataType.USER_PROFILE, SyncDataType.FAVORITES,
      SyncDataType.BROWSE_HISTORY, SyncDataType.CREDIT_DATA];
    for (let i = 0; i < types.length; i++) {
      const store = new SyncDataStore();
      await store.init(context, 'carbonlink_' + types[i]);
      DistributedDataManager.stores.set(types[i], store);
    }
    DistributedDataManager.initialized = true;
  }

  static async put(dataType: SyncDataType, key: string, value: string): Promise<void> {
    const store = DistributedDataManager.stores.get(dataType);
    if (store) {
      await store.put(key, value);
    }
  }

  static async get(dataType: SyncDataType, key: string): Promise<string> {
    const store = DistributedDataManager.stores.get(dataType);
    if (store) {
      return await store.get(key);
    }
    return '';
  }

  static getSyncStatus(dataType: SyncDataType): SyncStatus {
    const store = DistributedDataManager.stores.get(dataType);
    if (store) {
      return store.getSyncStatus();
    }
    return SyncStatus.FAILED;
  }
}