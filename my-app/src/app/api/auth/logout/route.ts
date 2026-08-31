import { NextResponse } from 'next/server';

// Ported from Express: router.post('/logout', authMiddleware, ctrl.logout)
// Stateless JWT: client discards tokens. (Refresh-token blacklist is a future item.)
export async function POST() {
  return NextResponse.json({ success: true });
}
