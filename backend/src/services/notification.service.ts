import nodemailer from 'nodemailer';
import type { Transporter } from 'nodemailer';
import env from '../config/env.js';
import logger from '../utils/logger.js';
import type { LeadRow } from '../db/rows.js';

/**
 * FREE, reliable demo-booking notifications — no paid WhatsApp API.
 * Three independent channels, each best-effort (a failure in one never blocks
 * the others or the API response):
 *   1) EMAIL   (SMTP: free Gmail App Password or Resend free tier)   — primary record
 *   2) TELEGRAM(Bot API, 100% free forever)                          — instant phone push
 *   3) IN-APP  (lead already saved to DB → shown in Super Admin panel)
 *
 * All three are triggered from lead.service after the lead is persisted.
 */

let _transporter: Transporter | null = null;
function getTransporter(): Transporter {
  if (_transporter) return _transporter;
  const { host, port, user, pass } = env.notify.email;
  _transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: user ? { user, pass } : undefined,
  });
  return _transporter;
}

function formatLead(lead: LeadRow): string {
  return [
    `Owner       : ${lead.owner_name}`,
    `Institute   : ${lead.institute_name}`,
    `Phone       : ${lead.phone}`,
    `Email       : ${lead.email || '-'}`,
    `City        : ${lead.city || '-'}`,
    `Students    : ${lead.student_count ?? '-'}`,
    lead.message ? `Message     : ${lead.message}` : null,
    `Received    : ${new Date(lead.created_at).toLocaleString('en-IN')}`,
  ]
    .filter(Boolean)
    .join('\n');
}

async function sendEmail(lead: LeadRow): Promise<boolean> {
  const cfg = env.notify.email;
  if (!cfg.enabled || !cfg.host || !cfg.to) {
    logger.debug('Email notify skipped (disabled or not configured)');
    return false;
  }
  try {
    await getTransporter().sendMail({
      from: cfg.from,
      to: cfg.to,
      subject: `🔥 New Demo Lead: ${lead.institute_name} (${lead.city || 'N/A'})`,
      text: formatLead(lead),
      html: `<h2>🔥 New Demo Lead</h2><pre style="font-size:14px">${formatLead(lead)}</pre>
             <p><a href="https://wa.me/${lead.phone}">Message ${lead.owner_name} on WhatsApp</a></p>`,
    });
    logger.info('Lead email sent', { to: cfg.to, lead: lead.id });
    return true;
  } catch (err) {
    logger.error('Lead email failed', { error: err instanceof Error ? err.message : String(err) });
    return false;
  }
}

async function sendTelegram(lead: LeadRow): Promise<boolean> {
  const cfg = env.notify.telegram;
  if (!cfg.enabled || !cfg.botToken || !cfg.chatId) {
    logger.debug('Telegram notify skipped (disabled or not configured)');
    return false;
  }
  const text =
    `🔥 *New Demo Lead*\n\n` +
    `*${lead.institute_name}* — ${lead.city || 'N/A'}\n` +
    `👤 ${lead.owner_name}\n` +
    `📞 ${lead.phone}\n` +
    `🎓 ${lead.student_count ?? '?'} students`;
  try {
    const res = await fetch(`https://api.telegram.org/bot${cfg.botToken}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chat_id: cfg.chatId, text, parse_mode: 'Markdown' }),
    });
    if (!res.ok) {
      logger.error('Telegram notify failed', { status: res.status, body: await res.text() });
      return false;
    }
    logger.info('Lead Telegram sent', { lead: lead.id });
    return true;
  } catch (err) {
    logger.error('Telegram notify error', { error: err instanceof Error ? err.message : String(err) });
    return false;
  }
}

/**
 * Fire email + telegram in parallel (best-effort). Returns true if AT LEAST
 * one external channel succeeded (in-app inbox always works regardless).
 */
export async function notifyNewLead(lead: LeadRow): Promise<boolean> {
  const [email, telegram] = await Promise.all([sendEmail(lead), sendTelegram(lead)]);
  return email || telegram;
}

export interface EmailChannelStatus {
  enabled: boolean;
  ok?: boolean;
  error?: string;
}

/** Verify SMTP connectivity (used by a health/diagnostic route). */
export async function verifyEmailChannel(): Promise<EmailChannelStatus> {
  if (!env.notify.email.enabled) return { enabled: false };
  try {
    await getTransporter().verify();
    return { enabled: true, ok: true };
  } catch (err) {
    return { enabled: true, ok: false, error: err instanceof Error ? err.message : String(err) };
  }
}
