import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/superadmin.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { registerTenantSchema } from '@/lib/validators/superadmin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/tenants', ctrl.listTenants)
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'super_admin');
    const result = await svc.listTenants();
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/tenants', validate(registerTenantSchema), ctrl.registerTenant)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'super_admin');
    const body = validateBody(registerTenantSchema, await req.json());
    const result = await svc.registerTenant(body, user.userId);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
