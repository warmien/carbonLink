declare module 'esdk-obs-nodejs' {
  interface ObsClientConfig {
    access_key_id: string;
    secret_access_key: string;
    server: string;
  }

  interface CreateSignedUrlResult {
    SignedUrl: string;
  }

  interface ObsClient {
    createSignedUrlSync(params: {
      Method: string;
      Bucket: string;
      Key: string;
      Expires: number;
      Headers?: Record<string, string>;
    }): CreateSignedUrlResult;

    deleteObject(params: {
      Bucket: string;
      Key: string;
    }): void;
  }

  class ObsClient {
    constructor(config: ObsClientConfig);
  }

  export default ObsClient;
}