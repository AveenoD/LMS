import bcrypt from 'bcryptjs';
import * as userRepo from '../db/repositories/userRepo.js';
import * as tenantRepo from '../db/repositories/tenantRepo.js';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/jwt.js';
import ApiError from '../utils/ApiError.js';
import type { PublicUser } from '../db/rows.js';

export interface Branding {
  name: string;
  logoUrl: string | null;
  primaryColor: string | null;
  slug: string;
}

export interface LoginInput {
  slug?: string;
  phone: string;
  password: string;
}

export interface LoginResult {
  accessToken: string;
  refreshToken: string;
  user: PublicUser | null;
  branding: Branding | null;
}

/**
 * Authenticate by (slug + phone + password). slug is omitted for super_admin.
 * Returns tokens, public user, and tenant branding (null for super_admin).
 */
export async function login({ slug, phone, password }: LoginInput): Promise<LoginResult> {
  let tenantId: number | null = null;
  let branding: Branding | null = null;

  if (slug) {
    const tenant = await tenantRepo.findBySlug(slug);
    if (!tenant) throw ApiError.unauthorized('INVALID_CREDENTIALS', 'Invalid login');
    if (!tenant.is_active) throw ApiError.forbidden('TENANT_SUSPENDED', 'This institute is suspended');
    tenantId = tenant.id;
    branding = {
      name: tenant.name,
      logoUrl: tenant.logo_url,
      primaryColor: tenant.primary_color,
      slug: tenant.slug,
    };
  }

  const user = await userRepo.findForLogin({ tenantId, phone });
  if (!user) throw ApiError.unauthorized('INVALID_CREDENTIALS', 'Invalid phone or password');

  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) throw ApiError.unauthorized('INVALID_CREDENTIALS', 'Invalid phone or password');

  const accessToken = signAccessToken({
    userId: user.id,
    tenantId: user.tenant_id,
    role: user.role,
  });
  const refreshToken = signRefreshToken({ userId: user.id });

  return {
    accessToken,
    refreshToken,
    user: userRepo.toPublicUser(user),
    branding,
  };
}

/** Issue a new access token from a valid refresh token. */
export async function refresh({ refreshToken }: { refreshToken: string }): Promise<{ accessToken: string }> {
  let payload;
  try {
    payload = verifyRefreshToken(refreshToken);
  } catch {
    throw ApiError.unauthorized('INVALID_REFRESH', 'Invalid or expired refresh token');
  }
  const user = await userRepo.findById(payload.sub);
  if (!user || !user.is_active) throw ApiError.unauthorized('INVALID_REFRESH', 'User no longer active');

  const accessToken = signAccessToken({
    userId: user.id,
    tenantId: user.tenant_id,
    role: user.role,
  });
  return { accessToken };
}

/** Return current user + branding for /auth/me. */
export async function me({ userId }: { userId: number }): Promise<{ user: PublicUser | null; branding: Branding | null }> {
  const user = await userRepo.findById(userId);
  if (!user) throw ApiError.unauthorized('USER_NOT_FOUND');
  const branding = user.tenant_id ? await tenantRepo.getBranding(user.tenant_id) : null;
  return { user: userRepo.toPublicUser(user), branding };
}
