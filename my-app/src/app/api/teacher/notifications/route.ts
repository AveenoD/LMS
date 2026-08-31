import { NextRequest, NextResponse } from 'next/server';
import * as notificationCenter from '@/lib/services/notificationCenter.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/notifications', ctrl.listNotifications)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const result = await notificationCenter.listMyNotifications(user.userId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
