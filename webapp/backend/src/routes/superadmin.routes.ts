import { Router } from 'express';
import * as ctrl from '../controllers/superadmin.controller.js';
import * as leadCtrl from '../controllers/lead.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { validate } from '../middleware/validate.js';
import {
  registerTenantSchema,
  suspendSchema,
  idParamSchema,
  expiringQuerySchema,
} from '../validators/superadmin.validators.js';
import { updateLeadStatusSchema } from '../validators/lead.validators.js';

const router = Router();

// All super-admin routes require a super_admin token.
router.use(authMiddleware, roleGuard('super_admin'));

// Tenants
router.get('/tenants', ctrl.listTenants);
router.post('/tenants', validate(registerTenantSchema), ctrl.registerTenant);
router.patch(
  '/tenants/:id/suspend',
  validate(idParamSchema, 'params'),
  validate(suspendSchema),
  ctrl.suspendTenant
);

// Subscriptions
router.get('/subscriptions', ctrl.listSubscriptions);
router.get('/subscriptions/expiring', validate(expiringQuerySchema, 'query'), ctrl.expiring);

// Analytics
router.get('/analytics', ctrl.analytics);

// Leads (in-app demo-booking inbox)
router.get('/leads', leadCtrl.listLeads);
router.get('/leads/unread-count', leadCtrl.unreadCount);
router.patch('/leads/:id/read', validate(idParamSchema, 'params'), leadCtrl.markRead);
router.patch(
  '/leads/:id/status',
  validate(idParamSchema, 'params'),
  validate(updateLeadStatusSchema),
  leadCtrl.updateStatus
);

export default router;
