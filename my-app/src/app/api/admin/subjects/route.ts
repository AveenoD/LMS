import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createSubjectSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/subjects', ctrl.listSubjects)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const result = await svc.listSubjects(requireTenantId(user));
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/subjects', subscriptionGuard, validate(createSubjectSchema), ctrl.createSubject)
// TODO: port subscriptionGuard when subscription/plan features are migrated
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const body = validateBody(createSubjectSchema, await req.json());
    const result = await svc.createSubject(requireTenantId(user), body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
