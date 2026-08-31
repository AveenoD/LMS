import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { testIdParamSchema, submitTestSchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/tests/:testId/submit', validate(testIdParamSchema, 'params'), validate(submitTestSchema, 'body'), ctrl.submitTest)
export async function POST(req: NextRequest, { params }: { params: Promise<{ testId: string }> }) {
  try {
    const user = requireAuth(req, 'student');
    const { testId } = validateBody(testIdParamSchema, await params);
    const body = validateBody(submitTestSchema, await req.json());
    const result = await svc.submitTest(requireTenantId(user), user.userId, testId, body);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
