import { v2 as cloudinary } from 'cloudinary';
import { env } from '../config/env.js';

// Configure cloudinary only if variables are present (to avoid crashing if not set yet)
if (env.cloudinary.cloudName && env.cloudinary.apiKey && env.cloudinary.apiSecret) {
  cloudinary.config({
    cloud_name: env.cloudinary.cloudName,
    api_key: env.cloudinary.apiKey,
    api_secret: env.cloudinary.apiSecret,
  });
}

export function generateSignature(folder: string = 'campus') {
  const timestamp = Math.round(new Date().getTime() / 1000);
  const signature = cloudinary.utils.api_sign_request(
    {
      timestamp,
      folder,
    },
    env.cloudinary.apiSecret || ''
  );

  return {
    timestamp,
    signature,
    cloudName: env.cloudinary.cloudName,
    apiKey: env.cloudinary.apiKey,
    folder,
  };
}
