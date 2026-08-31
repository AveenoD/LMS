import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { testIdParamSchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/tests/:testId/questions', validate(testIdParamSchema, 'params'), ctrl.getTestQuestions)
export async function GET(req: NextRequest, { params }: { params: Promise<{ testId: string }> }) {
  try {
    const user = requireAuth(req, 'student');
    const { testId } = validateBody(testIdParamSchema, await params);
    const result = await svc.getTestQuestions(requireTenantId(user), user.userId, testId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
