import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/superadmin.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/subscriptions', ctrl.listSubscriptions)
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'super_admin');
    const result = await svc.listSubscriptions();
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
