import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/razorpay.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { verifyPaymentSchema } from '@/lib/validators/payment.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/verify', validate(verifyPaymentSchema), ctrl.verify)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const body = validateBody(verifyPaymentSchema, await req.json());
    const result = await svc.verifyPayment(requireTenantId(user), user.userId, body);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
