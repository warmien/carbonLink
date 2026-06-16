import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { HttpService, ApiResponse } from './HttpService';

export class UploadCredential {
  uploadUrl: string = '';
  objectKey: string = '';
  publicUrl: string = '';
  headers: Record<string, string> = {};
}

export class FileInfo {
  fileName: string = '';
  contentType: string = '';
}

export class ObsService {
  private static context: common.UIAbilityContext | null = null;

  static init(context: common.UIAbilityContext): void {
    ObsService.context = context;
    console.info('[ObsService] initialized with cacheDir: ' + context.cacheDir);
  }

  private static copyToSandbox(mediaUri: string): string | null {
    try {
      if (!ObsService.context) {
        console.error('[ObsService] copyToSandbox: context not initialized');
        return null;
      }
      const fileName: string = mediaUri.split('/').pop() || 'image.jpg';
      const sandboxPath: string = ObsService.context.cacheDir + '/obs_upload_' + Date.now() + '_' + fileName;
      console.info('[ObsService] copyToSandbox: ' + mediaUri + ' -> ' + sandboxPath);

      const srcFile: fs.File = fs.openSync(mediaUri, fs.OpenMode.READ_ONLY);
      const srcStat: fs.Stat = fs.statSync(srcFile.fd);
      console.info('[ObsService] copyToSandbox: src size=' + srcStat.size);
      const buffer: ArrayBuffer = new ArrayBuffer(srcStat.size);
      fs.readSync(srcFile.fd, buffer);
      fs.closeSync(srcFile);

      const destFile: fs.File = fs.openSync(sandboxPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(destFile.fd, buffer);
      fs.closeSync(destFile);

      const destStat: fs.Stat = fs.statSync(sandboxPath);
      console.info('[ObsService] copyToSandbox success, dest size=' + destStat.size);
      return sandboxPath;
    } catch (err) {
      console.error('[ObsService] copyToSandbox failed: ' + (err as Error).message);
      return null;
    }
  }

  static async getUploadCredential(fileName: string, contentType: string): Promise<UploadCredential | null> {
    const reqBody: Record<string, string> = {};
    reqBody['fileName'] = fileName;
    reqBody['contentType'] = contentType;
    console.info('[ObsService] getUploadCredential: ' + fileName + ' ' + contentType);
    const resp: ApiResponse = await HttpService.POST('/obs/upload-credential', reqBody);
    console.info('[ObsService] getUploadCredential response: code=' + resp.code + ' msg=' + resp.message);
    if (resp.code === 0 && resp.data !== null) {
      const data: Record<string, string | number | object> = resp.data;
      const credential: UploadCredential = new UploadCredential();
      credential.uploadUrl = data['uploadUrl'] as string;
      credential.objectKey = data['objectKey'] as string;
      credential.publicUrl = data['publicUrl'] as string;
      credential.headers = data['headers'] as Record<string, string>;
      return credential;
    }
    return null;
  }

  static async getBatchCredentials(files: FileInfo[]): Promise<UploadCredential[] | null> {
    const filesData: Record<string, string>[] = [];
    for (let i = 0; i < files.length; i++) {
      const item: Record<string, string> = {};
      item['fileName'] = files[i].fileName;
      item['contentType'] = files[i].contentType;
      filesData.push(item);
    }
    const reqBody: Record<string, string | number | object> = {};
    reqBody['files'] = filesData as object;
    console.info('[ObsService] getBatchCredentials: ' + files.length + ' files');
    const resp: ApiResponse = await HttpService.POST('/obs/batch-credentials', reqBody);
    console.info('[ObsService] getBatchCredentials response: code=' + resp.code + ' msg=' + resp.message);
    if (resp.code === 0 && resp.data !== null) {
      const dataObj: Record<string, string | number | object> = resp.data;
      const itemsObj: string | number | object = dataObj['items'];
      const arr: Record<string, string | number | object>[] = itemsObj as Record<string, string | number | object>[];
      const credentials: UploadCredential[] = [];
      for (let i = 0; i < arr.length; i++) {
        const item: Record<string, string | number | object> = arr[i];
        const c: UploadCredential = new UploadCredential();
        c.uploadUrl = item['uploadUrl'] as string;
        c.objectKey = item['objectKey'] as string;
        c.publicUrl = item['publicUrl'] as string;
        c.headers = item['headers'] as Record<string, string>;
        credentials.push(c);
      }
      console.info('[ObsService] getBatchCredentials: got ' + credentials.length + ' credentials');
      return credentials;
    }
    console.error('[ObsService] getBatchCredentials failed');
    return null;
  }

  static async uploadFileToObs(localUri: string, credential: UploadCredential): Promise<boolean> {
    let sandboxPath: string | null = null;
    try {
      console.info('[ObsService] uploadFileToObs: uri=' + localUri);
      console.info('[ObsService] uploadFileToObs: uploadUrl=' + credential.uploadUrl.substring(0, 80) + '...');
      console.info('[ObsService] uploadFileToObs: publicUrl=' + credential.publicUrl);

      const isMediaUri: boolean = localUri.startsWith('file://media/') || localUri.startsWith('content://');
      let filePath: string = localUri;

      if (isMediaUri) {
        sandboxPath = ObsService.copyToSandbox(localUri);
        if (!sandboxPath) {
          console.error('[ObsService] uploadFileToObs: copyToSandbox failed');
          return false;
        }
        filePath = sandboxPath;
      }

      const httpRequest: http.HttpRequest = http.createHttp();
      const file: fs.File = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat: fs.Stat = fs.statSync(filePath);
      console.info('[ObsService] uploadFileToObs: file size=' + stat.size);
      const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      const headers: Record<string, string> = {};
      headers['Content-Type'] = credential.headers['Content-Type'] || 'image/jpeg';

      let uploadUrl: string = credential.uploadUrl;
      if (uploadUrl.includes('.myhuaweicloud.com:443')) {
        uploadUrl = uploadUrl.replace('.myhuaweicloud.com:443', '.myhuaweicloud.com');
      }

      console.info('[ObsService] uploadFileToObs: sending PUT request...');
      const response: http.HttpResponse = await httpRequest.request(uploadUrl, {
        method: http.RequestMethod.PUT,
        header: headers,
        extraData: buffer,
        connectTimeout: 30000,
        readTimeout: 60000,
      });

      console.info('[ObsService] uploadFileToObs: response code=' + response.responseCode);
      httpRequest.destroy();

      if (sandboxPath !== null) {
        try {
          fs.unlinkSync(sandboxPath);
        } catch (_) {
        }
      }

      return response.responseCode === 200;
    } catch (err) {
      console.error('[ObsService] uploadFileToObs failed: ' + (err as Error).message);
      if (sandboxPath !== null) {
        try {
          fs.unlinkSync(sandboxPath);
        } catch (_) {
        }
      }
      return false;
    }
  }

  static async uploadImage(localUri: string): Promise<string | null> {
    const fileName: string = localUri.split('/').pop() || 'image.jpg';
    const ext: string = fileName.includes('.') ? fileName.split('.').pop()!.toLowerCase() : 'jpg';
    const contentTypeMap: Record<string, string> = {};
    contentTypeMap['jpg'] = 'image/jpeg';
    contentTypeMap['jpeg'] = 'image/jpeg';
    contentTypeMap['png'] = 'image/png';
    contentTypeMap['webp'] = 'image/webp';
    contentTypeMap['heif'] = 'image/heif';
    const contentType: string = contentTypeMap[ext] || 'image/jpeg';

    const credential: UploadCredential | null = await ObsService.getUploadCredential(fileName, contentType);
    if (!credential) {
      return null;
    }

    const success: boolean = await ObsService.uploadFileToObs(localUri, credential);
    if (success) {
      return credential.publicUrl;
    }
    return null;
  }

  static async uploadImages(localUris: string[]): Promise<string[]> {
    if (localUris.length === 0) {
      return [];
    }

    console.info('[ObsService] uploadImages: ' + localUris.length + ' images');

    const fileInfos: FileInfo[] = [];
    const contentTypeMap: Record<string, string> = {};
    contentTypeMap['jpg'] = 'image/jpeg';
    contentTypeMap['jpeg'] = 'image/jpeg';
    contentTypeMap['png'] = 'image/png';
    contentTypeMap['webp'] = 'image/webp';
    contentTypeMap['heif'] = 'image/heif';

    for (let i = 0; i < localUris.length; i++) {
      const uri: string = localUris[i];
      const fileName: string = uri.split('/').pop() || 'image.jpg';
      const ext: string = fileName.includes('.') ? fileName.split('.').pop()!.toLowerCase() : 'jpg';
      const contentType: string = contentTypeMap[ext] || 'image/jpeg';
      const info: FileInfo = new FileInfo();
      info.fileName = fileName;
      info.contentType = contentType;
      fileInfos.push(info);
    }

    const credentials: UploadCredential[] | null = await ObsService.getBatchCredentials(fileInfos);
    if (!credentials) {
      console.error('[ObsService] uploadImages: getBatchCredentials returned null');
      return [];
    }

    const publicUrls: string[] = [];
    for (let i = 0; i < localUris.length; i++) {
      const success: boolean = await ObsService.uploadFileToObs(localUris[i], credentials[i]);
      if (success) {
        publicUrls.push(credentials[i].publicUrl);
        console.info('[ObsService] uploadImages: image ' + i + ' uploaded -> ' + credentials[i].publicUrl);
      } else {
        console.warn('[ObsService] uploadImages: image ' + i + ' upload FAILED');
      }
    }
    console.info('[ObsService] uploadImages: ' + publicUrls.length + '/' + localUris.length + ' succeeded');
    return publicUrls;
  }
}
