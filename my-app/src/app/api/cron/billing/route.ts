import { NextRequest, NextResponse } from 'next/server';
import { requireCronSecret } from '@/lib/middleware/cronAuth';
import { runBillingSweep } from '@/lib/jobs/billing.job';
import { handleApiError } from '@/lib/utils/apiResponse';

// Triggered externally (cron-job.org) once daily, e.g. 02:00 IST.
// Was: node-cron `0 2 * * *` in backend/src/jobs/billing.job.ts
export async function GET(req: NextRequest) {
  try {
    requireCronSecret(req);
    const result = await runBillingSweep();
    return NextResponse.json({ success: true, ...result });
  } catch (err) {
    return handleApiError(err);
  }
}
