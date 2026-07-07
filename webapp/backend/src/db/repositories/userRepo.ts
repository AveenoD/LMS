import { query } from '../../config/db.js';
import type { UserRow, PublicUser } from '../rows.js';

/**
 * Find a login user. For super_admin, tenantId is null (slug omitted).
 * For tenant users, we match on (tenant_id, phone).
 */
export async function findForLogin({
  tenantId,
  phone,
}: {
  tenantId: number | null;
  phone: string;
}): Promise<UserRow | null> {
  if (tenantId == null) {
    const { rows } = await query<UserRow>(
      `SELECT * FROM users WHERE tenant_id IS NULL AND phone = $1 AND is_active = true`,
      [phone]
    );
    return rows[0] || null;
  }
  const { rows } = await query<UserRow>(
    `SELECT * FROM users WHERE tenant_id = $1 AND phone = $2 AND is_active = true`,
    [tenantId, phone]
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
