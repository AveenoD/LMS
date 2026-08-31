import { google } from 'googleapis';
import env from './env.js';

/** A fresh, unauthenticated OAuth2 client for the shared Web app credentials.
 *  Callers attach per-teacher tokens (via setCredentials) before use. */
export function createOAuth2Client() {
  return new google.auth.OAuth2(env.googleOAuth.clientId, env.googleOAuth.clientSecret);
}
