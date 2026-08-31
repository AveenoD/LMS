import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { studentIdParamSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Same report the coaching_admin sees for this student — ownership
// (student must be in one of this teacher's batches) is checked in the service.

// Ported from Express: router.get('/students/:studentId/details', validate(studentIdParamSchema, 'params'), ctrl.getStudentDetails)
export async function GET(req: NextRequest, { params }: { params: Promise<{ studentId: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const { studentId } = validateBody(studentIdParamSchema, await params);
    const result = await svc.getStudentDetails(requireTenantId(user), user.userId, studentId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
