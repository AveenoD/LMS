import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/superadmin.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { expiringQuerySchema } from '@/lib/validators/superadmin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/subscriptions/expiring', validate(expiringQuerySchema, 'query'), ctrl.expiring)
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'super_admin');
    const { searchParams } = new URL(req.url);
    const query = validateBody(expiringQuerySchema, {
      days: searchParams.get('days') ?? undefined,
    });
    // query.days was coerced/validated by expiringQuerySchema — a real 0 is preserved
    // (previously `Number(...) || 3` silently overrode an explicit ?days=0).
    const days = query.days === undefined ? 3 : Number(query.days);
    const result = await svc.expiringSoon(days);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
