import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { askDoubtQuerySchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/ask-doubt', validate(askDoubtQuerySchema, 'query'), ctrl.askDoubt)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'student');
    const query = Object.fromEntries(req.nextUrl.searchParams.entries());
    const { teacherId, chapter } = validateBody(askDoubtQuerySchema, query);
    const result = await svc.askDoubt(requireTenantId(user), user.userId, teacherId, chapter);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
