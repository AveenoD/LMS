import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { requireFeature } from '@/lib/middleware/featureGuard';
import { validateBody } from '@/lib/middleware/validate';
import { studentIdParamSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/fees/:studentId/remind', featureGuard('whatsapp_reminders'), validate(studentIdParamSchema, 'params'), ctrl.feeReminder)
export async function POST(req: NextRequest, { params }: { params: Promise<{ studentId: string }> }) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const tenantId = requireTenantId(user);
    await requireFeature(tenantId, 'whatsapp_reminders');
    const { studentId } = validateBody(studentIdParamSchema, await params);
    const result = await svc.feeReminderLink(tenantId, studentId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
