import { Router } from 'express';
import * as ctrl from '../controllers/teacher.controller.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { roleGuard } from '../middleware/roleGuard.js';
import { featureGuard } from '../middleware/featureGuard.js';
import { validate } from '../middleware/validate.js';
import {
  markAttendanceSchema,
  createContentSchema,
  createChapterSchema,
  createLiveClassSchema,
  batchIdParamSchema,
  batchStudentsQuerySchema,
  studentIdParamSchema,
  doubtLinkQuerySchema,
  createTestSchema,
  createQuestionSchema,
  testIdParamSchema,
  questionIdParamSchema,
} from '../validators/teacher.validators.js';

const router = Router();
router.use(authMiddleware, roleGuard('teacher'));

router.get('/schedule/today', ctrl.todaySchedule);
router.get('/batches', ctrl.myBatches);
router.get(
  '/batches/:batchId/students',
  validate(batchIdParamSchema, 'params'),
  validate(batchStudentsQuerySchema, 'query'),
  ctrl.batchStudents
);

// Cloudinary Upload Signature
import { generateSignature } from '../services/cloudinary.service.js';
router.get('/upload-signature', (req, res) => {
  res.json(generateSignature('edtech_os'));
});

// Attendance — all plans (present/absent/late saved for everyone)
// WhatsApp absent-reminder links are filtered inside the service based on plan
router.post('/attendance', validate(markAttendanceSchema), ctrl.markAttendance);

// Subjects & Chapters
router.get('/subjects', ctrl.listSubjects);
router.get('/chapters', ctrl.listChapters);
router.post('/chapters', validate(createChapterSchema), ctrl.createChapter);

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

// --- Tests & Quizzes ---
router.get('/tests', ctrl.listTests);
router.post('/tests', validate(createTestSchema), ctrl.createTest);

router.get('/tests/:testId/questions', validate(testIdParamSchema, 'params'), ctrl.getTestQuestions);
router.post('/tests/:testId/questions', validate(testIdParamSchema, 'params'), validate(createQuestionSchema), ctrl.addQuestion);

router.put('/questions/:questionId', validate(questionIdParamSchema, 'params'), validate(createQuestionSchema), ctrl.updateQuestion);
router.delete('/questions/:questionId', validate(questionIdParamSchema, 'params'), ctrl.deleteQuestion);

export default router;

