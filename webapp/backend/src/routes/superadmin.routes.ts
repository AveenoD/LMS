import { Router } from 'express';
import * as ctrl from '../controllers/superadmin.controller.js';
import * as leadCtrl from '../controllers/lead.controller.js';
import * as planCtrl from '../controllers/plan.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { validate } from '../middleware/validate.js';
import {
  registerTenantSchema,
  suspendSchema,
  idParamSchema,
  expiringQuerySchema,
  broadcastToAdminsSchema,
  analyticsQuerySchema,
} from '../validators/superadmin.validators.js';
import { updateLeadStatusSchema } from '../validators/lead.validators.js';
import {
  createPlanSchema,
  updatePlanSchema,
  assignPlanSchema,
} from '../validators/plan.validators.js';

const router = Router();

// All super-admin routes require a super_admin token.
router.use(authMiddleware, roleGuard('super_admin'));

// ── Tenants ──────────────────────────────────────────────────────────────────
router.get('/tenants', ctrl.listTenants);
router.post('/tenants', validate(registerTenantSchema), ctrl.registerTenant);
router.patch(
  '/tenants/:id/suspend',
  validate(idParamSchema, 'params'),
  validate(suspendSchema),
  ctrl.suspendTenant
);

// Tenant subscription management (assign plan / view detail)
router.get('/tenants/:id/subscription', validate(idParamSchema, 'params'), planCtrl.getTenantSubscription);
router.put(
  '/tenants/:id/subscription',
  validate(idParamSchema, 'params'),
  validate(assignPlanSchema),
  planCtrl.assignPlan
);

// ── Subscriptions (overview) ──────────────────────────────────────────────────
router.get('/subscriptions', ctrl.listSubscriptions);
router.get('/subscriptions/expiring', validate(expiringQuerySchema, 'query'), ctrl.expiring);

// ── Plan Catalog CRUD ─────────────────────────────────────────────────────────
router.get('/plans', planCtrl.listPlans);
router.get('/plans/:id', validate(idParamSchema, 'params'), planCtrl.getPlan);
router.post('/plans', validate(createPlanSchema), planCtrl.createPlan);
router.put('/plans/:id', validate(idParamSchema, 'params'), validate(updatePlanSchema), planCtrl.updatePlan);
router.delete('/plans/:id', validate(idParamSchema, 'params'), planCtrl.deactivatePlan);

// ── Analytics ────────────────────────────────────────────────────────────────
router.get('/analytics', validate(analyticsQuerySchema, 'query'), ctrl.analytics);

// ── Leads (in-app demo-booking inbox) ────────────────────────────────────────
router.get('/leads', leadCtrl.listLeads);
router.get('/leads/unread-count', leadCtrl.unreadCount);
router.patch('/leads/:id/read', validate(idParamSchema, 'params'), leadCtrl.markRead);
router.patch(
  '/leads/:id/status',
  validate(idParamSchema, 'params'),
  validate(updateLeadStatusSchema),
  leadCtrl.updateStatus
);

// ── Notifications (broadcast to coaching_admins) ──────────────────────────────
router.post('/notifications/broadcast', validate(broadcastToAdminsSchema), ctrl.broadcastToAdmins);

export default router;
