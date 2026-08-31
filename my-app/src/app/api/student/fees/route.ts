import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/fees', ctrl.fees)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'student');
    const result = await svc.fees(requireTenantId(user), user.userId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
