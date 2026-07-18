import { query } from '../../config/db.js';
import type { UserRow, PublicUser } from '../rows.js';

/**
 * Find a login user by phone alone. Phone is globally unique across every
 * tenant (see migration 0003) — login no longer needs an institute slug to
 * disambiguate.
 */
export async function findForLogin(phone: string): Promise<UserRow | null> {
  // Fetch regardless of is_active so we can return a proper SUSPENDED error
  const { rows } = await query<UserRow>(
    `SELECT * FROM users WHERE phone = $1`,
    [phone]
  );
  return rows[0] || null;
}

export async function findById(id: number): Promise<UserRow | null> {
  const { rows } = await query<UserRow>(`SELECT * FROM users WHERE id = $1`, [id]);
  return rows[0] || null;
}

/** Public-safe projection of a user row. */
export function toPublicUser(u: UserRow | null | undefined): PublicUser | null {
  if (!u) return null;
  return {
    id: u.id,
    role: u.role,
    tenantId: u.tenant_id,
    fullName: u.full_name,
    phone: u.phone,
    email: u.email,
  };
}
