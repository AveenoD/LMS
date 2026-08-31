import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/fees', ctrl.listFees)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { searchParams } = new URL(req.url);
    const statusParam = searchParams.get('status');
    const status =
      statusParam === 'pending' || statusParam === 'paid' || statusParam === 'overdue' ? statusParam : null;
    const result = await svc.listFees(requireTenantId(user), status);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
