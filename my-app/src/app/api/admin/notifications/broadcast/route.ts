import { NextRequest, NextResponse } from 'next/server';
import * as notificationCenter from '@/lib/services/notificationCenter.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { broadcastNotificationSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/notifications/broadcast', subscriptionGuard, validate(broadcastNotificationSchema), ctrl.broadcastNotification)
// TODO: port subscriptionGuard when subscription/plan features are migrated
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { title, body, targetRole, batchId } = validateBody(broadcastNotificationSchema, await req.json());
    const result = await notificationCenter.broadcastNotification(
      { title, body, targetRole, tenantId: requireTenantId(user), batchId },
      user.userId
    );
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
