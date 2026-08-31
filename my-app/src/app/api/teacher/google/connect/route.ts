import { NextRequest, NextResponse } from 'next/server';
import * as googleAuth from '@/lib/services/teacherGoogleAuth.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { connectGoogleSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/google/connect', validate(connectGoogleSchema), ctrl.connectGoogleAccount)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const body = validateBody(connectGoogleSchema, await req.json());
    const result = await googleAuth.connectGoogleAccount(user.userId, requireTenantId(user), body.serverAuthCode);
    return NextResponse.json({ success: true, googleEmail: result.googleEmail });
  } catch (err) {
    return handleApiError(err);
  }
}
