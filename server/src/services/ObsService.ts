// eslint-disable-next-line @typescript-eslint/no-var-requires
const ObsClient = require('esdk-obs-nodejs');
import { v4 as uuidv4 } from 'uuid';

interface ObsConfig {
  accessKeyId: string;
  secretAccessKey: string;
  endpoint: string;
  bucket: string;
}

class ObsServiceInstance {
  private client: ObsClient | null = null;
  private config: ObsConfig | null = null;
  private publicDomain: string = '';

  init(config: ObsConfig): void {
    this.config = config;
    this.client = new ObsClient({
      access_key_id: config.accessKeyId,
      secret_access_key: config.secretAccessKey,
      server: config.endpoint,
    });
    this.publicDomain = `https://${config.bucket}.${config.endpoint.replace('https://', '').replace('http://', '')}`;
  }

  isConfigured(): boolean {
    return this.client !== null && this.config !== null;
  }

  generateUploadCredential(fileName: string, contentType: string): {
    uploadUrl: string;
    objectKey: string;
    publicUrl: string;
    headers: Record<string, string>;
  } {
    if (!this.client || !this.config) {
      throw new Error('OBS未配置');
    }

    const ext = fileName.includes('.') ? fileName.split('.').pop() : 'jpg';
    const objectKey = `carbonlink/${new Date().toISOString().slice(0, 7)}/${uuidv4()}.${ext}`;

    const signedResult = this.client.createSignedUrlSync({
      Method: 'PUT',
      Bucket: this.config.bucket,
      Key: objectKey,
      Expires: 1800,
      Headers: {
        'Content-Type': contentType,
      },
    });

    const publicUrl = `${this.publicDomain}/${objectKey}`;

    return {
      uploadUrl: signedResult.SignedUrl,
      objectKey,
      publicUrl,
      headers: {
        'Content-Type': contentType,
      },
    };
  }

  deleteObject(objectKey: string): boolean {
    if (!this.client || !this.config) {
      return false;
    }
    try {
      this.client.deleteObject({
        Bucket: this.config.bucket,
        Key: objectKey,
      });
      return true;
    } catch (e) {
      console.error('[ObsService] deleteObject failed:', e);
      return false;
    }
  }

  extractObjectKey(publicUrl: string): string | null {
    if (!this.publicDomain) return null;
    if (publicUrl.startsWith(this.publicDomain + '/')) {
      return publicUrl.substring(this.publicDomain.length + 1);
    }
    return null;
  }
}

export const ObsService = new ObsServiceInstance();

export function initObsFromEnv(): void {
  const accessKeyId = process.env.OBS_ACCESS_KEY_ID || '';
  const secretAccessKey = process.env.OBS_SECRET_ACCESS_KEY || '';
  const endpoint = process.env.OBS_ENDPOINT || '';
  const bucket = process.env.OBS_BUCKET || '';

  if (accessKeyId && secretAccessKey && endpoint && bucket) {
    ObsService.init({ accessKeyId, secretAccessKey, endpoint, bucket });
    console.log('[CarbonLink] OBS已配置, bucket:', bucket);
  } else {
    console.log('[CarbonLink] OBS未配置, 图片上传功能不可用');
    console.log('  需要环境变量: OBS_ACCESS_KEY_ID, OBS_SECRET_ACCESS_KEY, OBS_ENDPOINT, OBS_BUCKET');
  }
}