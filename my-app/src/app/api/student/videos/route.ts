import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { listVideosQuerySchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/videos', validate(listVideosQuerySchema, 'query'), ctrl.listVideos)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'student');
    const query = Object.fromEntries(req.nextUrl.searchParams.entries());
    const { subjectId } = validateBody(listVideosQuerySchema, query);
    const result = await svc.listVideos(requireTenantId(user), user.userId, subjectId ?? null);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
