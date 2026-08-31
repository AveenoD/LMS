import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { qrSessionIdParamSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/attendance/qr-session/:sessionId', validate(qrSessionIdParamSchema, 'params'), ctrl.getQrSessionStatus)
export async function GET(req: NextRequest, { params }: { params: Promise<{ sessionId: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const { sessionId } = validateBody(qrSessionIdParamSchema, await params);
    const result = await svc.getQrAttendanceSessionStatus(requireTenantId(user), user.userId, sessionId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
