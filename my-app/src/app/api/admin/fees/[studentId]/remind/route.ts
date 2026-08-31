import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { studentIdParamSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/fees/:studentId/remind', featureGuard('whatsapp_reminders'), validate(studentIdParamSchema, 'params'), ctrl.feeReminder)
// TODO: port featureGuard('whatsapp_reminders') when subscription/plan features are migrated
export async function POST(req: NextRequest, { params }: { params: Promise<{ studentId: string }> }) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { studentId } = validateBody(studentIdParamSchema, await params);
    const result = await svc.feeReminderLink(requireTenantId(user), studentId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
