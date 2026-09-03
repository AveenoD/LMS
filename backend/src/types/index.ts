/**
 * Shared domain types for the Campus backend.
 */

export type Role = 'super_admin' | 'coaching_admin' | 'teacher' | 'student';

/** The authenticated principal attached to every protected request. */
export interface AuthUser {
  userId: number;
  /** null for super_admin (global, not bound to a tenant). */
  tenantId: number | null;
  role: Role;
}

/** Access-token JWT payload. */
export interface AccessTokenPayload {
  sub: number;
  tenantId: number | null;
  role: Role;
  iat?: number;
  exp?: number;
}

/** Refresh-token JWT payload. */
export interface RefreshTokenPayload {
  sub: number;
  type: 'refresh';
  iat?: number;
  exp?: number;
}
