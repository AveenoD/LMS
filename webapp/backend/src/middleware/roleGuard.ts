import type { Request, Response, NextFunction, RequestHandler } from 'express';
import ApiError from '../utils/ApiError.js';
import type { Role } from '../types/index.js';

/**
 * Restricts a route to the given roles.
 * Usage: router.get('/x', authMiddleware, roleGuard('coaching_admin'), handler)
 */
export const roleGuard =
  (...roles: Role[]): RequestHandler =>
  (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) throw ApiError.unauthorized('NO_USER');
    if (!roles.includes(req.user.role)) {
      throw ApiError.forbidden('FORBIDDEN', 'You do not have access to this resource');
    }
    // Non-super-admin roles must be bound to a tenant.
    if (req.user.role !== 'super_admin' && !req.user.tenantId) {
      throw ApiError.forbidden('NO_TENANT', 'User is not bound to a tenant');
    }
    next();
  };

export default roleGuard;
