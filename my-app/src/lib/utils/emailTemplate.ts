/**
 * Shared HTML wrapper for tenant-facing transactional emails (fee due,
 * attendance, live class reminders, etc.), matching the app's theme —
 * same palette as my-app/src/app/globals.css (--ink-green, --brass-gold,
 * --chalk-teal). Table-based layout for broad email-client compatibility.
 */
export function renderNotificationEmail(title: string, body: string | undefined): string {
  const safeTitle = escapeHtml(title);
  const safeBody = body ? escapeHtml(body) : '';

  return `<!doctype html>
<html>
  <body style="margin:0; padding:0; background-color:#F4F6F3; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#F4F6F3; padding:32px 16px;">
      <tr>
        <td align="center">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:480px; background-color:#FFFFFF; border-radius:16px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,0.06);">
            <tr>
              <td style="background-color:#1F2E27; padding:20px 28px;">
                <img src="https://my-app-tau-umber-67.vercel.app/logo-white.png" alt="EdTech OS" width="36" height="36" style="display:block; margin-bottom:8px;" />
                <span style="color:#FFFFFF; font-size:18px; font-weight:700; letter-spacing:0.02em;">EdTech OS</span>
              </td>
            </tr>
            <tr>
              <td style="padding:28px;">
                <h1 style="margin:0 0 12px; color:#1F2E27; font-size:20px; font-weight:700; line-height:1.3;">
                  ${safeTitle}
                </h1>
                ${
                  safeBody
                    ? `<p style="margin:0; color:#1F2E27B3; font-size:14px; line-height:1.6;">${safeBody}</p>`
                    : ''
                }
              </td>
            </tr>
            <tr>
              <td style="padding:0 28px 28px;">
                <div style="height:1px; background-color:#F4F6F3; margin-bottom:20px;"></div>
                <p style="margin:0; color:#1F2E2780; font-size:12px; line-height:1.5;">
                  This is an automated notification from your institute's EdTech OS account.
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>`;
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
