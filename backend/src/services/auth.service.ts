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
 * Authenticate by phone + password alone. Phone is globally unique across
 * every tenant (see migration 0003), so no institute slug is needed to
 * disambiguate — one login form for every role.
 */
export async function login({ phone, password }: LoginInput): Promise<LoginResult> {
  const user = await userRepo.findForLogin(phone);
  if (!user) throw ApiError.unauthorized('INVALID_CREDENTIALS', 'Invalid phone or password');

  // Explicitly check suspension before password — gives a clear error
  if (!user.is_active) throw ApiError.forbidden('USER_SUSPENDED', 'Your ID has been suspended. Please contact your institute.');

  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) throw ApiError.unauthorized('INVALID_CREDENTIALS', 'Invalid phone or password');

  let branding: Branding | null = null;
  if (user.tenant_id) {
    const tenant = await tenantRepo.findById(user.tenant_id);
    if (!tenant) throw ApiError.unauthorized('INVALID_CREDENTIALS', 'Invalid login');
    if (!tenant.is_active) throw ApiError.forbidden('TENANT_SUSPENDED', 'This institute is suspended');
    branding = {
      name: tenant.name,
      logoUrl: tenant.logo_url,
      primaryColor: tenant.primary_color,
      slug: tenant.slug,
    };
  }

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

/** Sets the caller's own profile photo — any role, no ownership check
 *  needed beyond "it's their own userId" (sourced from the JWT). */
export async function updateAvatar({ userId, avatarUrl }: { userId: number; avatarUrl: string }): Promise<PublicUser> {
  const user = await userRepo.updateAvatarUrl(userId, avatarUrl);
  if (!user) throw ApiError.notFound('USER_NOT_FOUND');
  return user;
}
