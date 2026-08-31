import { NextRequest, NextResponse } from 'next/server';
import * as authService from '@/lib/services/auth.service';
import { validateBody } from '@/lib/middleware/validate';
import { refreshSchema } from '@/lib/validators/auth.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/refresh', authLimiter, validate(refreshSchema), ctrl.refresh)
export async function POST(req: NextRequest) {
  try {
    const raw = await req.json();
    const body = validateBody(refreshSchema, raw);
    const result = await authService.refresh(body);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
