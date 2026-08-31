import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createFeeStructureSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/fees/structures', subscriptionGuard, validate(createFeeStructureSchema), ctrl.createFeeStructure)
// TODO: port subscriptionGuard when subscription/plan features are migrated
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const body = validateBody(createFeeStructureSchema, await req.json());
    const result = await svc.createFeeStructure(requireTenantId(user), user.userId, body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
