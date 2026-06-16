import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'ImagePickerService';
const DOMAIN = 0x0000;

export class ImagePickerService {
  static async selectFromGallery(maxCount: number): Promise<string[]> {
    try {
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const options: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = maxCount;
      const result: photoAccessHelper.PhotoSelectResult = await picker.select(options);
      hilog.info(DOMAIN, TAG, `Selected ${result.photoUris.length} images`);
      for (let i = 0; i < result.photoUris.length; i++) {
        hilog.info(DOMAIN, TAG, `  URI[${i}]: ${result.photoUris[i]}`);
      }
      return result.photoUris;
    } catch (e) {
      hilog.error(DOMAIN, TAG, `selectFromGallery failed: ${(e as Error).message}`);
      return [];
    }
  }

  static async takePhoto(): Promise<string | null> {
    try {
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const options: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const result: photoAccessHelper.PhotoSelectResult = await picker.select(options);
      if (result.photoUris.length > 0) {
        hilog.info(DOMAIN, TAG, `Photo URI: ${result.photoUris[0]}`);
        return result.photoUris[0];
      }
      return null;
    } catch (e) {
      hilog.error(DOMAIN, TAG, `takePhoto failed: ${(e as Error).message}`);
      return null;
    }
  }
}
