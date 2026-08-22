import type { Request, Response, NextFunction } from 'express';
import { query } from '../config/db.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';

interface SubscriptionRow {
  status: string;
  trial_ends_at: Date | null;
  next_billing_date: Date | null;
}

/**
 * Blocks coaching-admin WRITE actions when the tenant's trial has expired or
 * the account is past_due / suspended. Read (GET) routes stay open (soft lock)
 * so the institute can still view its data and reach the "Pay Now" screen.
 *
 * Attach ONLY to POST/PUT/PATCH/DELETE coaching-admin routes.
 *
 * Wrapped in asyncHandler so thrown ApiErrors reach the central errorHandler
 * (Express 4 does not auto-catch rejected promises from async middleware).
 */
export const subscriptionGuard = asyncHandler(async function subscriptionGuard(
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> {
  const tenantId = req.user?.tenantId;
  if (!tenantId) throw ApiError.forbidden('NO_TENANT');

  const { rows } = await query<SubscriptionRow>(
    `SELECT status, trial_ends_at, next_billing_date
       FROM subscriptions WHERE tenant_id = $1`,
    [tenantId]
  );
  const sub = rows[0];
  if (!sub) throw ApiError.forbidden('NO_SUBSCRIPTION', 'No subscription found');

  const now = new Date();

  if (sub.status === 'trial') {
    if (sub.trial_ends_at && now > new Date(sub.trial_ends_at)) {
      throw ApiError.forbidden('TRIAL_EXPIRED', 'Your free trial has ended. Please subscribe to continue.');
    }
    return next();
  }

  if (sub.status === 'active') return next();

  if (sub.status === 'past_due' || sub.status === 'suspended') {
    throw ApiError.forbidden('PAYMENT_REQUIRED', 'Payment required to continue using the admin panel.');
  }

  next();
});

export default subscriptionGuard;
