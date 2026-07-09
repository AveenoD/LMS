import { Router } from 'express';
import * as ctrl from '../controllers/teacher.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
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
router.post('/attendance', validate(markAttendanceSchema), ctrl.markAttendance);
router.get('/content', ctrl.listContent);
router.post('/content', validate(createContentSchema), ctrl.createContent);
router.post('/live-classes', validate(createLiveClassSchema), ctrl.createLiveClass);
router.get(
  '/doubt-link/:studentId',
  validate(studentIdParamSchema, 'params'),
  validate(doubtLinkQuerySchema, 'query'),
  ctrl.doubtLink
);

export default router;
