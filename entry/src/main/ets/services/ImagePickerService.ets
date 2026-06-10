import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';

export class ImagePickerService {
  static async selectFromGallery(maxCount: number): Promise<string[]> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = maxCount;
      const result = await picker.select(options);
      return result.photoUris;
    } catch (e) {
      return [];
    }
  }

  static async takePhoto(): Promise<string | null> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const result = await picker.select(options);
      if (result.photoUris.length > 0) {
        return result.photoUris[0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
