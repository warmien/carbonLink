import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

export class ImageUtils {
  static async checkImageSize(uri: string, maxSizeMB: number): Promise<boolean> {
    try {
      const stat = fs.statSync(uri);
      return stat.size <= maxSizeMB * 1024 * 1024;
    } catch (e) {
      return false;
    }
  }

  static async imageToBase64(uri: string): Promise<string> {
    try {
      const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(uri);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      const helper = new util.Base64Helper();
      const uint8Array = new Uint8Array(buffer);
      return helper.encodeToStringSync(uint8Array);
    } catch (e) {
      return '';
    }
  }

  static getSupportedFormats(): string[] {
    return ['jpeg', 'jpg', 'png', 'heif', 'webp'];
  }
}
