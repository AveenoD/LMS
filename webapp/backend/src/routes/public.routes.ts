import { Router } from 'express';
import * as planCtrl from '../controllers/plan.controller.js';

const router = Router();

/**
 * Unauthenticated public endpoints — no auth middleware.
 * Used by the marketing/pricing page to fetch plan data dynamically.
 */

// GET /api/v1/public/plans  → returns active plans with prices + features
router.get('/plans', planCtrl.listPublicPlans);

export default router;
