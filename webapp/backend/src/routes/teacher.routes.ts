import { Router } from 'express';
import * as ctrl from '../controllers/teacher.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { featureGuard } from '../middleware/featureGuard.js';
import { validate } from '../middleware/validate.js';
import {
  markAttendanceSchema,
  createContentSchema,
  createLiveClassSchema,
  batchIdParamSchema,
  studentIdParamSchema,
  doubtLinkQuerySchema,
} from '../validators/teacher.validators.js';

const router = Router();
router.use(authMiddleware, roleGuard('teacher'));

router.get('/schedule/today', ctrl.todaySchedule);
router.get('/batches/:batchId/students', validate(batchIdParamSchema, 'params'), ctrl.batchStudents);

// Attendance — all plans (present/absent/late saved for everyone)
// WhatsApp absent-reminder links are filtered inside the service based on plan
router.post('/attendance', validate(markAttendanceSchema), ctrl.markAttendance);

// Video content — all plans (Basic has video library)
router.get('/content', ctrl.listContent);
router.post('/content', validate(createContentSchema), ctrl.createContent);

// Live classes — Pro & Elite only
router.post(
  '/live-classes',
  featureGuard('live_classes'),
  validate(createLiveClassSchema),
  ctrl.createLiveClass
);

// Doubt link — Pro & Elite only
router.get(
  '/doubt-link/:studentId',
  featureGuard('doubt_solving'),
  validate(studentIdParamSchema, 'params'),
  validate(doubtLinkQuerySchema, 'query'),
  ctrl.doubtLink
);

export default router;

