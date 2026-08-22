import { query } from '../config/db.js';
import ApiError from '../utils/ApiError.js';
import { writeAudit } from '../utils/audit.js';

/**
 * In-app notification broadcasting + inbox reads against the `notifications`
 * table. Distinct from `notification.service.ts`, which delivers lead emails
 * / Telegram pushes — unrelated concern, same-ish name on purpose avoided.
 */

export type NotificationTargetRole = 'coaching_admin' | 'student';

export interface BroadcastInput {
  title: string;
  body?: string;
  targetRole: NotificationTargetRole;
  /** null = every tenant (super_admin targeting coaching_admins). A number scopes
   *  to one tenant — always required (and enforced from the JWT, never the
   *  request body) when targetRole is 'student'. */
  tenantId: number | null;
  /** Optional area filter — only meaningful when targetRole is 'coaching_admin'. */
  city?: string;
  /** Optional batch filter — only meaningful when targetRole is 'student'. */
  batchId?: number;
}

export interface NotificationRow {
  id: number;
  title: string;
  body: string | null;
  isRead: boolean;
  createdAt: Date;
}

/**
 * Generic broadcast: resolves an audience (by target role + optional
 * city/batch filter) and inserts one notification row per matching user in
 * a single INSERT...SELECT. Reused by both super_admin -> coaching_admin
 * (all institutes, or filtered by city) and coaching_admin -> student
 * (whole institute, or filtered by batch) broadcasts.
 */
export async function broadcastNotification(
  input: BroadcastInput,
  actorUserId: number | null
): Promise<{ recipientCount: number }> {
  const { title, body, targetRole, tenantId, city, batchId } = input;

  let audienceSql: string;
  let audienceParams: unknown[];

  if (targetRole === 'coaching_admin') {
    audienceSql = `
      SELECT u.tenant_id, u.id
        FROM users u
        JOIN tenants t ON t.id = u.tenant_id
       WHERE u.role = 'coaching_admin' AND u.is_active = true
         AND ($1::int IS NULL OR u.tenant_id = $1)
         AND ($2::text IS NULL OR t.city = $2)`;
    audienceParams = [tenantId, city ?? null];
  } else {
    if (tenantId == null) {
      throw ApiError.badRequest('TENANT_REQUIRED', 'Student broadcasts must be scoped to one institute');
    }
    audienceSql = `
      SELECT DISTINCT u.tenant_id, u.id
        FROM users u
        JOIN students s ON s.user_id = u.id
        LEFT JOIN batch_enrollments be ON be.student_id = s.id
       WHERE u.tenant_id = $1 AND u.role = 'student' AND u.is_active = true
         AND ($2::int IS NULL OR be.batch_id = $2)`;
    audienceParams = [tenantId, batchId ?? null];
  }

  const titleParamIdx = audienceParams.length + 1;
  const bodyParamIdx = audienceParams.length + 2;

  const { rows } = await query<{ id: number }>(
    `INSERT INTO notifications (tenant_id, user_id, title, body)
     SELECT tenant_id, id, $${titleParamIdx}, $${bodyParamIdx}
       FROM (${audienceSql}) AS audience
     RETURNING id`,
    [...audienceParams, title, body ?? null]
  );

  await writeAudit({
    tenantId: targetRole === 'student' ? tenantId : null,
    actorUserId,
    action: 'notification_broadcast',
    entity: 'notification',
    meta: { title, targetRole, tenantId, city: city ?? null, batchId: batchId ?? null, recipientCount: rows.length },
  });

  return { recipientCount: rows.length };
}

/** A user's own notification inbox — generic by user_id, used by both
 *  coaching_admin and student roles. */
export async function listMyNotifications(userId: number): Promise<NotificationRow[]> {
  const { rows } = await query<NotificationRow>(
    `SELECT id, title, body, is_read AS "isRead", created_at AS "createdAt"
       FROM notifications WHERE user_id = $1
      ORDER BY created_at DESC LIMIT 50`,
    [userId]
  );
  return rows;
}

export async function unreadNotificationCount(userId: number): Promise<number> {
  const { rows } = await query<{ count: number }>(
    `SELECT count(*)::int AS count FROM notifications WHERE user_id = $1 AND is_read = false`,
    [userId]
  );
  return rows[0]?.count ?? 0;
}

/** Marks one of the caller's own notifications as read — ownership enforced
 *  via the WHERE clause, not just the id. */
export async function markNotificationRead(id: number, userId: number): Promise<void> {
  const { rowCount } = await query(`UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2`, [
    id,
    userId,
  ]);
  if (!rowCount) throw ApiError.notFound('NOTIFICATION_NOT_FOUND');
}
