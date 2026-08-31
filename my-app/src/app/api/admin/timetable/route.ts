import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/admin.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createTimetableSchema } from '@/lib/validators/admin.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/timetable', ctrl.listTimetable)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const { searchParams } = new URL(req.url);
    const day = searchParams.get('day') ?? undefined;
    const result = await svc.listTimetable(requireTenantId(user), day);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/timetable', subscriptionGuard, validate(createTimetableSchema), ctrl.createTimetable)
// TODO: port subscriptionGuard when subscription/plan features are migrated
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'coaching_admin');
    const body = validateBody(createTimetableSchema, await req.json());
    const result = await svc.createTimetableEntry(requireTenantId(user), body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
