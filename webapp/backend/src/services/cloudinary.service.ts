import { v2 as cloudinary } from 'cloudinary';
import { env } from '../config/env.js';

// Configure cloudinary only if variables are present (to avoid crashing if not set yet)
if (env.CLOUD_NAME && env.API_KEY && env.API_SECRET) {
  cloudinary.config({
    cloud_name: env.CLOUD_NAME,
    api_key: env.API_KEY,
    api_secret: env.API_SECRET,
  });
}

export function generateSignature(folder: string = 'edtech_os') {
  const timestamp = Math.round(new Date().getTime() / 1000);
  const signature = cloudinary.utils.api_sign_request(
    {
      timestamp,
      folder,
    },
    env.API_SECRET || ''
  );

  return {
    timestamp,
    signature,
    cloudName: env.CLOUD_NAME,
    apiKey: env.API_KEY,
    folder,
  };
}
