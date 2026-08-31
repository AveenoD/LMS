import { NextRequest, NextResponse } from 'next/server';
import * as notificationCenter from '@/lib/services/notificationCenter.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { broadcastToAdminsSchema } from '@/lib/validators/superadmin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

/** Broadcast a notification to coaching_admins — all institutes, or filtered by city. */
// Ported from Express: router.post('/notifications/broadcast', validate(broadcastToAdminsSchema), ctrl.broadcastToAdmins)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'super_admin');
    const { title, body, city } = validateBody(broadcastToAdminsSchema, await req.json());
    const result = await notificationCenter.broadcastNotification(
      { title, body, targetRole: 'coaching_admin', tenantId: null, city },
      user.userId
    );
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
