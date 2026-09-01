import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { requireFeature } from '@/lib/middleware/featureGuard';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/reports/performance', featureGuard('performance_reports'), ctrl.performance)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const tenantId = requireTenantId(user);
    await requireFeature(tenantId, 'performance_reports');
    const { searchParams } = new URL(req.url);
    const batchId = searchParams.get('batchId') ? Number(searchParams.get('batchId')) : null;
    const result = await svc.performanceReport(tenantId, batchId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
