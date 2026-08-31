import { NextRequest, NextResponse } from 'next/server';
import * as notificationCenter from '@/lib/services/notificationCenter.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.patch('/notifications/:id/read', validate(idParamSchema, 'params'), ctrl.markNotificationRead)
export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = requireAuth(req, 'teacher');
    const { id } = validateBody(idParamSchema, await params);
    await notificationCenter.markNotificationRead(id, user.userId);
    return NextResponse.json({ success: true });
  } catch (err) {
    return handleApiError(err);
  }
}
