import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { requireFeature } from '@/lib/middleware/featureGuard';
import { validateBody } from '@/lib/middleware/validate';
import { liveClassIdParamSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Live classes — Pro & Elite only

// Ported from Express: router.patch('/live-classes/:id/end', featureGuard('live_classes'), validate(liveClassIdParamSchema, 'params'), ctrl.endLiveClass)
export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const tenantId = requireTenantId(user);
    await requireFeature(tenantId, 'live_classes');
    const { id } = validateBody(liveClassIdParamSchema, await params);
    await svc.endLiveClass(tenantId, user.userId, id);
    return NextResponse.json({ success: true });
  } catch (err) {
    return handleApiError(err);
  }
}
