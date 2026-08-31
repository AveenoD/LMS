import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createSubjectSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.put('/subjects/:id', subscriptionGuard, validate(createSubjectSchema), ctrl.updateSubject)
// TODO: port subscriptionGuard when subscription/plan features are migrated
export async function PUT(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { id: rawId } = await params;
    const id = Number(rawId);
    const body = validateBody(createSubjectSchema, await req.json());
    const result = await svc.updateSubject(requireTenantId(user), id, body);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.delete('/subjects/:id', subscriptionGuard, ctrl.deleteSubject)
// TODO: port subscriptionGuard when subscription/plan features are migrated
// Note: no validate(idParamSchema, 'params') on this route in the original
// Express router either — deleteSubject controller reads req.params.id raw.
export async function DELETE(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { id: rawId } = await params;
    const id = Number(rawId);
    await svc.deleteSubject(requireTenantId(user), id);
    return new NextResponse(null, { status: 204 });
  } catch (err) {
    return handleApiError(err);
  }
}
