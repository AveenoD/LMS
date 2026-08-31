import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/superadmin.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema } from '@/lib/validators/superadmin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/tenants/:id/dashboard', validate(idParamSchema, 'params'), ctrl.getTenantDashboard)
export async function GET(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    requireAuth(req, 'super_admin');
    const { id } = validateBody(idParamSchema, await params);
    const result = await svc.getTenantDashboard(id);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
