import { query } from '../../config/db.js';
import type { TenantRow } from '../rows.js';

export async function findBySlug(slug: string): Promise<TenantRow | null> {
  const { rows } = await query<TenantRow>(`SELECT * FROM tenants WHERE slug = $1`, [slug]);
  return rows[0] || null;
}

export async function findById(id: number): Promise<TenantRow | null> {
  const { rows } = await query<TenantRow>(`SELECT * FROM tenants WHERE id = $1`, [id]);
  return rows[0] || null;
}
