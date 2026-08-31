import { NextRequest, NextResponse } from 'next/server';
import * as testSvc from '@/lib/services/test.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createTestSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/tests', ctrl.listTests)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const result = await testSvc.listTests(requireTenantId(user));
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/tests', validate(createTestSchema), ctrl.createTest)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const body = validateBody(createTestSchema, await req.json());
    const result = await testSvc.createTest(requireTenantId(user), body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
