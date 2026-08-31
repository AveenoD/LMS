import { NextRequest, NextResponse } from 'next/server';
import { generateSignature } from '@/lib/services/cloudinary.service';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

// Ported from Express: router.get('/upload-signature', (req, res) => { res.json(generateSignature('edtech_os')); })
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'teacher');
    return NextResponse.json(generateSignature('edtech_os'));
  } catch (err) {
    return handleApiError(err);
  }
}
