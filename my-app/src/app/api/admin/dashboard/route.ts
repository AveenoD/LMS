import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/dashboard', ctrl.dashboard)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { searchParams } = new URL(req.url);
    const month = searchParams.get('month') ? Number(searchParams.get('month')) : undefined;
    const year = searchParams.get('year') ? Number(searchParams.get('year')) : undefined;
    const result = await svc.dashboard(requireTenantId(user), month, year);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
