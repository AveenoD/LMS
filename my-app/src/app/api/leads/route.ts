import { NextRequest, NextResponse } from 'next/server';
import * as leadService from '@/lib/services/lead.service';
import { validateBody } from '@/lib/middleware/validate';
import { createLeadSchema } from '@/lib/validators/lead.validators';
import { handleApiError } from '@/lib/utils/apiResponse';

/**
 * PUBLIC endpoint — the marketing site's "Book a Demo" form posts here.
 * Persists the lead + fires free notifications (email + telegram + in-app inbox).
 * NO auth required — mirrors Express's unauthenticated lead.routes.ts.
 */
// Ported from Express: router.post('/', leadLimiter, validate(createLeadSchema), ctrl.createLead)
// TODO: add rate limiting (e.g. Upstash Redis) once available — was leadLimiter in Express
export async function POST(req: NextRequest) {
  try {
    const body = validateBody(createLeadSchema, await req.json());
    const lead = await leadService.createLead(body);
    return NextResponse.json(
      {
        success: true,
        message: 'Thanks! Our team will contact you shortly.',
        leadId: lead.id,
      },
      { status: 201 }
    );
  } catch (err) {
    return handleApiError(err);
  }
}
