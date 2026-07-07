import { Router } from 'express';
import * as ctrl from '../controllers/admin.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { subscriptionGuard } from '../middleware/subscriptionGuard.js';
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
} from '../validators/admin.validators.js';

const router = Router();

// All routes require a coaching_admin token.
router.use(authMiddleware, roleGuard('coaching_admin'));

// Reads (always allowed, even after trial expiry — soft lock)
router.get('/dashboard', ctrl.dashboard);
router.get('/teachers', ctrl.listTeachers);
router.get('/students', ctrl.listStudents);
router.get('/batches', ctrl.listBatches);
router.get('/subjects', ctrl.listSubjects);
router.get('/timetable', ctrl.listTimetable);
router.get('/fees', ctrl.listFees);
router.get('/fees/:studentId/remind', ctrl.feeReminder);
router.get('/reports/performance', ctrl.performance);
router.get('/branding', ctrl.getBranding);

// Writes (blocked by subscriptionGuard when trial expired / past_due)
router.post('/teachers', subscriptionGuard, validate(createTeacherSchema), ctrl.createTeacher);
router.delete('/teachers/:id', subscriptionGuard, ctrl.deleteTeacher);

router.post('/students', subscriptionGuard, validate(createStudentSchema), ctrl.createStudent);
router.delete('/students/:id', subscriptionGuard, ctrl.deleteStudent);

router.post('/batches', subscriptionGuard, validate(createBatchSchema), ctrl.createBatch);
router.post('/subjects', subscriptionGuard, validate(createSubjectSchema), ctrl.createSubject);

router.post('/timetable', subscriptionGuard, validate(createTimetableSchema), ctrl.createTimetable);

router.post('/fees/structures', subscriptionGuard, validate(createFeeStructureSchema), ctrl.createFeeStructure);
router.post('/fees/payments', subscriptionGuard, validate(recordPaymentSchema), ctrl.recordPayment);

router.put('/branding', subscriptionGuard, validate(updateBrandingSchema), ctrl.updateBranding);

export default router;
