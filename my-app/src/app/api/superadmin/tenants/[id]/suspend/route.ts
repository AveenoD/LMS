import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/superadmin.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema, suspendSchema } from '@/lib/validators/superadmin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.patch('/tenants/:id/suspend', validate(idParamSchema, 'params'), validate(suspendSchema), ctrl.suspendTenant)
export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'super_admin');
    const { id } = validateBody(idParamSchema, await params);
    const body = validateBody(suspendSchema, await req.json());
    const result = await svc.setTenantActive(id, body.isActive, user.userId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
