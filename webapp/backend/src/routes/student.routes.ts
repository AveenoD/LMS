import { Router } from 'express';
import * as ctrl from '../controllers/student.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { validate } from '../middleware/validate.js';
import {
  idParamSchema,
  paymentIdParamSchema,
  listVideosQuerySchema,
  askDoubtQuerySchema,
} from '../validators/student.validators.js';

const router = Router();
router.use(authMiddleware, roleGuard('student'));

router.get('/dashboard', ctrl.dashboard);
router.get('/videos', validate(listVideosQuerySchema, 'query'), ctrl.listVideos);
router.get('/videos/:id', validate(idParamSchema, 'params'), ctrl.videoDetail);
router.get('/live/today', ctrl.todayLive);
router.get('/fees', ctrl.fees);
router.get('/fees/receipt/:paymentId', validate(paymentIdParamSchema, 'params'), ctrl.receipt);
router.get('/ask-doubt', validate(askDoubtQuerySchema, 'query'), ctrl.askDoubt);
router.get('/notifications', ctrl.listNotifications);
router.get('/notifications/unread-count', ctrl.unreadNotificationCount);
router.patch('/notifications/:id/read', validate(idParamSchema, 'params'), ctrl.markNotificationRead);

export default router;
