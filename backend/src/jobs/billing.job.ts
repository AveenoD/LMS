import cron from 'node-cron';
import { query } from '../config/db.js';
import env from '../config/env.js';
import logger from '../utils/logger.js';
import * as notificationCenter from '../services/notificationCenter.service.js';

/** How many days out a trial must be from expiring before we start flagging it. */
const TRIAL_EXPIRY_WARNING_DAYS = 3;

/**
 * Daily maintenance:
 *  - Move 'active' subs past (next_billing_date + grace) → 'past_due'.
 *  - Flag trials expiring within TRIAL_EXPIRY_WARNING_DAYS: write a notification
 *    for the tenant's coaching_admin(s) and an audit_log entry (super admin can
 *    already pull the same list live via GET /superadmin/subscriptions/expiring).
 *  - (Already-expired trials are enforced live by subscriptionGuard; we just log them.)
 */
export async function runBillingSweep(): Promise<{
  movedToPastDue: number;
  trialsFlaggedExpiringSoon: number;
  alreadyExpiredTrials: number;
}> {
  const pastDue = await query(
    `UPDATE subscriptions
        SET status='past_due'
      WHERE status='active'
        AND next_billing_date IS NOT NULL
        AND now() > next_billing_date + ($1 || ' days')::interval
      RETURNING tenant_id`,
    [env.billing.graceDays]
  );

  // Trials expiring within the warning window (but not yet expired) get a
  // notification written for every coaching_admin of that tenant, once per
  // sweep — a daily reminder while the window is open.
  const expiringSoon = await query<{ tenant_id: number; name: string; trial_ends_at: string }>(
    `SELECT s.tenant_id, t.name, s.trial_ends_at
       FROM subscriptions s
       JOIN tenants t ON t.id = s.tenant_id
      WHERE s.status = 'trial'
        AND s.trial_ends_at IS NOT NULL
        AND s.trial_ends_at > now()
        AND s.trial_ends_at <= now() + ($1 || ' days')::interval`,
    [TRIAL_EXPIRY_WARNING_DAYS]
  );

  for (const row of expiringSoon.rows) {
    const daysLeft = Math.max(0, Math.ceil((new Date(row.trial_ends_at).getTime() - Date.now()) / 86_400_000));
    const title = 'Trial ending soon';
    const body = `${row.name}'s free trial ends in ${daysLeft} day${daysLeft === 1 ? '' : 's'}. Subscribe to avoid losing write access.`;

    const { rows: admins } = await query<{ id: number }>(
      `SELECT id FROM users WHERE tenant_id = $1 AND role = 'coaching_admin' AND is_active = true`,
      [row.tenant_id]
    );
    await notificationCenter.sendNotification({
      userIds: admins.map((a) => a.id),
      tenantId: row.tenant_id,
      title,
      body,
      type: 'system',
    });
    await query(
      `INSERT INTO audit_log (tenant_id, action, entity, entity_id, meta)
       VALUES ($1, 'trial_expiry_flagged', 'subscription', NULL, $2::jsonb)`,
      [row.tenant_id, JSON.stringify({ daysLeft, trialEndsAt: row.trial_ends_at })]
    );
  }

  const expiredTrials = await query(
    `SELECT tenant_id FROM subscriptions
      WHERE status='trial' AND trial_ends_at IS NOT NULL AND now() > trial_ends_at`
  );

  logger.info('Billing sweep complete', {
    movedToPastDue: pastDue.rowCount,
    trialsFlaggedExpiringSoon: expiringSoon.rowCount,
    alreadyExpiredTrials: expiredTrials.rowCount,
  });
  return {
    movedToPastDue: pastDue.rowCount ?? 0,
    trialsFlaggedExpiringSoon: expiringSoon.rowCount ?? 0,
    alreadyExpiredTrials: expiredTrials.rowCount ?? 0,
  };
}

/** Schedule at 02:00 every day. Call once at boot. */
export function scheduleBillingJob(): void {
  cron.schedule('0 2 * * *', () => {
    runBillingSweep().catch((err) =>
      logger.error('Billing sweep failed', { error: err instanceof Error ? err.message : String(err) })
    );
  });
  logger.info('Billing cron scheduled (daily 02:00)');
}
