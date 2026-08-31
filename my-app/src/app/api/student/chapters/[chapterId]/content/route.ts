import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { chapterIdParamSchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/chapters/:chapterId/content', validate(chapterIdParamSchema, 'params'), ctrl.listChapterContent)
export async function GET(req: NextRequest, { params }: { params: Promise<{ chapterId: string }> }) {
  try {
    const user = requireAuth(req, 'student');
    const { chapterId } = validateBody(chapterIdParamSchema, await params);
    const result = await svc.listChapterContent(requireTenantId(user), user.userId, chapterId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
