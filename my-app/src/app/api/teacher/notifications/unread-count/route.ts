import { NextRequest, NextResponse } from 'next/server';
import * as notificationCenter from '@/lib/services/notificationCenter.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/notifications/unread-count', ctrl.unreadNotificationCount)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const count = await notificationCenter.unreadNotificationCount(user.userId);
    return NextResponse.json({ count });
  } catch (err) {
    return handleApiError(err);
  }
}
