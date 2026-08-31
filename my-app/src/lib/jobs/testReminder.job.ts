import { query } from '../db';
import logger from '../utils/logger';
import * as notificationCenter from '../services/notificationCenter.service';

/** How far ahead of a test's scheduled_at to remind students. */
const REMINDER_MINUTES_BEFORE = 60;
/** Sweep granularity — must be <= REMINDER_MINUTES_BEFORE, wide enough to
 *  catch a test whose scheduled_at falls in the window between two runs. */
const SWEEP_WINDOW_MINUTES = 10;

/**
 * Finds tests whose scheduled_at is between
 * (now + REMINDER_MINUTES_BEFORE) and (now + REMINDER_MINUTES_BEFORE + window),
 * i.e. about to start within the reminder window, and haven't been reminded yet.
 */
export async function runTestReminderSweep(): Promise<{ remindersSent: number }> {
  const { rows: upcoming } = await query<{
    id: number;
    tenant_id: number;
    batch_id: number | null;
    title: string;
    scheduled_at: string;
  }>(
    `SELECT id, tenant_id, batch_id, title, scheduled_at
       FROM tests
      WHERE batch_id IS NOT NULL
        AND scheduled_at IS NOT NULL
        AND scheduled_at BETWEEN now() + ($1 || ' minutes')::interval
                              AND now() + ($2 || ' minutes')::interval
        AND NOT EXISTS (
          SELECT 1 FROM notifications
           WHERE type = 'test_reminder' AND entity_id = tests.id
        )`,
    [REMINDER_MINUTES_BEFORE, REMINDER_MINUTES_BEFORE + SWEEP_WINDOW_MINUTES]
  );

  let remindersSent = 0;

  for (const test of upcoming) {
    const { rows: students } = await query<{ user_id: number }>(
      `SELECT u.id AS user_id
         FROM users u
         JOIN students s ON s.user_id = u.id
         JOIN batch_enrollments be ON be.student_id = s.id
        WHERE be.batch_id = $1 AND u.is_active = true`,
      [test.batch_id]
    );
    if (students.length === 0) continue;

    await notificationCenter.sendNotification({
      userIds: students.map((s) => s.user_id),
      tenantId: test.tenant_id,
      title: 'Test starting soon',
      body: `${test.title} starts at ${new Date(test.scheduled_at).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}.`,
      type: 'test_reminder',
      entityId: test.id,
    });
    remindersSent += students.length;
  }

  logger.info('Test reminder sweep complete', { testsChecked: upcoming.length, remindersSent });
  return { remindersSent };
}
