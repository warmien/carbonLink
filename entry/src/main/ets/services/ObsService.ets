import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
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
  static async getUploadCredential(fileName: string, contentType: string): Promise<UploadCredential | null> {
    const reqBody: Record<string, string> = {};
    reqBody['fileName'] = fileName;
    reqBody['contentType'] = contentType;
    const resp: ApiResponse = await HttpService.POST('/obs/upload-credential', reqBody);
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
    const reqBody: Record<string, object> = {};
    reqBody['files'] = filesData as object;
    const resp: ApiResponse = await HttpService.POST('/obs/batch-credentials', reqBody as Record<string, string | number | object>);
    if (resp.code === 0 && resp.data !== null) {
      const dataObj: Record<string, string | number | object> = resp.data;
      const arrData: string | number | object = dataObj['data'] !== undefined ? dataObj['data'] : resp.data;
      const arr: Record<string, string | number | object>[] = arrData as Record<string, string | number | object>[];
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
      return credentials;
    }
    return null;
  }

  static async uploadFileToObs(localUri: string, credential: UploadCredential): Promise<boolean> {
    try {
      const httpRequest: http.HttpRequest = http.createHttp();
      const file: fs.File = fs.openSync(localUri, fs.OpenMode.READ_ONLY);
      const stat: fs.Stat = fs.statSync(localUri);
      const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      const headers: Record<string, string> = {};
      headers['Content-Type'] = credential.headers['Content-Type'] || 'image/jpeg';

      const response: http.HttpResponse = await httpRequest.request(credential.uploadUrl, {
        method: http.RequestMethod.PUT,
        header: headers,
        extraData: buffer,
        connectTimeout: 30000,
        readTimeout: 60000,
      });

      httpRequest.destroy();
      return response.responseCode === 200;
    } catch (err) {
      console.error(`[ObsService] uploadFileToObs failed: ${(err as Error).message}`);
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
      return [];
    }

    const publicUrls: string[] = [];
    for (let i = 0; i < localUris.length; i++) {
      const success: boolean = await ObsService.uploadFileToObs(localUris[i], credentials[i]);
      if (success) {
        publicUrls.push(credentials[i].publicUrl);
      }
    }
    return publicUrls;
  }
}
