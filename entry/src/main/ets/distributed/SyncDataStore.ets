import { distributedKVStore } from '@kit.ArkData';
import { SyncStatus } from '../models/SyncData';

export class SyncDataStore {
  private kvManager: distributedKVStore.KVManager | null = null;
  private kvStore: distributedKVStore.SingleKVStore | null = null;
  private storeId: string = '';
  private syncStatus: SyncStatus = SyncStatus.PENDING;
  private localCache: Map<string, string> = new Map();

  async init(context: Context, storeId: string): Promise<void> {
    this.storeId = storeId;
    try {
      const config: distributedKVStore.KVManagerConfig = {
        context: context,
        bundleName: 'com.carbonlink.entry'
      };
      this.kvManager = distributedKVStore.createKVManager(config);
      const storeConfig: distributedKVStore.StoreConfig = {
        securityLevel: distributedKVStore.SecurityLevel.S1
      };
      this.kvStore = await this.kvManager.getKVStore(storeId, storeConfig);
      this.syncStatus = SyncStatus.SYNCED;
    } catch (e) {
      this.syncStatus = SyncStatus.FAILED;
    }
  }

  async put(key: string, value: string): Promise<void> {
    this.localCache.set(key, value);
    if (this.kvStore) {
      try {
        this.syncStatus = SyncStatus.PENDING;
        await this.kvStore.put(key, value);
        this.syncStatus = SyncStatus.SYNCED;
      } catch (e) {
        this.syncStatus = SyncStatus.FAILED;
      }
    }
  }

  async get(key: string): Promise<string> {
    const cached = this.localCache.get(key);
    if (cached) return cached;
    if (this.kvStore) {
      try {
        const result = await this.kvStore.get(key);
        const val = typeof result === 'string' ? result : String(result);
        this.localCache.set(key, val);
        return val;
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  getSyncStatus(): SyncStatus {
    return this.syncStatus;
  }
}