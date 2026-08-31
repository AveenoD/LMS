import { NextRequest, NextResponse } from 'next/server';
import * as svc from '@/lib/services/teacher.service';
import { requireAuth, requireTenantId } from '@/lib/middleware/auth';
import { validateBody } from '@/lib/middleware/validate';
import { createContentSchema } from '@/lib/validators/teacher.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/content', ctrl.listContent)
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const chapterIdRaw = req.nextUrl.searchParams.get('chapterId');
    const chapterId = chapterIdRaw ? Number(chapterIdRaw) : undefined;
    const result = await svc.listContent(requireTenantId(user), user.userId, chapterId);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}

// Ported from Express: router.post('/content', validate(createContentSchema), ctrl.createContent)
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req, 'teacher');
    const body = validateBody(createContentSchema, await req.json());
    const result = await svc.createContent(requireTenantId(user), user.userId, body);
    return NextResponse.json(result, { status: 201 });
  } catch (err) {
    return handleApiError(err);
  }
}
