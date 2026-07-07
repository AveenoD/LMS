import crypto from 'node:crypto';
import Razorpay from 'razorpay';
import { query } from '../config/db.js';
import env from '../config/env.js';
import ApiError from '../utils/ApiError.js';
import logger from '../utils/logger.js';

interface SubscriptionRow {
  id: number;
  plan: string;
  amount: number;
  status: string;
  trialEndsAt: Date | null;
  nextBillingDate: Date | null;
}

export interface CreateOrderResult {
  orderId: string;
  amount: number;
  currency: string;
  keyId: string;
  mock?: boolean;
}

export interface VerifyPaymentInput {
  orderId: string;
  paymentId: string;
  signature?: string;
}

export interface VerifyPaymentResult {
  status: string;
  nextBillingDate: Date | null;
}

let _client: Razorpay | null = null;
function client(): Razorpay | null {
  if (!env.razorpay.enabled) return null;
  if (!_client) {
    _client = new Razorpay({ key_id: env.razorpay.keyId, key_secret: env.razorpay.secret });
  }
  return _client;
}

async function getSubscription(tenantId: number): Promise<SubscriptionRow> {
  const { rows } = await query<SubscriptionRow>(
    `SELECT id, plan, amount, status, trial_ends_at AS "trialEndsAt", next_billing_date AS "nextBillingDate"
       FROM subscriptions WHERE tenant_id=$1`,
    [tenantId]
  );
  if (!rows[0]) throw ApiError.notFound('NO_SUBSCRIPTION');
  return rows[0];
}

export async function subscriptionStatus(tenantId: number): Promise<SubscriptionRow> {
  return getSubscription(tenantId);
}

/** Create a Razorpay order for the tenant's subscription amount. */
export async function createOrder(tenantId: number): Promise<CreateOrderResult> {
  const sub = await getSubscription(tenantId);
  const amountPaise = sub.amount * 100; // never trust client amount

  if (!env.razorpay.enabled) {
    // Dev fallback so the flow is testable without live keys.
    logger.warn('Razorpay not configured — returning mock order (dev only)');
    return {
      orderId: `order_mock_${Date.now()}`,
      amount: amountPaise,
      currency: 'INR',
      keyId: 'rzp_test_mock',
      mock: true,
    };
  }

  const rzp = client();
  if (!rzp) throw ApiError.badRequest('RAZORPAY_NOT_CONFIGURED', 'Payment gateway not configured');

  const order = await rzp.orders.create({
    amount: amountPaise,
    currency: 'INR',
    receipt: `sub_${sub.id}_${Date.now()}`,
    notes: { tenantId: String(tenantId) },
  });
  return {
    orderId: order.id,
    amount: Number(order.amount),
    currency: order.currency,
    keyId: env.razorpay.keyId,
  };
}

/**
 * Verify Razorpay payment signature server-side, then activate the subscription.
 * signature = HMAC_SHA256(orderId + '|' + paymentId, secret)
 */
export async function verifyPayment(
  tenantId: number,
  { orderId, paymentId, signature }: VerifyPaymentInput
): Promise<VerifyPaymentResult> {
  if (env.razorpay.enabled) {
    const expected = crypto
      .createHmac('sha256', env.razorpay.secret)
      .update(`${orderId}|${paymentId}`)
      .digest('hex');
    if (expected !== signature) {
      throw ApiError.badRequest('INVALID_SIGNATURE', 'Payment signature verification failed');
    }
  } else if (!String(orderId).startsWith('order_mock_')) {
    // In dev without keys, only accept mock orders.
    throw ApiError.badRequest('RAZORPAY_NOT_CONFIGURED', 'Payment gateway not configured');
  }

  const { rows } = await query<{ status: string; nextBillingDate: Date | null }>(
    `UPDATE subscriptions
        SET status='active', next_billing_date = now() + interval '30 days'
      WHERE tenant_id=$1
      RETURNING status, next_billing_date AS "nextBillingDate"`,
    [tenantId]
  );

  await query(
    `INSERT INTO audit_log (tenant_id, action, entity, meta)
     VALUES ($1,'payment_verified','subscription', $2::jsonb)`,
    [tenantId, JSON.stringify({ orderId, paymentId })]
  );

  return { status: rows[0].status, nextBillingDate: rows[0].nextBillingDate };
}
