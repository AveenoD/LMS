import type { NextRequest } from 'next/server';
import { verifyAccessToken } from '../utils/jwt';
import ApiError from '../utils/ApiError';
import type { AuthUser, Role } from '../types/index';

/**
 * Combines the Express backend's authMiddleware + roleGuard + helpers.ts
 * into one call, since Next.js route handlers have no middleware chain —
 * each handler calls this itself at the top, same as
 * `router.use(authMiddleware, roleGuard('teacher'))` did for a whole
 * Express router.
 *
 * Usage in a route handler:
 *   const user = requireAuth(req, 'coaching_admin');
 *   // user.userId, user.tenantId, user.role — same shape as req.user before.
 *
 * Call with no roles to just require *some* valid authenticated user
 * (mirrors Express routes that only had authMiddleware, no roleGuard).
 */
export function requireAuth(req: NextRequest, ...roles: Role[]): AuthUser {
  const header = req.headers.get('authorization') || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) throw ApiError.unauthorized('NO_TOKEN', 'Authorization token missing');

  let user: AuthUser;
  try {
    const payload = verifyAccessToken(token);
    user = {
      userId: payload.sub,
      tenantId: payload.tenantId ?? null,
      role: payload.role,
    };
  } catch (err) {
    if (err instanceof Error && err.name === 'TokenExpiredError') {
      throw ApiError.unauthorized('TOKEN_EXPIRED', 'Access token expired');
    }
    throw ApiError.unauthorized('INVALID_TOKEN', 'Invalid access token');
  }

  if (roles.length > 0) {
    if (!roles.includes(user.role)) {
      throw ApiError.forbidden('FORBIDDEN', 'You do not have access to this resource');
    }
    // Non-super-admin roles must be bound to a tenant.
    if (user.role !== 'super_admin' && !user.tenantId) {
      throw ApiError.forbidden('NO_TENANT', 'User is not bound to a tenant');
    }
  }

  return user;
}

/** Tenant id for tenant-bound roles (coaching_admin / teacher / student). */
export function requireTenantId(user: AuthUser): number {
  if (user.tenantId == null) throw ApiError.forbidden('NO_TENANT', 'User is not bound to a tenant');
  return user.tenantId;
}
