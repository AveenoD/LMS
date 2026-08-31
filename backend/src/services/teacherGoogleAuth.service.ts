import { query } from '../config/db.js';
import { createOAuth2Client } from '../config/googleCalendar.js';
import ApiError from '../utils/ApiError.js';

type OAuth2Client = ReturnType<typeof createOAuth2Client>;

/**
 * Exchanges the one-time server auth code (from the mobile app's
 * google_sign_in authorizeServer call) for a refresh token, and stores it
 * against the teacher. Called once at "Connect Google Account" time.
 */
export async function connectGoogleAccount(
  userId: number,
  tenantId: number,
  serverAuthCode: string
): Promise<{ googleEmail: string | null }> {
  const client = createOAuth2Client();

  let tokens;
  try {
    ({ tokens } = await client.getToken(serverAuthCode));
  } catch {
    throw ApiError.badRequest('GOOGLE_AUTH_CODE_INVALID', 'That Google authorization could not be completed. Please try connecting again.');
  }

  if (!tokens.refresh_token) {
    throw ApiError.badRequest(
      'GOOGLE_NO_REFRESH_TOKEN',
      'Google did not grant offline access. Disconnect this app in your Google Account settings and try connecting again.'
    );
  }

  let googleEmail: string | null = null;
  try {
    client.setCredentials(tokens);
    const oauth2 = (await import('googleapis')).google.oauth2({ version: 'v2', auth: client });
    const { data } = await oauth2.userinfo.get();
    googleEmail = data.email ?? null;
  } catch {
    googleEmail = null; // non-fatal — the connection still works without a cached display email
  }

  await query(
    `INSERT INTO teacher_google_tokens (user_id, tenant_id, refresh_token, google_email)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (user_id) DO UPDATE
       SET refresh_token = $3, google_email = $4, connected_at = now()`,
    [userId, tenantId, tokens.refresh_token, googleEmail]
  );

  return { googleEmail };
}

export async function disconnectGoogleAccount(userId: number): Promise<void> {
  await query(`DELETE FROM teacher_google_tokens WHERE user_id = $1`, [userId]);
}

export interface GoogleConnectionStatus {
  connected: boolean;
  googleEmail: string | null;
  connectedAt: string | null;
}

export async function getConnectionStatus(userId: number): Promise<GoogleConnectionStatus> {
  const { rows } = await query<{ google_email: string | null; connected_at: string }>(
    `SELECT google_email, connected_at FROM teacher_google_tokens WHERE user_id = $1`,
    [userId]
  );
  if (!rows.length) return { connected: false, googleEmail: null, connectedAt: null };
  return { connected: true, googleEmail: rows[0].google_email, connectedAt: rows[0].connected_at };
}

/**
 * Returns an OAuth2 client authenticated as the given teacher, ready for
 * Calendar API calls. Throws a clear, actionable error if the teacher hasn't
 * connected their Google account yet.
 */
export async function getAuthedClientForTeacher(userId: number): Promise<OAuth2Client> {
  const { rows } = await query<{ refresh_token: string }>(
    `SELECT refresh_token FROM teacher_google_tokens WHERE user_id = $1`,
    [userId]
  );
  if (!rows.length) {
    throw ApiError.badRequest(
      'GOOGLE_NOT_CONNECTED',
      'Connect your Google account first to schedule a live class with an auto-generated Meet link.'
    );
  }

  const client = createOAuth2Client();
  client.setCredentials({ refresh_token: rows[0].refresh_token });
  return client;
}
