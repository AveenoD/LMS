import { query } from '../config/db.js';
import ApiError from '../utils/ApiError.js';
import { buildWaUrl, doubtMessage } from './whatsapp.service.js';

/** Resolve the students.id for a logged-in student user. */
async function getStudentId(tenantId: number, userId: number): Promise<number> {
  const { rows } = await query<{ id: number }>(
    `SELECT id FROM students WHERE tenant_id=$1 AND user_id=$2`,
    [tenantId, userId]
  );
  if (!rows[0]) throw ApiError.notFound('STUDENT_PROFILE_NOT_FOUND');
  return rows[0].id;
}

/** Batch ids the student is enrolled in. */
async function enrolledBatchIds(tenantId: number, studentId: number): Promise<number[]> {
  const { rows } = await query<{ batch_id: number }>(
    `SELECT batch_id FROM batch_enrollments WHERE tenant_id=$1 AND student_id=$2`,
    [tenantId, studentId]
  );
  return rows.map((r) => r.batch_id);
}

export interface VideoItem {
  id: number;
  title: string;
  fileUrl: string;
  contentType: string;
  subject?: string | null;
  chapter?: string | null;
}

export interface LiveClassItem {
  id: number;
  title: string;
  meetUrl: string;
  scheduledAt: Date;
  joinable?: boolean;
}

export interface TimetableItem {
  id: number;
  subject: string;
  teacherName: string;
  startTime: string;
  endTime: string;
}

export interface UpcomingTest {
  id: number;
  title: string;
  subject: string | null;
  testDate: string | null;
  maxMarks: number;
}

export interface ContinuePlaying {
  id: number;
  title: string;
  fileUrl: string;
  contentType: string;
  chapter: string | null;
  subject: string | null;
  chapterId: number | null;
  progressSeconds: number;
  durationMinutes: number;
  durationSeconds: number;
}

export interface StudentDashboard {
  nextLiveClass: LiveClassItem | null;
  pendingFees: number;
  recentVideos: VideoItem[];
  continuePlaying: ContinuePlaying | null;
  attendancePct: number;       // 0-100
  todaySchedule: TimetableItem[];
  nextTest: UpcomingTest | null;
}

export async function dashboard(tenantId: number, userId: number): Promise<StudentDashboard> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];

  const nextLive =
    (
      await query<LiveClassItem>(
        `SELECT id, title, meet_url AS "meetUrl", scheduled_at AS "scheduledAt"
       FROM live_classes
      WHERE tenant_id=$1 AND batch_id = ANY($2::int[]) AND scheduled_at >= now() - interval '1 hour'
      ORDER BY scheduled_at ASC LIMIT 1`,
        [tenantId, safeBatches]
      )
    ).rows[0] || null;

  const fees = (
    await query<{ pending: number }>(
      `SELECT
       COALESCE((SELECT sum(f.amount) FROM fee_structures f
                  WHERE f.tenant_id=$1 AND f.batch_id = ANY($2::int[])),0)::int
       - COALESCE((SELECT sum(amount_paid) FROM fee_payments WHERE tenant_id=$1 AND student_id=$3),0)::int
         AS pending`,
      [tenantId, safeBatches, studentId]
    )
  ).rows[0];

  const recentVideos = (
    await query<VideoItem & { chapterId: number }>(
      `SELECT c.id, c.title, c.file_url AS "fileUrl", c.content_type AS "contentType", ch.name AS chapter, ch.id AS "chapterId", sub.name AS subject
       FROM content c 
       LEFT JOIN chapters ch ON ch.id = c.chapter_id
       LEFT JOIN subjects sub ON sub.id = ch.subject_id
       WHERE c.tenant_id=$1 AND (c.batch_id = ANY($2::int[]) OR c.batch_id IS NULL)
      ORDER BY c.created_at DESC LIMIT 5`,
      [tenantId, safeBatches]
    )
  ).rows;

  // Attendance %
  const attRow = (
    await query<{ total: number; present: number }>(
      `SELECT
         COUNT(*)::int AS total,
         COUNT(*) FILTER (WHERE status='present' OR status='late')::int AS present
       FROM attendance
       WHERE tenant_id=$1 AND student_id=$2`,
      [tenantId, studentId]
    )
  ).rows[0];
  const attendancePct = attRow.total > 0 ? Math.round((attRow.present / attRow.total) * 100) : 0;

  // Today's timetable
  const dow = new Date().getDay(); // 0=Sun..6=Sat
  const todaySchedule = (
    await query<TimetableItem>(
      `SELECT t.id, s.name AS subject, u.full_name AS "teacherName",
              to_char(t.start_time,'HH12:MI AM') AS "startTime",
              to_char(t.end_time,'HH12:MI AM') AS "endTime"
       FROM timetable t
       JOIN subjects s ON s.id = t.subject_id
       JOIN users u ON u.id = t.teacher_id
       WHERE t.tenant_id=$1 AND t.batch_id = ANY($2::int[]) AND t.day_of_week=$3
       ORDER BY t.start_time`,
      [tenantId, safeBatches, dow]
    )
  ).rows;

  // Next upcoming test
  const nextTest = (
    await query<UpcomingTest>(
      `SELECT t.id, t.title, s.name AS subject, t.scheduled_at AS "testDate", t.max_marks AS "maxMarks"
       FROM tests t LEFT JOIN subjects s ON s.id = t.subject_id
       WHERE t.tenant_id=$1 AND t.batch_id = ANY($2::int[]) AND t.scheduled_at >= now()
       ORDER BY t.scheduled_at ASC LIMIT 1`,
      [tenantId, safeBatches]
    )
  ).rows[0] || null;

  const continuePlaying = (
    await query<ContinuePlaying>(
      `SELECT c.id, c.title, c.file_url AS "fileUrl", c.content_type AS "contentType",
              c.duration_minutes AS "durationMinutes", c.duration_seconds AS "durationSeconds",
              ch.name AS chapter, ch.id AS "chapterId", sub.name AS subject,
              p.progress_seconds AS "progressSeconds"
       FROM user_content_progress p
       JOIN content c ON c.id = p.content_id
       LEFT JOIN chapters ch ON ch.id = c.chapter_id
       LEFT JOIN subjects sub ON sub.id = ch.subject_id
       WHERE p.tenant_id=$1 AND p.user_id=$2 AND c.content_type = 'video'
       ORDER BY p.updated_at DESC LIMIT 1`,
      [tenantId, userId]
    )
  ).rows[0] || null;

  return {
    nextLiveClass: nextLive,
    pendingFees: fees.pending,
    recentVideos,
    continuePlaying,
    attendancePct,
    todaySchedule,
    nextTest,
  };
}

export async function updateProgress(tenantId: number, userId: number, contentId: number, progressSeconds: number): Promise<void> {
  await query(
    `INSERT INTO user_content_progress (tenant_id, user_id, content_id, progress_seconds, updated_at)
     VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
     ON CONFLICT (user_id, content_id) DO UPDATE 
     SET progress_seconds = EXCLUDED.progress_seconds,
         updated_at = CURRENT_TIMESTAMP`,
    [tenantId, userId, contentId, progressSeconds]
  );
}

export async function listVideos(
  tenantId: number,
  userId: number,
  subjectId: number | null
): Promise<VideoItem[]> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];
  const params: unknown[] = [tenantId, safeBatches];
  let subFilter = '';
  if (subjectId) {
    params.push(subjectId);
    subFilter = `AND ch.subject_id = $3`;
  }
  const { rows } = await query<VideoItem>(
    `SELECT c.id, c.title, c.file_url AS "fileUrl", c.content_type AS "contentType", ch.name AS chapter, sub.name AS subject
       FROM content c 
       LEFT JOIN chapters ch ON ch.id = c.chapter_id
       LEFT JOIN subjects sub ON sub.id=ch.subject_id
      WHERE c.tenant_id=$1 AND (c.batch_id = ANY($2::int[]) OR c.batch_id IS NULL) ${subFilter}
      ORDER BY c.created_at DESC`,
    params
  );
  return rows;
}

export async function videoDetail(tenantId: number, userId: number, id: number): Promise<VideoItem> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];
  const { rows } = await query<VideoItem>(
    `SELECT c.id, c.title, c.file_url AS "fileUrl", c.content_type AS "contentType"
       FROM content c
      WHERE c.tenant_id=$1 AND c.id=$2 AND (c.batch_id = ANY($3::int[]) OR c.batch_id IS NULL)`,
    [tenantId, id, safeBatches]
  );
  if (!rows[0]) throw ApiError.notFound('VIDEO_NOT_FOUND');
  return rows[0];
}

export async function todayLive(tenantId: number, userId: number): Promise<LiveClassItem[]> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];
  const { rows } = await query<LiveClassItem>(
    `SELECT id, title, meet_url AS "meetUrl", scheduled_at AS "scheduledAt",
            (now() BETWEEN scheduled_at - interval '10 minutes'
                       AND scheduled_at + interval '60 minutes') AS joinable
       FROM live_classes
      WHERE tenant_id=$1 AND batch_id = ANY($2::int[])
        AND scheduled_at::date = now()::date
      ORDER BY scheduled_at`,
    [tenantId, safeBatches]
  );
  return rows;
}

export interface FeePayment {
  id: number;
  receiptNo: string;
  amount: number;
  paidOn: Date;
  method: string;
}

export interface StudentFees {
  total: number;
  paid: number;
  pending: number;
  payments: FeePayment[];
}

export async function fees(tenantId: number, userId: number): Promise<StudentFees> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];

  const totals = (
    await query<{ total: number; paid: number }>(
      `SELECT
       COALESCE((SELECT sum(f.amount) FROM fee_structures f
                  WHERE f.tenant_id=$1 AND f.batch_id = ANY($2::int[])),0)::int AS total,
       COALESCE((SELECT sum(amount_paid) FROM fee_payments WHERE tenant_id=$1 AND student_id=$3),0)::int AS paid`,
      [tenantId, safeBatches, studentId]
    )
  ).rows[0];

  const payments = (
    await query<FeePayment>(
      `SELECT id, receipt_no AS "receiptNo", amount_paid AS "amount", paid_on AS "paidOn", method
       FROM fee_payments WHERE tenant_id=$1 AND student_id=$2 ORDER BY paid_on DESC`,
      [tenantId, studentId]
    )
  ).rows;

  return { total: totals.total, paid: totals.paid, pending: totals.total - totals.paid, payments };
}

export interface Receipt {
  receiptNo: string;
  amount: number;
  paidOn: Date;
  method: string;
  studentName: string;
  instituteName: string;
}

export async function receipt(tenantId: number, userId: number, paymentId: number): Promise<Receipt> {
  const studentId = await getStudentId(tenantId, userId);
  const { rows } = await query<Receipt>(
    `SELECT fp.receipt_no AS "receiptNo", fp.amount_paid AS amount, fp.paid_on AS "paidOn",
            fp.method, u.full_name AS "studentName", t.name AS "instituteName"
       FROM fee_payments fp
       JOIN students s ON s.id=fp.student_id
       JOIN users u ON u.id=s.user_id
       JOIN tenants t ON t.id=fp.tenant_id
      WHERE fp.id=$1 AND fp.tenant_id=$2 AND fp.student_id=$3`,
    [paymentId, tenantId, studentId]
  );
  if (!rows[0]) throw ApiError.notFound('RECEIPT_NOT_FOUND');
  return rows[0];
}

/** Free wa.me link to the chosen teacher for a doubt. */
export async function askDoubt(
  tenantId: number,
  userId: number,
  teacherId: number,
  chapter?: string
): Promise<{ waUrl: string }> {
  const student = (
    await query<{ name: string; institute: string }>(
      `SELECT u.full_name AS name, t.name AS institute
       FROM students s JOIN users u ON u.id=s.user_id JOIN tenants t ON t.id=s.tenant_id
      WHERE s.tenant_id=$1 AND s.user_id=$2`,
      [tenantId, userId]
    )
  ).rows[0];
  if (!student) throw ApiError.notFound('STUDENT_PROFILE_NOT_FOUND');

  const teacher = (
    await query<{ phone: string }>(
      `SELECT phone FROM users WHERE id=$1 AND tenant_id=$2 AND role='teacher'`,
      [teacherId, tenantId]
    )
  ).rows[0];
  if (!teacher) throw ApiError.badRequest('INVALID_TEACHER');

  const msg = doubtMessage({
    studentName: student.name,
    instituteName: student.institute,
    chapter: chapter || 'a topic',
  });
  return { waUrl: buildWaUrl(teacher.phone, msg) };
}

// ─── SUBJECTS ───────────────────────────────────────────────────────────────

export interface SubjectWithStats {
  id: number;
  name: string;
  totalChapters: number;
  totalVideos: number;
}

export async function listSubjects(tenantId: number, userId: number): Promise<SubjectWithStats[]> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];

  // Subjects come from the student's batches' subject_ids — set once at
  // batch-create time — not from timetable entries. A batch with no
  // timetable slots yet (or a subject with no class scheduled this week)
  // still shows up here, which is the whole point.
  const { rows } = await query<SubjectWithStats>(
    `SELECT s.id, s.name,
            COUNT(DISTINCT ch.id)::int AS "totalChapters",
            COUNT(DISTINCT c.id) FILTER (WHERE c.content_type = 'video')::int AS "totalVideos"
       FROM subjects s
       LEFT JOIN chapters ch ON ch.subject_id = s.id AND ch.tenant_id = s.tenant_id
       LEFT JOIN content c ON c.chapter_id = ch.id
      WHERE s.tenant_id=$1
        AND s.id = ANY(
          SELECT DISTINCT unnest(b.subject_ids) FROM batches b
          WHERE b.tenant_id=$1 AND b.id = ANY($2::int[])
        )
      GROUP BY s.id, s.name
      ORDER BY s.name`,
    [tenantId, safeBatches]
  );
  return rows;
}

// ─── CHAPTERS ───────────────────────────────────────────────────────────────

export interface ChapterWithCounts {
  id: number;
  name: string;
  videoCount: number;
  docCount: number;
  sortOrder: number;
}

export async function listChapters(
  tenantId: number,
  userId: number,
  subjectId: number
): Promise<ChapterWithCounts[]> {
  await getStudentId(tenantId, userId); // auth check
  const { rows } = await query<ChapterWithCounts>(
    `SELECT ch.id, ch.name,
            COUNT(c.id) FILTER (WHERE c.content_type = 'video')::int AS "videoCount",
            COUNT(c.id) FILTER (WHERE c.content_type != 'video')::int AS "docCount",
            ROW_NUMBER() OVER (ORDER BY ch.created_at)::int AS "sortOrder"
       FROM chapters ch
       LEFT JOIN content c ON c.chapter_id = ch.id
      WHERE ch.tenant_id=$1 AND ch.subject_id=$2
      GROUP BY ch.id, ch.name, ch.created_at
      ORDER BY ch.created_at`,
    [tenantId, subjectId]
  );
  return rows;
}

// ─── CHAPTER CONTENT ─────────────────────────────────────────────────────────

export interface ContentItem {
  id: number;
  title: string;
  fileUrl: string;
  contentType: string;
  durationMinutes: number;
  durationSeconds: number;
}

export async function listChapterContent(
  tenantId: number,
  userId: number,
  chapterId: number
): Promise<ContentItem[]> {
  await getStudentId(tenantId, userId); // auth check
  const { rows } = await query<ContentItem>(
    `SELECT id, title, file_url AS "fileUrl", content_type AS "contentType",
            duration_minutes AS "durationMinutes", duration_seconds AS "durationSeconds"
       FROM content
      WHERE tenant_id=$1 AND chapter_id=$2
      ORDER BY created_at ASC`,
    [tenantId, chapterId]
  );
  return rows;
}

// ─── TESTS ──────────────────────────────────────────────────────────────────

export interface StudentTest {
  id: number;
  title: string;
  subject: string | null;
  testDate: string | null;
  maxMarks: number;
  durationMinutes: number | null;
  isOnline: boolean;
  // for completed:
  marksObtained?: number;
}

export async function listTests(
  tenantId: number,
  userId: number
): Promise<{ active: StudentTest[]; completed: StudentTest[] }> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];

  const active = (
    await query<StudentTest>(
      `SELECT t.id, t.title, s.name AS subject, t.scheduled_at AS "testDate",
              t.max_marks AS "maxMarks", t.duration_minutes AS "durationMinutes", t.is_online AS "isOnline"
         FROM tests t
         LEFT JOIN subjects s ON s.id = t.subject_id
        WHERE t.tenant_id=$1 AND t.batch_id = ANY($2::int[])
          AND (t.scheduled_at IS NULL OR t.scheduled_at >= now())
          AND NOT EXISTS (
            SELECT 1 FROM test_results tr
            WHERE tr.test_id = t.id AND tr.student_id = $3
          )
        ORDER BY t.scheduled_at ASC NULLS LAST`,
      [tenantId, safeBatches, studentId]
    )
  ).rows;

  const completed = (
    await query<StudentTest>(
      `SELECT t.id, t.title, s.name AS subject, t.scheduled_at AS "testDate",
              t.max_marks AS "maxMarks", t.duration_minutes AS "durationMinutes", t.is_online AS "isOnline",
              tr.marks_obtained AS "marksObtained"
         FROM tests t
         JOIN test_results tr ON tr.test_id = t.id AND tr.student_id = $3
         LEFT JOIN subjects s ON s.id = t.subject_id
        WHERE t.tenant_id=$1 AND t.batch_id = ANY($2::int[])
        ORDER BY t.scheduled_at DESC NULLS FIRST`,
      [tenantId, safeBatches, studentId]
    )
  ).rows;

  return { active, completed };
}

// ─── QUIZ QUESTIONS ──────────────────────────────────────────────────────────

export interface QuizQuestion {
  id: number;
  questionText: string;
  imageUrl: string | null;
  marks: number;
  options: { id: number; optionText: string | null; imageUrl: string | null }[];
}

interface StoredOption {
  id: number;
  optionText: string | null;
  imageUrl: string | null;
  isCorrect: boolean;
}

interface StoredQuestion {
  id: number;
  questionText: string;
  imageUrl: string | null;
  marks: number;
  options: StoredOption[];
}

export async function getTestQuestions(
  tenantId: number,
  userId: number,
  testId: number
): Promise<QuizQuestion[]> {
  const studentId = await getStudentId(tenantId, userId);
  const batchIds = await enrolledBatchIds(tenantId, studentId);
  const safeBatches = batchIds.length ? batchIds : [-1];

  // Verify test belongs to student's batch
  const testCheck = await query<{ questions: StoredQuestion[] }>(
    `SELECT questions FROM tests WHERE id=$1 AND tenant_id=$2 AND batch_id = ANY($3::int[])`,
    [testId, tenantId, safeBatches]
  );
  if (!testCheck.rows[0]) throw ApiError.notFound('TEST_NOT_FOUND');

  const questions = testCheck.rows[0].questions || [];

  // isCorrect is deliberately stripped — the student hasn't submitted yet.
  return questions.map((q) => ({
    id: q.id,
    questionText: q.questionText,
    imageUrl: q.imageUrl,
    marks: q.marks,
    options: q.options.map((o) => ({ id: o.id, optionText: o.optionText, imageUrl: o.imageUrl })),
  }));
}

// ─── SUBMIT QUIZ ─────────────────────────────────────────────────────────────

export interface QuizSubmitPayload {
  answers: Record<string, number>; // questionId -> optionId
}

export interface QuizResult {
  marksObtained: number;
  maxMarks: number;
  correct: number;
  incorrect: number;
  skipped: number;
  total: number;
}

export async function submitTest(
  tenantId: number,
  userId: number,
  testId: number,
  payload: QuizSubmitPayload
): Promise<QuizResult> {
  const studentId = await getStudentId(tenantId, userId);

  // Verify not already submitted
  const existing = await query(
    `SELECT id FROM test_results WHERE test_id=$1 AND student_id=$2`,
    [testId, studentId]
  );
  if (existing.rows[0]) throw ApiError.badRequest('TEST_ALREADY_SUBMITTED');

  const test = (
    await query<{ max_marks: number; questions: StoredQuestion[] }>(
      `SELECT max_marks, questions FROM tests WHERE id=$1 AND tenant_id=$2`,
      [testId, tenantId]
    )
  ).rows[0];
  if (!test) throw ApiError.notFound('TEST_NOT_FOUND');

  const questions = test.questions || [];
  if (questions.length === 0) throw ApiError.notFound('TEST_HAS_NO_QUESTIONS');

  let correct = 0;
  let incorrect = 0;
  let skipped = 0;
  let marksObtained = 0;

  // Per-question answer record, stored alongside the result so a future
  // "review answers" screen has something to read (previously only the
  // aggregate marks_obtained was persisted — individual answers were
  // computed here and then discarded).
  const answers: Record<string, { selectedOptionId: number | null; isCorrect: boolean }> = {};

  for (const q of questions) {
    const submitted = payload.answers[String(q.id)];
    const correctOpt = q.options.find((o) => o.isCorrect);
    if (submitted === undefined || submitted === null) {
      skipped++;
      answers[String(q.id)] = { selectedOptionId: null, isCorrect: false };
    } else if (correctOpt && submitted === correctOpt.id) {
      correct++;
      marksObtained += q.marks;
      answers[String(q.id)] = { selectedOptionId: submitted, isCorrect: true };
    } else {
      incorrect++;
      answers[String(q.id)] = { selectedOptionId: submitted, isCorrect: false };
    }
  }

  await query(
    `INSERT INTO test_results (tenant_id, test_id, student_id, marks_obtained, answers)
     VALUES ($1, $2, $3, $4, $5::jsonb)`,
    [tenantId, testId, studentId, marksObtained, JSON.stringify(answers)]
  );

  return {
    marksObtained,
    maxMarks: test.max_marks,
    correct,
    incorrect,
    skipped,
    total: questions.length,
  };
}

// ─── ATTENDANCE MONTHLY ──────────────────────────────────────────────────────

export interface MonthlyAttendance {
  month: string;  // e.g. "July 2025"
  present: number;
  absent: number;
  total: number;
}

export async function monthlyAttendance(
  tenantId: number,
  userId: number
): Promise<MonthlyAttendance[]> {
  const studentId = await getStudentId(tenantId, userId);
  const { rows } = await query<MonthlyAttendance>(
    `SELECT to_char(date, 'Month YYYY') AS month,
            COUNT(*) FILTER (WHERE status='present' OR status='late')::int AS present,
            COUNT(*) FILTER (WHERE status='absent')::int AS absent,
            COUNT(*)::int AS total
       FROM attendance
      WHERE tenant_id=$1 AND student_id=$2
      GROUP BY to_char(date, 'Month YYYY'), date_trunc('month', date)
      ORDER BY date_trunc('month', date) DESC
      LIMIT 6`,
    [tenantId, studentId]
  );
  return rows;
}

// ─── PERFORMANCE ─────────────────────────────────────────────────────────────

export interface SubjectPerformance {
  subject: string;
  totalMarks: number;
  obtainedMarks: number;
  testCount: number;
}

export async function subjectPerformance(
  tenantId: number,
  userId: number
): Promise<SubjectPerformance[]> {
  const studentId = await getStudentId(tenantId, userId);
  const { rows } = await query<SubjectPerformance>(
    `SELECT s.name AS subject,
            SUM(t.max_marks)::int AS "totalMarks",
            SUM(tr.marks_obtained)::int AS "obtainedMarks",
            COUNT(*)::int AS "testCount"
       FROM test_results tr
       JOIN tests t ON t.id = tr.test_id
       LEFT JOIN subjects s ON s.id = t.subject_id
      WHERE tr.tenant_id=$1 AND tr.student_id=$2
      GROUP BY s.name
      ORDER BY s.name`,
    [tenantId, studentId]
  );
  return rows;
}

// ─── STUDENT PROFILE ─────────────────────────────────────────────────────────

export interface StudentProfile {
  fullName: string;
  phone: string | null;
  rollNo: string | null;
  grade: string | null;
  batchName: string | null;
  parentName: string | null;
  parentPhone: string | null;
  attendancePct: number;
  testsGiven: number;
  avgScore: number | null;
}

export async function getProfile(tenantId: number, userId: number): Promise<StudentProfile> {
  const studentId = await getStudentId(tenantId, userId);

  const profileRow = (
    await query<{
      fullName: string;
      phone: string | null;
      rollNo: string | null;
      grade: string | null;
      batchName: string | null;
      parentName: string | null;
      parentPhone: string | null;
    }>(
      `SELECT u.full_name AS "fullName", u.phone,
              s.roll_no AS "rollNo", s.grade, s.parent_name AS "parentName", s.parent_phone AS "parentPhone",
              b.name AS "batchName"
         FROM students s
         JOIN users u ON u.id = s.user_id
         LEFT JOIN batch_enrollments be ON be.student_id = s.id AND be.tenant_id = s.tenant_id
         LEFT JOIN batches b ON b.id = be.batch_id
        WHERE s.tenant_id=$1 AND s.user_id=$2
        LIMIT 1`,
      [tenantId, userId]
    )
  ).rows[0];

  if (!profileRow) throw ApiError.notFound('STUDENT_PROFILE_NOT_FOUND');

  const attRow = (
    await query<{ total: number; present: number }>(
      `SELECT COUNT(*)::int AS total,
              COUNT(*) FILTER (WHERE status='present' OR status='late')::int AS present
         FROM attendance WHERE tenant_id=$1 AND student_id=$2`,
      [tenantId, studentId]
    )
  ).rows[0];
  const attendancePct =
    attRow && attRow.total > 0 ? Math.round((attRow.present / attRow.total) * 100) : 0;

  const testStats = (
    await query<{ testsGiven: number; avgScore: number | null }>(
      `SELECT COUNT(*)::int AS "testsGiven",
              CASE WHEN SUM(t.max_marks) > 0
                   THEN ROUND(SUM(tr.marks_obtained)::numeric / SUM(t.max_marks) * 100)::int
                   ELSE NULL END AS "avgScore"
         FROM test_results tr
         JOIN tests t ON t.id = tr.test_id
        WHERE tr.tenant_id=$1 AND tr.student_id=$2`,
      [tenantId, studentId]
    )
  ).rows[0];

  return {
    ...profileRow,
    attendancePct,
    testsGiven: testStats?.testsGiven ?? 0,
    avgScore: testStats?.avgScore ?? null,
  };
}
