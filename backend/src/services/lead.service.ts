import { query } from '../config/db.js';
import { notifyNewLead } from './notification.service.js';
import logger from '../utils/logger.js';
import type { LeadRow, LeadStatus } from '../db/rows.js';

export interface CreateLeadInput {
  ownerName: string;
  instituteName: string;
  phone: string;
  city?: string;
  studentCount?: number;
  message?: string;
}

export interface LeadListItem {
  id: number;
  ownerName: string;
  instituteName: string;
  phone: string;
  city: string | null;
  studentCount: number | null;
  message: string | null;
  status: LeadStatus;
  isRead: boolean;
  notified: boolean;
  createdAt: Date;
}

/**
 * Persist a demo booking, then fire free notifications (email + telegram).
 * The DB row IS the in-app inbox for the Super Admin panel.
 */
export async function createLead(input: CreateLeadInput): Promise<LeadRow> {
  const { rows } = await query<LeadRow>(
    `INSERT INTO leads (owner_name, institute_name, phone, city, student_count, message, source)
     VALUES ($1,$2,$3,$4,$5,$6,'marketing_site')
     RETURNING *`,
    [
      input.ownerName,
      input.instituteName,
      input.phone,
      input.city || null,
      input.studentCount ?? null,
      input.message || null,
    ]
  );
  const lead = rows[0];

  // Best-effort external notifications (never block the response).
  notifyNewLead(lead)
    .then((sent) => {
      if (sent) query(`UPDATE leads SET notified = true WHERE id = $1`, [lead.id]).catch(() => {});
    })
    .catch((err) => logger.error('notifyNewLead failed', { error: err instanceof Error ? err.message : String(err) }));

  return lead;
}

export async function listLeads(
  { status, limit = 100 }: { status?: LeadStatus | string; limit?: number } = {}
): Promise<LeadListItem[]> {
  const params: unknown[] = [];
  let where = '';
  if (status) {
    params.push(status);
    where = `WHERE status = $1`;
  }
  params.push(limit);
  const { rows } = await query<LeadListItem>(
    `SELECT id, owner_name AS "ownerName", institute_name AS "instituteName", phone, city,
            student_count AS "studentCount", message, status, is_read AS "isRead",
            notified, created_at AS "createdAt"
       FROM leads ${where}
       ORDER BY created_at DESC
       LIMIT $${params.length}`,
    params
  );
  return rows;
}

export async function unreadCount(): Promise<number> {
  const { rows } = await query<{ count: number }>(
    `SELECT count(*)::int AS count FROM leads WHERE is_read = false`
  );
  return rows[0].count;
}

export async function markRead(id: number): Promise<void> {
  await query(`UPDATE leads SET is_read = true WHERE id = $1`, [id]);
}

export async function updateStatus(
  id: number,
  status: LeadStatus
): Promise<{ id: number; status: LeadStatus } | null> {
  const { rows } = await query<{ id: number; status: LeadStatus }>(
    `UPDATE leads SET status = $2, is_read = true WHERE id = $1 RETURNING id, status`,
    [id, status]
  );
  return rows[0] || null;
}
