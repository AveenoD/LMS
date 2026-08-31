import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/student.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';
import ApiError from '@/lib/utils/ApiError';

// Ported from Express: router.post('/progress', ctrl.updateProgress)
// Note: this controller does inline validation, NOT zod's validate() — ported verbatim.
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'student');
    const body = await req.json();
    const { contentId, progressSeconds } = body;
    if (!contentId || progressSeconds == null) throw ApiError.badRequest('Missing contentId or progressSeconds');
    await svc.updateProgress(requireTenantId(user), user.userId, Number(contentId), Number(progressSeconds));
    return NextResponse.json({ success: true });
  } catch (err) {
    return handleApiError(err);
  }
}
