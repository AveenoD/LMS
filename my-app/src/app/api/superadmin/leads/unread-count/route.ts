import { NextRequest, NextResponse } from 'next/server';
import * as leadService from '@/lib/services/lead.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/leads/unread-count', leadCtrl.unreadCount)
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'super_admin');
    const count = await leadService.unreadCount();
    return NextResponse.json({ count });
  } catch (err) {
    return handleApiError(err);
  }
}
