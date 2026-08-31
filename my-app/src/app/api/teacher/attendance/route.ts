import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { markAttendanceSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/attendance', validate(markAttendanceSchema), ctrl.markAttendance)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const body = validateBody(markAttendanceSchema, await req.json());
    const result = await svc.markAttendance(requireTenantId(user), user.userId, body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
