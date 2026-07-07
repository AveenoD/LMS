import { query } from '../../config/db.js';
import type { TenantRow, BrandingRow } from '../rows.js';

/** Fetch tenant branding by id (name, logo, color). */
export async function getBranding(tenantId: number | null): Promise<BrandingRow | null> {
  if (!tenantId) return null;
  const { rows } = await query<BrandingRow>(
    `SELECT name, logo_url AS "logoUrl", primary_color AS "primaryColor", slug
       FROM tenants WHERE id = $1`,
    [tenantId]
  );
  return rows[0] || null;
}

export async function findBySlug(slug: string): Promise<TenantRow | null> {
  const { rows } = await query<TenantRow>(`SELECT * FROM tenants WHERE slug = $1`, [slug]);
  return rows[0] || null;
}

export async function findById(id: number): Promise<TenantRow | null> {
  const { rows } = await query<TenantRow>(`SELECT * FROM tenants WHERE id = $1`, [id]);
  return rows[0] || null;
}
