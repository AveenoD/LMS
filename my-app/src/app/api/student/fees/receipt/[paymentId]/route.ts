import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { paymentIdParamSchema } from '@/lib/validators/student.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/fees/receipt/:paymentId', validate(paymentIdParamSchema, 'params'), ctrl.receipt)
export async function GET(req: NextRequest, { params }: { params: Promise<{ paymentId: string }> }) {
  try {
    const user = requireAuth(req, 'student');
    const { paymentId } = validateBody(paymentIdParamSchema, await params);
    const result = await svc.receipt(requireTenantId(user), user.userId, paymentId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
