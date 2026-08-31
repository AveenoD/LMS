import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/superadmin.service';
import { requireAuth } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { analyticsQuerySchema } from '@/lib/validators/superadmin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/analytics', validate(analyticsQuerySchema, 'query'), ctrl.analytics)
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'super_admin');
    const { searchParams } = new URL(req.url);
    const query = validateBody(analyticsQuerySchema, {
      month: searchParams.get('month') ?? undefined,
      year: searchParams.get('year') ?? undefined,
    });
    const month = query.month ? Number(query.month) : undefined;
    const year = query.year ? Number(query.year) : undefined;
    const result = await svc.analytics(month, year);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
