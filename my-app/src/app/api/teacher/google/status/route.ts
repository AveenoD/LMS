import { NextRequest, NextResponse } from 'next/server';
import * as googleAuth from '@/lib/services/teacherGoogleAuth.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/google/status', ctrl.googleConnectionStatus)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const result = await googleAuth.getConnectionStatus(user.userId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
