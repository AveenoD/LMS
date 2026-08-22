/**
 * Zero-cost WhatsApp deep links (wa.me). This is NOT the paid WhatsApp
 * Business API — it just builds a click-to-chat URL that opens the user's own
 * WhatsApp app with a pre-filled message. No server, no fees, no message logs.
 * Used for: fee reminders, absentee alerts, and student doubt-solving.
 */
export function buildWaUrl(phone: string | number, message: string): string {
  let clean = String(phone).replace(/[^\d]/g, ''); // strip +, spaces, dashes
  if (clean.length === 10) {
    clean = '91' + clean; // Auto-append India country code
  }
  return `https://wa.me/${clean}?text=${encodeURIComponent(message)}`;
}

export function feeReminderMessage({
  parentName,
  studentName,
  feeTitle,
  pending,
  instituteName,
}: {
  parentName?: string | null;
  studentName: string;
  feeTitle: string;
  pending: number;
  instituteName: string;
}): string {
  return (
    `Namaste ${parentName || ''}, ${studentName} ki ${feeTitle} fees ₹${pending} ` +
    `pending hai. Kripya jaldi jama karein. - ${instituteName}`
  );
}

export function absentMessage({
  studentName,
  instituteName,
  date,
}: {
  studentName: string;
  instituteName: string;
  date: string;
}): string {
  return `Namaste, aaj ${date} ko ${studentName} class me absent the. - ${instituteName}`;
}

export function doubtMessage({
  studentName,
  instituteName,
  chapter,
}: {
  studentName: string;
  instituteName: string;
  chapter: string;
}): string {
  return `Sir, mujhe ${chapter} mein doubt hai. - ${studentName} (${instituteName})`;
}
