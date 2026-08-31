import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/videos/:id', validate(idParamSchema, 'params'), ctrl.videoDetail)
export async function GET(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'student');
    const { id } = validateBody(idParamSchema, await params);
    const result = await svc.videoDetail(requireTenantId(user), user.userId, id);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
