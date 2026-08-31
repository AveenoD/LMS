import { NextRequest, NextResponse } from 'next/server';
import * as testSvc from '@/lib/services/test.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { testIdParamSchema, createQuestionSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/tests/:testId/questions', validate(testIdParamSchema, 'params'), ctrl.getTestQuestions)
export async function GET(req: NextRequest, { params }: { params: Promise<{ testId: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const { testId } = validateBody(testIdParamSchema, await params);
    const result = await testSvc.getTestQuestions(requireTenantId(user), testId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/tests/:testId/questions', validate(testIdParamSchema, 'params'), validate(createQuestionSchema), ctrl.addQuestion)
export async function POST(req: NextRequest, { params }: { params: Promise<{ testId: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const { testId } = validateBody(testIdParamSchema, await params);
    const body = validateBody(createQuestionSchema, await req.json());
    const result = await testSvc.addQuestion(requireTenantId(user), testId, body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
