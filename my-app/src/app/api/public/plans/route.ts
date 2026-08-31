import { NextResponse } from 'next/server';
import * as svc from '@/lib/services/plan.service';
import { handleApiError } from '@/lib/utils/apiResponse';

/**
 * PUBLIC endpoint — used by the marketing/pricing page to fetch plan data
 * dynamically (active plans only). NO auth required.
 */
// Ported from Express: router.get('/plans', planCtrl.listPublicPlans)  [public.routes.ts]
export async function GET() {
  try {
    const result = await svc.listPlans(true);
    return NextResponse.json(result);
  } catch (err) {
    return handleApiError(err);
  }
}
