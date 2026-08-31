import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/plan.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema } from '@/lib/validators/superadmin.validators';
import { assignPlanSchema } from '@/lib/validators/plan.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/tenants/:id/subscription', validate(idParamSchema, 'params'), planCtrl.getTenantSubscription)
export async function GET(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    requireAuth(req, 'super_admin');
    const { id } = validateBody(idParamSchema, await params);
    const result = await svc.getTenantSubscription(id);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.put('/tenants/:id/subscription', validate(idParamSchema, 'params'), validate(assignPlanSchema), planCtrl.assignPlan)
export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'super_admin');
    const { id } = validateBody(idParamSchema, await params);
    const body = validateBody(assignPlanSchema, await req.json());
    const result = await svc.assignPlanToTenant(id, body, user.userId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
