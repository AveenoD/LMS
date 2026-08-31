import { NextRequest, NextResponse } from 'next/server';
import { requireCronSecret } from '@/lib/middleware/cronAuth';
import { runFeeReminderSweep } from '@/lib/jobs/feeReminder.job';
import { handleApiError } from '@/lib/utils/apiResponse';

// Triggered externally (cron-job.org) once daily, e.g. 09:00 IST.
// Was: node-cron `0 9 * * *` in backend/src/jobs/feeReminder.job.ts
export async function GET(req: NextRequest) {
  try {
    requireCronSecret(req);
    const result = await runFeeReminderSweep();
    return NextResponse.json({ success: true, ...result });
  } catch (err) {
    return handleApiError(err);
  }
}
