import cron from 'node-cron';
import { query } from '../config/db.js';
import env from '../config/env.js';
import logger from '../utils/logger.js';

/**
 * Daily maintenance:
 *  - Move 'active' subs past (next_billing_date + grace) → 'past_due'.
 *  - (Trials are enforced live by subscriptionGuard; here we just log expiries.)
 */
export async function runBillingSweep(): Promise<{ movedToPastDue: number; expiredTrials: number }> {
  const pastDue = await query(
    `UPDATE subscriptions
        SET status='past_due'
      WHERE status='active'
        AND next_billing_date IS NOT NULL
        AND now() > next_billing_date + ($1 || ' days')::interval
      RETURNING tenant_id`,
    [env.billing.graceDays]
  );

  const expiredTrials = await query(
    `SELECT tenant_id FROM subscriptions
      WHERE status='trial' AND trial_ends_at IS NOT NULL AND now() > trial_ends_at`
  );

  logger.info('Billing sweep complete', {
    movedToPastDue: pastDue.rowCount,
    expiredTrials: expiredTrials.rowCount,
  });
  return { movedToPastDue: pastDue.rowCount ?? 0, expiredTrials: expiredTrials.rowCount ?? 0 };
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
