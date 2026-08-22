/**
 * Mailer utility — placeholder for email sending logic.
 * Will be implemented when backend integration is needed.
 */

export interface EmailPayload {
  to: string;
  subject: string;
  body: string;
}

export async function sendEmail(payload: EmailPayload): Promise<boolean> {
  // TODO: Implement with actual email service (e.g., Resend, SendGrid)
  console.log("Email would be sent:", payload);
  return true;
}
