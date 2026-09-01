import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { requireFeature } from '@/lib/middleware/featureGuard';
import { validateBody } from '@/lib/middleware/validate';
import { studentIdParamSchema, doubtLinkQuerySchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Doubt link — Pro & Elite only

// Ported from Express: router.get('/doubt-link/:studentId', featureGuard('doubt_solving'), validate(studentIdParamSchema, 'params'), validate(doubtLinkQuerySchema, 'query'), ctrl.doubtLink)
export async function GET(req: NextRequest, { params }: { params: Promise<{ studentId: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const tenantId = requireTenantId(user);
    await requireFeature(tenantId, 'doubt_solving');
    const { studentId } = validateBody(studentIdParamSchema, await params);
    const query = Object.fromEntries(req.nextUrl.searchParams);
    const { text } = validateBody(doubtLinkQuerySchema, query);
    const result = await svc.doubtLink(tenantId, user.userId, studentId, text);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
