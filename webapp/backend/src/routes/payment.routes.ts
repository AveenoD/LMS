import { Router } from 'express';
import * as ctrl from '../controllers/payment.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { validate } from '../middleware/validate.js';
import { verifyPaymentSchema } from '../validators/payment.validators.js';

const router = Router();
router.use(authMiddleware, roleGuard('coaching_admin'));

router.post('/create-order', ctrl.createOrder);
router.post('/verify', validate(verifyPaymentSchema), ctrl.verify);
router.get('/subscription', ctrl.status);

export default router;
