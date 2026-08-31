import { NextRequest, NextResponse } from 'next/server';
import * as googleAuth from '@/lib/services/teacherGoogleAuth.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.delete('/google/disconnect', ctrl.disconnectGoogleAccount)
export async function DELETE(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    await googleAuth.disconnectGoogleAccount(user.userId);
    return NextResponse.json({ success: true });
  } catch (err) {
    return handleApiError(err);
  }
}
