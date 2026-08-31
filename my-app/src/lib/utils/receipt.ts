/**
 * Generate a human-readable, unique-ish receipt number.
 * Format: RCPT-<tenantId>-<YYYYMMDD>-<random4>
 */
export function generateReceiptNo(tenantId: number | string): string {
  const d = new Date();
  const ymd = `${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, '0')}${String(
    d.getDate()
  ).padStart(2, '0')}`;
  const rand = Math.random().toString(36).slice(2, 6).toUpperCase();
  return `RCPT-${tenantId}-${ymd}-${rand}`;
}
