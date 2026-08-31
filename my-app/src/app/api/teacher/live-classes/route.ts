import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createLiveClassSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Live classes — Pro & Elite only
// TODO: port featureGuard('live_classes') when subscription/plan features are migrated

// Ported from Express: router.get('/live-classes', featureGuard('live_classes'), ctrl.listLiveClasses)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const result = await svc.listLiveClasses(requireTenantId(user), user.userId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/live-classes', featureGuard('live_classes'), validate(createLiveClassSchema), ctrl.createLiveClass)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const body = validateBody(createLiveClassSchema, await req.json());
    const result = await svc.createLiveClass(requireTenantId(user), user.userId, body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
