import type { Request } from 'express';
import type { AuthUser } from '../types/index.js';
import ApiError from '../utils/ApiError.js';

/**
 * Returns the authenticated user, guaranteed non-null.
 * Controllers behind authMiddleware always have req.user set; this narrows the
 * optional type and throws defensively if the middleware order is ever wrong.
 */
export function requireUser(req: Request): AuthUser {
  if (!req.user) throw ApiError.unauthorized('NO_USER');
  return req.user;
}

/** Tenant id for tenant-bound roles (coaching_admin / teacher / student). */
export function tenantId(req: Request): number {
  const user = requireUser(req);
  if (user.tenantId == null) throw ApiError.forbidden('NO_TENANT', 'User is not bound to a tenant');
  return user.tenantId;
}

/** Authenticated user's id. */
export function userId(req: Request): number {
  return requireUser(req).userId;
}
