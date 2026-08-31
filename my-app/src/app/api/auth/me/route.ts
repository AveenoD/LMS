import { NextRequest, NextResponse } from 'next/server';
import * as authService from '@/lib/services/auth.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/me', authMiddleware, ctrl.me)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req); // any authenticated role
    const result = await authService.me({ userId: user.userId });
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
