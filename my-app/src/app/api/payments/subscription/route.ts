import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/razorpay.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/subscription', ctrl.status)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const result = await svc.subscriptionStatus(requireTenantId(user));
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
