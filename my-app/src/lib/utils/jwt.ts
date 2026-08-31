import jwt from 'jsonwebtoken';
import type { SignOptions } from 'jsonwebtoken';
import env from '../config/env';
import type { AccessTokenPayload, RefreshTokenPayload, Role } from '../types/index';

/**
 * Access token payload: { sub: userId, tenantId, role }
 * tenantId is null for super_admin.
 * Ported verbatim from the Express backend's src/utils/jwt.ts.
 */
export function signAccessToken({
  userId,
  tenantId,
  role,
}: {
  userId: number;
  tenantId: number | null;
  role: Role;
}): string {
  return jwt.sign(
    { sub: userId, tenantId: tenantId ?? null, role },
    env.jwt.accessSecret,
    { expiresIn: env.jwt.accessTtl } as SignOptions
  );
}

export function signRefreshToken({ userId }: { userId: number }): string {
  return jwt.sign({ sub: userId, type: 'refresh' }, env.jwt.refreshSecret, {
    expiresIn: env.jwt.refreshTtl,
  } as SignOptions);
}

export function verifyAccessToken(token: string): AccessTokenPayload {
  return jwt.verify(token, env.jwt.accessSecret) as unknown as AccessTokenPayload;
}

export function verifyRefreshToken(token: string): RefreshTokenPayload {
  return jwt.verify(token, env.jwt.refreshSecret) as unknown as RefreshTokenPayload;
}
