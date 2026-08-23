import cron from 'node-cron';
import { query } from '../config/db.js';
import logger from '../utils/logger.js';
import * as notificationCenter from '../services/notificationCenter.service.js';

/** How far ahead of a live class's scheduled_at to remind students. */
const REMINDER_MINUTES_BEFORE = 10;
/** Sweep granularity — narrow, since the reminder window itself is narrow. */
const SWEEP_WINDOW_MINUTES = 5;

export async function runLiveClassReminderSweep(): Promise<{ remindersSent: number }> {
  const { rows: upcoming } = await query<{
    id: number;
    tenant_id: number;
    batch_id: number;
    title: string;
    meet_url: string;
    scheduled_at: string;
  }>(
    `SELECT id, tenant_id, batch_id, title, meet_url, scheduled_at
       FROM live_classes
      WHERE scheduled_at BETWEEN now() + ($1 || ' minutes')::interval
                              AND now() + ($2 || ' minutes')::interval
        AND NOT EXISTS (
          SELECT 1 FROM notifications
           WHERE type = 'live_class_reminder' AND entity_id = live_classes.id
        )`,
    [REMINDER_MINUTES_BEFORE, REMINDER_MINUTES_BEFORE + SWEEP_WINDOW_MINUTES]
  );

  let remindersSent = 0;

  for (const liveClass of upcoming) {
    const { rows: students } = await query<{ user_id: number }>(
      `SELECT u.id AS user_id
         FROM users u
         JOIN students s ON s.user_id = u.id
         JOIN batch_enrollments be ON be.student_id = s.id
        WHERE be.batch_id = $1 AND u.is_active = true`,
      [liveClass.batch_id]
    );
    if (students.length === 0) continue;

    await notificationCenter.sendNotification({
      userIds: students.map((s) => s.user_id),
      tenantId: liveClass.tenant_id,
      title: 'Live class starting soon',
      body: `${liveClass.title} starts in ${REMINDER_MINUTES_BEFORE} minutes.`,
      type: 'live_class_reminder',
      entityId: liveClass.id,
    });
    remindersSent += students.length;
  }

  logger.info('Live class reminder sweep complete', { classesChecked: upcoming.length, remindersSent });
  return { remindersSent };
}

/** Schedule every 5 minutes — matches the narrow reminder window. */
export function scheduleLiveClassReminderJob(): void {
  cron.schedule(`*/${SWEEP_WINDOW_MINUTES} * * * *`, () => {
    runLiveClassReminderSweep().catch((err) =>
      logger.error('Live class reminder sweep failed', { error: err instanceof Error ? err.message : String(err) })
    );
  });
  logger.info(`Live class reminder cron scheduled (every ${SWEEP_WINDOW_MINUTES} min)`);
}
