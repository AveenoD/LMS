import { Router } from 'express';
import * as ctrl from '../controllers/lead.controller.js';
import { validate } from '../middleware/validate.js';
import { leadLimiter } from '../middleware/rateLimiter.js';
import { createLeadSchema } from '../validators/lead.validators.js';

const router = Router();

/**
 * PUBLIC endpoint — the marketing site's "Book a Demo" form posts here.
 * Rate-limited to prevent spam. Persists the lead + fires free notifications
 * (email + telegram + in-app inbox).
 */
router.post('/', leadLimiter, validate(createLeadSchema), ctrl.createLead);

export default router;
