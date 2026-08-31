/**
 * Raw DB row shapes (snake_case, as returned by Postgres) for tables the
 * repositories/services read directly. Query-specific projections (with
 * camelCase aliases) are typed inline at each call site.
 */
import type { Role } from '../types/index.js';

export interface TenantRow {
  id: number;
  name: string;
  slug: string;
  city: string | null;
  contact_phone: string | null;
  is_active: boolean;
  created_at: Date;
}

export interface UserRow {
  id: number;
  tenant_id: number | null;
  role: Role;
  full_name: string;
  phone: string;
  email: string | null;
  password_hash: string;
  avatar_url: string | null;
  is_active: boolean;
  created_at: Date;
}

export interface PublicUser {
  id: number;
  role: Role;
  tenantId: number | null;
  fullName: string;
  phone: string;
  email: string | null;
  avatarUrl: string | null;
}

export type LeadStatus = 'new' | 'contacted' | 'converted' | 'lost';

export interface LeadRow {
  id: number;
  owner_name: string;
  institute_name: string;
  phone: string;
  email: string | null;
  city: string | null;
  student_count: number | null;
  message: string | null;
  status: LeadStatus;
  is_read: boolean;
  notified: boolean;
  source: string | null;
  created_at: Date;
}
