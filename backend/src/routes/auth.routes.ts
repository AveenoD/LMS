import { Router } from 'express';
import * as ctrl from '../controllers/auth.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { validate } from '../middleware/validate.js';
import { authLimiter } from '../middleware/rateLimiter.js';
import {
  loginSchema,
  refreshSchema,
  updateAvatarSchema,
  registerDeviceTokenSchema,
  unregisterDeviceTokenSchema,
} from '../validators/auth.validators.js';
import { generateSignature } from '../services/cloudinary.service.js';

const router = Router();

router.post('/login', authLimiter, validate(loginSchema), ctrl.login);
router.post('/refresh', authLimiter, validate(refreshSchema), ctrl.refresh);
router.get('/me', authMiddleware, ctrl.me);
router.post('/logout', authMiddleware, ctrl.logout);
router.patch('/avatar', authMiddleware, validate(updateAvatarSchema), ctrl.updateAvatar);

// Cloudinary signature for profile-photo uploads — any authenticated role
// (unlike /teacher/upload-signature, which is gated to teachers only).
router.get('/upload-signature', authMiddleware, (req, res) => {
  res.json(generateSignature('campus/avatars'));
});

// Push notification device tokens — any authenticated role registers its own.
router.post('/device-token', authMiddleware, validate(registerDeviceTokenSchema), ctrl.registerDeviceToken);
router.delete('/device-token', authMiddleware, validate(unregisterDeviceTokenSchema), ctrl.unregisterDeviceToken);

export default router;
