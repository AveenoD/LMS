import cron from 'node-cron';
import { query } from '../config/db.js';
import logger from '../utils/logger.js';
import * as notificationCenter from '../services/notificationCenter.service.js';

/** Remind students this many days before a fee's due date, and again on the due date itself. */
const REMINDER_DAYS_BEFORE = [3, 1, 0];

/**
 * Daily sweep: for every fee_structure whose due_date is 3, 1, or 0 days
 * away, notify every enrolled student who hasn't fully paid it yet.
 * Idempotent per (structure, day-offset) via a lightweight dedupe check
 * against notifications already sent today for that entity.
 */
export async function runFeeReminderSweep(): Promise<{ remindersSent: number }> {
  const { rows: due } = await query<{
    id: number;
    tenant_id: number;
    batch_id: number | null;
    title: string;
    amount: number;
    due_date: string;
    days_left: number;
  }>(
    `SELECT id, tenant_id, batch_id, title, amount, due_date,
            (due_date - CURRENT_DATE) AS days_left
       FROM fee_structures
      WHERE batch_id IS NOT NULL
        AND due_date IS NOT NULL
        AND (due_date - CURRENT_DATE) = ANY($1::int[])`,
    [REMINDER_DAYS_BEFORE]
  );

  let remindersSent = 0;

  for (const fee of due) {
    // Already reminded today for this exact structure? Skip (cron can run
    // more than once a day in dev/restarts; this keeps it idempotent).
    const already = await query(
      `SELECT 1 FROM notifications
        WHERE type = 'fee_due' AND entity_id = $1 AND created_at::date = CURRENT_DATE
        LIMIT 1`,
      [fee.id]
    );
    if (already.rowCount) continue;

    const { rows: unpaid } = await query<{ user_id: number }>(
      `SELECT u.id AS user_id
         FROM users u
         JOIN students s ON s.user_id = u.id
         JOIN batch_enrollments be ON be.student_id = s.id
        WHERE be.batch_id = $1 AND u.is_active = true
          AND COALESCE((
            SELECT sum(fp.amount_paid) FROM fee_payments fp
             WHERE fp.fee_structure_id = $2 AND fp.student_id = s.id
          ), 0) < $3`,
      [fee.batch_id, fee.id, fee.amount]
    );
    if (unpaid.length === 0) continue;

    const title = fee.days_left === 0 ? 'Fee due today' : 'Fee due soon';
    const body =
      fee.days_left === 0
        ? `${fee.title} (₹${fee.amount}) is due today.`
        : `${fee.title} (₹${fee.amount}) is due in ${fee.days_left} day${fee.days_left === 1 ? '' : 's'}.`;

    await notificationCenter.sendNotification({
      userIds: unpaid.map((u) => u.user_id),
      tenantId: fee.tenant_id,
      title,
      body,
      type: 'fee_due',
      entityId: fee.id,
    });
    remindersSent += unpaid.length;
  }

  logger.info('Fee reminder sweep complete', { structuresChecked: due.length, remindersSent });
  return { remindersSent };
}

/** Schedule at 09:00 every day — a reasonable local-morning time for a reminder. */
export function scheduleFeeReminderJob(): void {
  cron.schedule('0 9 * * *', () => {
    runFeeReminderSweep().catch((err) =>
      logger.error('Fee reminder sweep failed', { error: err instanceof Error ? err.message : String(err) })
    );
  });
  logger.info('Fee reminder cron scheduled (daily 09:00)');
}
