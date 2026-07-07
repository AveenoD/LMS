import bcrypt from 'bcryptjs';
import { query, withTransaction } from '../config/db.js';
import env from '../config/env.js';
import ApiError from '../utils/ApiError.js';

export interface RegisterTenantInput {
  name: string;
  slug: string;
  city?: string;
  contactPhone?: string;
  primaryColor?: string;
  adminName: string;
  adminPhone: string;
  adminPassword: string;
  plan?: string;
  amount?: number;
}

interface TenantResult {
  id: number;
  name: string;
  slug: string;
  city: string | null;
  primaryColor: string | null;
  contactPhone: string | null;
}

interface AdminResult {
  id: number;
  fullName: string;
  phone: string;
  role: string;
}

/**
 * Onboard a new institute: creates tenant + trial subscription + coaching_admin
 * in a single transaction.
 */
export async function registerTenant(
  input: RegisterTenantInput
): Promise<{ tenant: TenantResult; adminUser: AdminResult }> {
  const {
    name,
    slug,
    city,
    contactPhone,
    primaryColor,
    adminName,
    adminPhone,
    adminPassword,
    plan = 'flat',
    amount = env.billing.defaultAmount,
  } = input;

  const hash = await bcrypt.hash(adminPassword, 10);

  return withTransaction(async (client) => {
    const existing = await client.query(`SELECT 1 FROM tenants WHERE slug = $1`, [slug]);
    if (existing.rowCount) throw ApiError.conflict('SLUG_TAKEN', 'This slug is already in use');

    const tenant = (
      await client.query<TenantResult>(
        `INSERT INTO tenants (name, slug, city, contact_phone, primary_color)
       VALUES ($1,$2,$3,$4,$5)
       RETURNING id, name, slug, city, primary_color AS "primaryColor", contact_phone AS "contactPhone"`,
        [name, slug, city || null, contactPhone || null, primaryColor || '#2563EB']
      )
    ).rows[0];

    await client.query(
      `INSERT INTO subscriptions (tenant_id, plan, amount, status, trial_ends_at)
       VALUES ($1,$2,$3,'trial', now() + ($4 || ' days')::interval)`,
      [tenant.id, plan, amount, env.billing.trialDays]
    );

    const admin = (
      await client.query<AdminResult>(
        `INSERT INTO users (tenant_id, role, full_name, phone, password_hash)
       VALUES ($1,'coaching_admin',$2,$3,$4)
       RETURNING id, full_name AS "fullName", phone, role`,
        [tenant.id, adminName, adminPhone, hash]
      )
    ).rows[0];

    return { tenant, adminUser: admin };
  });
}

export interface TenantListItem {
  id: number;
  name: string;
  slug: string;
  city: string | null;
  isActive: boolean;
  status: string | null;
  trialEndsAt: Date | null;
  nextBillingDate: Date | null;
  studentCount: number;
}

export async function listTenants(): Promise<TenantListItem[]> {
  const { rows } = await query<TenantListItem>(`
    SELECT t.id, t.name, t.slug, t.city, t.is_active AS "isActive",
           s.status, s.trial_ends_at AS "trialEndsAt", s.next_billing_date AS "nextBillingDate",
           (SELECT count(*)::int FROM students st WHERE st.tenant_id = t.id) AS "studentCount"
      FROM tenants t
      LEFT JOIN subscriptions s ON s.tenant_id = t.id
      ORDER BY t.created_at DESC
  `);
  return rows;
}

export async function setTenantActive(
  id: number,
  isActive: boolean
): Promise<{ id: number; name: string; isActive: boolean }> {
  const { rows } = await query<{ id: number; name: string; isActive: boolean }>(
    `UPDATE tenants SET is_active = $2 WHERE id = $1
     RETURNING id, name, is_active AS "isActive"`,
    [id, isActive]
  );
  if (!rows[0]) throw ApiError.notFound('TENANT_NOT_FOUND');
  return rows[0];
}

export interface SubscriptionListItem {
  tenantId: number;
  name: string;
  status: string;
  plan: string;
  amount: number;
  trialEndsAt: Date | null;
  nextBillingDate: Date | null;
}

export async function listSubscriptions(): Promise<SubscriptionListItem[]> {
  const { rows } = await query<SubscriptionListItem>(`
    SELECT s.tenant_id AS "tenantId", t.name, s.status, s.plan, s.amount,
           s.trial_ends_at AS "trialEndsAt", s.next_billing_date AS "nextBillingDate"
      FROM subscriptions s JOIN tenants t ON t.id = s.tenant_id
      ORDER BY s.created_at DESC
  `);
  return rows;
}

export interface ExpiringItem {
  tenantId: number;
  name: string;
  status: string;
  trialEndsAt: Date | null;
}

export async function expiringSoon(days = 3): Promise<ExpiringItem[]> {
  const { rows } = await query<ExpiringItem>(
    `SELECT s.tenant_id AS "tenantId", t.name, s.status, s.trial_ends_at AS "trialEndsAt"
       FROM subscriptions s JOIN tenants t ON t.id = s.tenant_id
      WHERE s.status = 'trial'
        AND s.trial_ends_at IS NOT NULL
        AND s.trial_ends_at <= now() + ($1 || ' days')::interval
        AND s.trial_ends_at >= now()
      ORDER BY s.trial_ends_at ASC`,
    [days]
  );
  return rows;
}

export interface PlatformAnalytics {
  totalTenants: number;
  activeTenants: number;
  totalStudents: number;
  mrr: number;
  onTrial: number;
}

export async function analytics(): Promise<PlatformAnalytics> {
  const { rows } = await query<PlatformAnalytics>(`
    SELECT
      (SELECT count(*)::int FROM tenants) AS "totalTenants",
      (SELECT count(*)::int FROM tenants WHERE is_active) AS "activeTenants",
      (SELECT count(*)::int FROM students) AS "totalStudents",
      (SELECT COALESCE(sum(amount),0)::int FROM subscriptions WHERE status = 'active') AS "mrr",
      (SELECT count(*)::int FROM subscriptions WHERE status = 'trial') AS "onTrial"
  `);
  return rows[0];
}
