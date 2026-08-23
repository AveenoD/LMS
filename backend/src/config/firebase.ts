import { initializeApp, cert, getApps, type App } from 'firebase-admin/app';
import { getMessaging, type Messaging } from 'firebase-admin/messaging';
import env from './env.js';
import logger from '../utils/logger.js';

let app: App | null = null;

function getApp(): App | null {
  if (!env.firebase.enabled) return null;
  if (app) return app;

  app = getApps()[0] ?? initializeApp({
    credential: cert({
      projectId: env.firebase.projectId,
      clientEmail: env.firebase.clientEmail,
      privateKey: env.firebase.privateKey,
    }),
  });
  return app;
}

/** Returns the Firebase Messaging client, or null if push isn't configured. */
export function getFirebaseMessaging(): Messaging | null {
  const a = getApp();
  if (!a) {
    logger.debug('Push skipped: Firebase not configured (FIREBASE_* env vars unset)');
    return null;
  }
  return getMessaging(a);
}
