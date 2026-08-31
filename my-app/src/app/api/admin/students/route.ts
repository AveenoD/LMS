import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createStudentSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/students', ctrl.listStudents)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { searchParams } = new URL(req.url);
    const batchId = searchParams.get('batchId') ? Number(searchParams.get('batchId')) : null;
    const result = await svc.listStudents(requireTenantId(user), batchId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/students', subscriptionGuard, validate(createStudentSchema), ctrl.createStudent)
// TODO: port subscriptionGuard when subscription/plan features are migrated
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const body = validateBody(createStudentSchema, await req.json());
    const result = await svc.createStudent(requireTenantId(user), user.userId, body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
