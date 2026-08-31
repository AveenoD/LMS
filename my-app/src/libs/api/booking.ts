// Same-origin: the marketing site and API are the same Next.js deployment
// now, so no base URL/host/port is needed.

export interface BookingData {
  instituteName: string;
  ownerName: string;
  phone: string;
  email?: string;
  city?: string;
  studentCount?: number;
  message?: string;
}

export interface BookingResult {
  success: boolean;
  message: string;
}

export async function submitBooking(data: BookingData): Promise<BookingResult> {
  const res = await fetch("/api/leads", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  const payload = await res.json().catch(() => null);

  if (!res.ok) {
    const detailMessage = payload?.error?.details?.[0]?.message;
    const message = detailMessage || payload?.error?.message || "Something went wrong. Please try again.";
    throw new Error(message);
  }

  return { success: true, message: payload?.message || "Thanks! Our team will contact you shortly." };
}
