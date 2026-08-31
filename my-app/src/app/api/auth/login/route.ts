import { NextRequest, NextResponse } from 'next/server';
import * as authService from '@/lib/services/auth.service';
import { validateBody } from '@/lib/middleware/validate';
import { loginSchema } from '@/lib/validators/auth.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.post('/login', authLimiter, validate(loginSchema), ctrl.login)
// Rate limiting (authLimiter) is applied separately — see docs/notes on Upstash migration.
export async function POST(req: NextRequest) {
  try {
    const raw = await req.json();
    const body = validateBody(loginSchema, raw);
    const result = await authService.login(body);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
