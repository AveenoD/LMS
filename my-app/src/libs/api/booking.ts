const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000/api/v1";

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
  const res = await fetch(`${API_BASE_URL}/leads`, {
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
