import { NextRequest, NextResponse } from 'next/server';
import { requireCronSecret } from '@/lib/middleware/cronAuth';
import { runLiveClassReminderSweep } from '@/lib/jobs/liveClassReminder.job';
import { handleApiError } from '@/lib/utils/apiResponse';

// Triggered externally (cron-job.org) every 5 minutes.
// Was: node-cron `*/5 * * * *` in backend/src/jobs/liveClassReminder.job.ts
export async function GET(req: NextRequest) {
  try {
    requireCronSecret(req);
    const result = await runLiveClassReminderSweep();
    return NextResponse.json({ success: true, ...result });
  } catch (err) {
    return handleApiError(err);
  }
}
