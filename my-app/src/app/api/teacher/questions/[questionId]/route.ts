import { NextRequest, NextResponse } from 'next/server';
import * as testSvc from '@/lib/services/test.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { questionIdParamSchema, createQuestionSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.put('/questions/:questionId', validate(questionIdParamSchema, 'params'), validate(createQuestionSchema), ctrl.updateQuestion)
export async function PUT(req: NextRequest, { params }: { params: Promise<{ questionId: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const { questionId } = validateBody(questionIdParamSchema, await params);
    const body = validateBody(createQuestionSchema, await req.json());
    const result = await testSvc.updateQuestion(requireTenantId(user), questionId, body);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.delete('/questions/:questionId', validate(questionIdParamSchema, 'params'), ctrl.deleteQuestion)
export async function DELETE(req: NextRequest, { params }: { params: Promise<{ questionId: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const { questionId } = validateBody(questionIdParamSchema, await params);
    const result = await testSvc.deleteQuestion(requireTenantId(user), questionId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
