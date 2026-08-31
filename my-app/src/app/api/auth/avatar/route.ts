import { NextRequest, NextResponse } from 'next/server';
import * as authService from '@/lib/services/auth.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { updateAvatarSchema } from '@/lib/validators/auth.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.patch('/avatar', authMiddleware, validate(updateAvatarSchema), ctrl.updateAvatar)
export async function PATCH(req: NextRequest) {
  try {
    const authUser = requireAuth(req);
    const raw = await req.json();
    const body = validateBody(updateAvatarSchema, raw);
    const user = await authService.updateAvatar({ userId: authUser.userId, avatarUrl: body.avatarUrl });
    return NextResponse.json({ user });
  } catch (err) {
    return handleApiError(err);
  }
}
