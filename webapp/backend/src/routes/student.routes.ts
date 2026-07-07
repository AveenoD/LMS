import { Router } from 'express';
import * as ctrl from '../controllers/student.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';

const router = Router();
router.use(authMiddleware, roleGuard('student'));

router.get('/dashboard', ctrl.dashboard);
router.get('/videos', ctrl.listVideos);
router.get('/videos/:id', ctrl.videoDetail);
router.get('/live/today', ctrl.todayLive);
router.get('/fees', ctrl.fees);
router.get('/fees/receipt/:paymentId', ctrl.receipt);
router.get('/ask-doubt', ctrl.askDoubt);

export default router;
