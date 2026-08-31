import { NextRequest, NextResponse } from 'next/server';
import * as leadService from '@/lib/services/lead.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema } from '@/lib/validators/superadmin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.patch('/leads/:id/read', validate(idParamSchema, 'params'), leadCtrl.markRead)
export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    requireAuth(req, 'super_admin');
    const { id } = validateBody(idParamSchema, await params);
    await leadService.markRead(id);
    return NextResponse.json({ success: true });
  } catch (err) {
    return handleApiError(err);
  }
}
