import { NextRequest } from 'next/server';
import env from '../config/env';
import ApiError from '../utils/ApiError';

/**
 * Cron endpoints have no user session — they're hit by an external scheduler
 * (cron-job.org / Vercel Cron), so auth is a single shared secret instead of
 * a JWT. Accepts either `Authorization: Bearer <secret>` (cron-job.org custom
 * headers) or `?secret=<secret>` (simplest to configure on either scheduler).
 */
export function requireCronSecret(req: NextRequest): void {
  if (!env.cron.secret) {
    throw ApiError.badRequest('CRON_NOT_CONFIGURED', 'CRON_SECRET is not set');
  }
  const authHeader = req.headers.get('authorization');
  const bearer = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;
  const queryParam = req.nextUrl.searchParams.get('secret');
  const provided = bearer ?? queryParam;

  if (provided !== env.cron.secret) {
    throw ApiError.unauthorized('INVALID_CRON_SECRET');
  }
}
