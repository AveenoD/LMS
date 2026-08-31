import { NextRequest, NextResponse } from 'next/server';
import * as leadService from '@/lib/services/lead.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/leads', leadCtrl.listLeads)  — SUPER ADMIN in-app inbox
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'super_admin');
    const { searchParams } = new URL(req.url);
    const status = searchParams.get('status') ?? undefined;
    const result = await leadService.listLeads({ status });
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
