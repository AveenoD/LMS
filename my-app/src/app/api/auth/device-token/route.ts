import { NextRequest, NextResponse } from 'next/server';
import * as notificationCenter from '@/lib/services/notificationCenter.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { registerDeviceTokenSchema, unregisterDeviceTokenSchema } from '@/lib/validators/auth.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/device-token', authMiddleware, validate(registerDeviceTokenSchema), ctrl.registerDeviceToken)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req);
    const raw = await req.json();
    const body = validateBody(registerDeviceTokenSchema, raw);
    await notificationCenter.registerDeviceToken(user.userId, user.tenantId ?? null, body.token, body.platform);
    return NextResponse.json({ success: true });
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.delete('/device-token', authMiddleware, validate(unregisterDeviceTokenSchema), ctrl.unregisterDeviceToken)
export async function DELETE(req: NextRequest) {
  try {
    const user = requireAuth(req);
    const raw = await req.json();
    const body = validateBody(unregisterDeviceTokenSchema, raw);
    await notificationCenter.unregisterDeviceToken(user.userId, body.token);
    return NextResponse.json({ success: true });
  } catch (err) {
    return handleApiError(err);
  }
}
