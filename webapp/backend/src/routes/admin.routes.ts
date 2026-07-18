import { Router } from 'express';
import * as ctrl from '../controllers/admin.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { subscriptionGuard } from '../middleware/subscriptionGuard.js';
import { featureGuard } from '../middleware/featureGuard.js';
import { validate } from '../middleware/validate.js';
import {
  createTeacherSchema,
  createStudentSchema,
  createBatchSchema,
  createSubjectSchema,
  createTimetableSchema,
  createFeeStructureSchema,
  recordPaymentSchema,
  updateBrandingSchema,
  idParamSchema,
  studentIdParamSchema,
  broadcastToStudentsSchema,
} from '../validators/admin.validators.js';

const router = Router();

// All routes require a coaching_admin token.
router.use(authMiddleware, roleGuard('coaching_admin'));

// ── Reads (always allowed, even after trial expiry — soft lock) ───────────────
router.get('/dashboard', ctrl.dashboard);
router.get('/teachers', ctrl.listTeachers);
router.get('/students', ctrl.listStudents);
router.get('/students/:id/details', validate(idParamSchema, 'params'), ctrl.getStudentDetails);
router.get('/batches', ctrl.listBatches);
router.get('/subjects', ctrl.listSubjects);
router.get('/timetable', ctrl.listTimetable);
router.get('/fees', ctrl.listFees);
router.get('/fees/analytics', ctrl.feeAnalytics);
router.get('/branding', ctrl.getBranding);
router.get('/notifications', ctrl.listNotifications);
router.get('/notifications/unread-count', ctrl.unreadNotificationCount);
router.patch('/notifications/:id/read', validate(idParamSchema, 'params'), ctrl.markNotificationRead);

// Performance reports — Pro & Elite only
router.get('/reports/performance', featureGuard('performance_reports'), ctrl.performance);

// Fee remind via WhatsApp — Pro & Elite only (returns wa.me link)
router.post(
  '/fees/:studentId/remind',
  featureGuard('whatsapp_reminders'),
  validate(studentIdParamSchema, 'params'),
  ctrl.feeReminder
);

// ── Writes (blocked by subscriptionGuard when trial expired / past_due) ───────

// Teacher accounts — Elite only (max 3 allowed in plan)
router.post(
  '/teachers',
  subscriptionGuard,
  featureGuard('teacher_accounts'),
  validate(createTeacherSchema),
  ctrl.createTeacher
);
router.delete('/teachers/:id', subscriptionGuard, validate(idParamSchema, 'params'), ctrl.deleteTeacher);

router.post('/students', subscriptionGuard, validate(createStudentSchema), ctrl.createStudent);
router.put('/students/:id', subscriptionGuard, ctrl.updateStudent);
router.delete('/students/:id', subscriptionGuard, validate(idParamSchema, 'params'), ctrl.deleteStudent);
router.patch('/students/:id/suspend', subscriptionGuard, validate(idParamSchema, 'params'), ctrl.suspendStudent);

router.post('/batches', subscriptionGuard, validate(createBatchSchema), ctrl.createBatch);
router.post('/subjects', subscriptionGuard, validate(createSubjectSchema), ctrl.createSubject);

router.post('/timetable', subscriptionGuard, validate(createTimetableSchema), ctrl.createTimetable);

router.post('/fees/structures', subscriptionGuard, validate(createFeeStructureSchema), ctrl.createFeeStructure);
router.post('/fees/payments', subscriptionGuard, validate(recordPaymentSchema), ctrl.recordPayment);

// Custom branding (logo + colors) — Elite only
router.put(
  '/branding',
  subscriptionGuard,
  featureGuard('custom_branding'),
  validate(updateBrandingSchema),
  ctrl.updateBranding
);

router.post(
  '/notifications/broadcast',
  subscriptionGuard,
  validate(broadcastToStudentsSchema),
  ctrl.broadcastToStudents
);

export default router;

