import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import env from '@/lib/config/env';

/**
 * CORS for every /api/* route. Ported from the Express backend's global
 * `cors()` middleware (backend/src/app.ts) — same wildcard-vs-allowlist
 * behavior: CORS_ORIGINS="*" (or unset) reflects any origin WITHOUT
 * credentials; an explicit comma-separated list reflects only matching
 * origins WITH credentials. Mirrors env.ts's own production guard, which
 * refuses to boot with a wildcard in prod.
 */
const isWildcard = env.corsOrigins.includes('*');

const corsHeaders = {
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export function proxy(request: NextRequest) {
  const origin = request.headers.get('origin') ?? '';
  const isAllowedOrigin = isWildcard || env.corsOrigins.includes(origin);

  if (request.method === 'OPTIONS') {
    const preflightHeaders: Record<string, string> = { ...corsHeaders };
    if (isAllowedOrigin) {
      preflightHeaders['Access-Control-Allow-Origin'] = isWildcard ? '*' : origin;
      if (!isWildcard) preflightHeaders['Access-Control-Allow-Credentials'] = 'true';
    }
    return new NextResponse(null, { status: 204, headers: preflightHeaders });
  }

  const response = NextResponse.next();
  if (isAllowedOrigin) {
    response.headers.set('Access-Control-Allow-Origin', isWildcard ? '*' : origin);
    if (!isWildcard) response.headers.set('Access-Control-Allow-Credentials', 'true');
  }
  Object.entries(corsHeaders).forEach(([key, value]) => response.headers.set(key, value));
  return response;
}

export const config = {
  matcher: '/api/:path*',
};
