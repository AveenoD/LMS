import { randomUUID } from 'crypto';
import { google } from 'googleapis';
import { getAuthedClientForTeacher } from './teacherGoogleAuth.service.js';
import ApiError from '../utils/ApiError.js';

export interface CreatedMeetEvent {
  eventId: string;
  meetUrl: string;
}

/**
 * Creates a Calendar event on the given teacher's own Google Calendar, with
 * auto-generated Meet conferencing, and returns the resulting join link.
 * Requires the teacher to have connected their Google account (see
 * teacherGoogleAuth.service.ts) — a bare service account cannot create
 * Meet-conferencing events without Google Workspace, so this must run as
 * the teacher's own OAuth identity.
 */
export async function createMeetEvent(
  teacherUserId: number,
  input: { title: string; scheduledAt: string; durationMinutes?: number }
): Promise<CreatedMeetEvent> {
  const auth = await getAuthedClientForTeacher(teacherUserId);
  const calendar = google.calendar({ version: 'v3', auth });

  const start = new Date(input.scheduledAt);
  const end = new Date(start.getTime() + (input.durationMinutes ?? 60) * 60_000);

  const { data } = await calendar.events.insert({
    calendarId: 'primary',
    conferenceDataVersion: 1,
    requestBody: {
      summary: input.title,
      start: { dateTime: start.toISOString() },
      end: { dateTime: end.toISOString() },
      conferenceData: {
        createRequest: {
          requestId: randomUUID(),
          conferenceSolutionKey: { type: 'hangoutsMeet' },
        },
      },
    },
  });

  const meetUrl = data.hangoutLink;
  if (!data.id || !meetUrl) {
    throw new ApiError(502, 'GOOGLE_MEET_CREATE_FAILED', 'Google did not return a Meet link for this event.');
  }

  return { eventId: data.id, meetUrl };
}

/** Best-effort delete — a missing/already-deleted event, or a teacher who
 *  has since disconnected Google, is not an error here. */
export async function deleteMeetEvent(teacherUserId: number, eventId: string): Promise<void> {
  let auth;
  try {
    auth = await getAuthedClientForTeacher(teacherUserId);
  } catch {
    return; // teacher disconnected Google since — nothing we can clean up
  }
  const calendar = google.calendar({ version: 'v3', auth });

  try {
    await calendar.events.delete({ calendarId: 'primary', eventId });
  } catch (err) {
    const status = (err as { code?: number; response?: { status?: number } })?.response?.status;
    if (status === 404 || status === 410) return; // already gone — fine
    throw err;
  }
}
