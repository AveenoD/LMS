import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/students/:id/details', validate(idParamSchema, 'params'), ctrl.getStudentDetails)
export async function GET(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { id } = validateBody(idParamSchema, await params);
    const result = await svc.getStudentDetails(requireTenantId(user), id);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
