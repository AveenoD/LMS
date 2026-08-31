import { NextRequest, NextResponse } from 'next/server';
import { requireCronSecret } from '@/lib/middleware/cronAuth';
import { runTestReminderSweep } from '@/lib/jobs/testReminder.job';
import { handleApiError } from '@/lib/utils/apiResponse';

// Triggered externally (cron-job.org) every 10 minutes.
// Was: node-cron `*/10 * * * *` in backend/src/jobs/testReminder.job.ts
export async function GET(req: NextRequest) {
  try {
    requireCronSecret(req);
    const result = await runTestReminderSweep();
    return NextResponse.json({ success: true, ...result });
  } catch (err) {
    return handleApiError(err);
  }
}
