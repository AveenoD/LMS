import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { scanAttendanceQrSchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/attendance/qr-scan', validate(scanAttendanceQrSchema), ctrl.scanAttendanceQr)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'student');
    const body = validateBody(scanAttendanceQrSchema, await req.json());
    const result = await svc.scanAttendanceQr(requireTenantId(user), user.userId, body.token);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
