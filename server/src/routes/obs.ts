import { Router, Request, Response } from 'express';
import { userAuthMiddleware } from '../middleware/userAuth';
import { ObsService } from '../services/ObsService';

const router = Router();

router.post('/upload-credential', userAuthMiddleware, (req: Request, res: Response): void => {
  if (!ObsService.isConfigured()) {
    res.status(503).json({ code: 50301, message: 'OBS未配置，图片上传不可用' });
    return;
  }

  const { fileName, contentType } = req.body;
  if (!fileName || !contentType) {
    res.status(400).json({ code: 40001, message: '缺少fileName或contentType参数' });
    return;
  }

  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/heif'];
  if (!allowedTypes.includes(contentType)) {
    res.status(400).json({ code: 40002, message: '不支持的图片格式，仅支持jpeg/png/webp/heif' });
    return;
  }

  try {
    const credential = ObsService.generateUploadCredential(fileName, contentType);
    res.json({
      code: 0,
      message: 'success',
      data: {
        uploadUrl: credential.uploadUrl,
        objectKey: credential.objectKey,
        publicUrl: credential.publicUrl,
        headers: credential.headers,
      },
    });
  } catch (e) {
    res.status(500).json({ code: 50001, message: '生成上传凭证失败' });
  }
});

router.post('/batch-credentials', userAuthMiddleware, (req: Request, res: Response): void => {
  if (!ObsService.isConfigured()) {
    res.status(503).json({ code: 50301, message: 'OBS未配置，图片上传不可用' });
    return;
  }

  const { files } = req.body as { files: { fileName: string; contentType: string }[] };
  if (!files || !Array.isArray(files) || files.length === 0) {
    res.status(400).json({ code: 40001, message: '缺少files参数' });
    return;
  }

  if (files.length > 9) {
    res.status(400).json({ code: 40003, message: '单次最多9张图片' });
    return;
  }

  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/heif'];
  try {
    const credentials = files.map((file) => {
      if (!allowedTypes.includes(file.contentType)) {
        throw new Error('不支持的图片格式');
      }
      return ObsService.generateUploadCredential(file.fileName, file.contentType);
    });

    res.json({
      code: 0,
      message: 'success',
      data: {
        items: credentials.map((c) => ({
          uploadUrl: c.uploadUrl,
          objectKey: c.objectKey,
          publicUrl: c.publicUrl,
          headers: c.headers,
        })),
        count: credentials.length,
      },
    });
  } catch (e) {
    res.status(400).json({ code: 40002, message: (e as Error).message });
  }
});

export default router;