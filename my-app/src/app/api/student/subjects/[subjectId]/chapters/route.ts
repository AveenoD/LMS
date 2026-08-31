import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { subjectIdParamSchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/subjects/:subjectId/chapters', validate(subjectIdParamSchema, 'params'), ctrl.listChapters)
export async function GET(req: NextRequest, { params }: { params: Promise<{ subjectId: string }> }) {
  try {
    const user = requireAuth(req, 'student');
    const { subjectId } = validateBody(subjectIdParamSchema, await params);
    const result = await svc.listChapters(requireTenantId(user), user.userId, subjectId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
