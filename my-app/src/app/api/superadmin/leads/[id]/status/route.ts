import { NextRequest, NextResponse } from 'next/server';
import * as leadService from '@/lib/services/lead.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { idParamSchema } from '@/lib/validators/superadmin.validators';
import { updateLeadStatusSchema } from '@/lib/validators/lead.validators';
import ApiError from '@/lib/utils/ApiError';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.patch('/leads/:id/status', validate(idParamSchema, 'params'), validate(updateLeadStatusSchema), leadCtrl.updateStatus)
export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    requireAuth(req, 'super_admin');
    const { id } = validateBody(idParamSchema, await params);
    const body = validateBody(updateLeadStatusSchema, await req.json());
    const updated = await leadService.updateStatus(id, body.status);
    if (!updated) throw ApiError.notFound('LEAD_NOT_FOUND');
    return NextResponse.json(updated);
  } catch (err) {
    return handleApiError(err);
  }
}
