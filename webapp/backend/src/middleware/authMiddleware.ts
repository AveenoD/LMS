import type { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/jwt.js';
import ApiError from '../utils/ApiError.js';

/**
 * Verifies the Bearer access token and attaches:
 *   req.user = { userId, tenantId, role }
 * tenantId is read ONLY from the token — never from the request body —
 * which is the core of our tenant-isolation guarantee.
 */
export function authMiddleware(req: Request, _res: Response, next: NextFunction): void {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) throw ApiError.unauthorized('NO_TOKEN', 'Authorization token missing');

  try {
    const payload = verifyAccessToken(token);
    req.user = {
      userId: payload.sub,
      tenantId: payload.tenantId ?? null,
      role: payload.role,
    };
    next();
  } catch (err) {
    if (err instanceof Error && err.name === 'TokenExpiredError') {
      throw ApiError.unauthorized('TOKEN_EXPIRED', 'Access token expired');
    }
    throw ApiError.unauthorized('INVALID_TOKEN', 'Invalid access token');
  }
}

export default authMiddleware;
