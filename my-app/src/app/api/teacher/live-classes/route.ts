import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { requireFeature } from '@/lib/middleware/featureGuard';
import { validateBody } from '@/lib/middleware/validate';
import { createLiveClassSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Live classes — Pro & Elite only

// Ported from Express: router.get('/live-classes', featureGuard('live_classes'), ctrl.listLiveClasses)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const tenantId = requireTenantId(user);
    await requireFeature(tenantId, 'live_classes');
    const result = await svc.listLiveClasses(tenantId, user.userId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/live-classes', featureGuard('live_classes'), validate(createLiveClassSchema), ctrl.createLiveClass)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const tenantId = requireTenantId(user);
    await requireFeature(tenantId, 'live_classes');
    const body = validateBody(createLiveClassSchema, await req.json());
    const result = await svc.createLiveClass(tenantId, user.userId, body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
