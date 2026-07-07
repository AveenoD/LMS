import { Router } from 'express';
import * as ctrl from '../controllers/auth.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { validate } from '../middleware/validate.js';
import { authLimiter } from '../middleware/rateLimiter.js';
import { loginSchema, refreshSchema } from '../validators/auth.validators.js';

const router = Router();

router.post('/login', authLimiter, validate(loginSchema), ctrl.login);
router.post('/refresh', authLimiter, validate(refreshSchema), ctrl.refresh);
router.get('/me', authMiddleware, ctrl.me);
router.post('/logout', authMiddleware, ctrl.logout);

export default router;
