import bcrypt from 'bcryptjs';
import { query, withTransaction } from '../config/db.js';
import ApiError from '../utils/ApiError.js';
import { generateReceiptNo } from '../utils/receipt.js';
import { writeAudit } from '../utils/audit.js';
import { buildWaUrl, feeReminderMessage } from './whatsapp.service.js';
import { getTenantDashboard } from './superadmin.service.js';
/* ─────────────── Dashboard ─────────────── */
export async function dashboard(tenantId: number) {
  const dash = await getTenantDashboard(tenantId);
  const subRes = await query(`
    SELECT plan as "planName", status, trial_ends_at as "trialEndsAt", next_billing_date as "nextBillingDate"
    FROM subscriptions
    WHERE tenant_id = $1
  `, [tenantId]);

  return {
    ...dash,
    subscription: subRes.rows[0] || null
  };
}

/* ─────────────── Teachers ─────────────── */
export interface TeacherItem {
  id: number;
  fullName: string;
  phone: string;
  email: string | null;
}

export async function listTeachers(tenantId: number): Promise<TeacherItem[]> {
  const { rows } = await query<TeacherItem>(
    `SELECT id, full_name AS "fullName", phone, email
       FROM users WHERE tenant_id = $1 AND role='teacher' ORDER BY full_name`,
    [tenantId]
  );
  return rows;
}

export interface CreateTeacherInput {
  fullName: string;
  phone: string;
  password: string;
  email?: string;
}

export async function createTeacher(
  tenantId: number,
  actorUserId: number,
  { fullName, phone, password, email }: CreateTeacherInput
): Promise<TeacherItem> {
  const hash = await bcrypt.hash(password, 10);
  const { rows } = await query<TeacherItem>(
    `INSERT INTO users (tenant_id, role, full_name, phone, email, password_hash)
     VALUES ($1,'teacher',$2,$3,$4,$5)
     RETURNING id, full_name AS "fullName", phone, email`,
    [tenantId, fullName, phone, email || null, hash]
  );
  await writeAudit({
    tenantId,
    actorUserId,
    action: 'teacher_created',
    entity: 'user',
    entityId: rows[0].id,
    meta: { fullName, phone },
  });
  return rows[0];
}

export async function deleteTeacher(tenantId: number, actorUserId: number, id: number): Promise<void> {
  const { rowCount } = await query(
    `DELETE FROM users WHERE id=$1 AND tenant_id=$2 AND role='teacher'`,
    [id, tenantId]
  );
  if (!rowCount) throw ApiError.notFound('TEACHER_NOT_FOUND');
  await writeAudit({ tenantId, actorUserId, action: 'teacher_deleted', entity: 'user', entityId: id });
}

/* ─────────────── Students ─────────────── */
export interface StudentItem {
  id: number;
  fullName: string;
  rollNo: string | null;
  grade: string | null;
  parentName: string | null;
  parentPhone: string | null;
  phone: string;
}

export async function listStudents(tenantId: number, batchId: number | null): Promise<StudentItem[]> {
  const params: unknown[] = [tenantId];
  let join = '';
  if (batchId) {
    params.push(batchId);
    join = `JOIN batch_enrollments be ON be.student_id = s.id AND be.batch_id = $2`;
  }
  const { rows } = await query<StudentItem>(
    `SELECT s.id, u.full_name AS "fullName", s.roll_no AS "rollNo", s.grade,
            s.parent_name AS "parentName", s.parent_phone AS "parentPhone", u.phone
       FROM students s
       JOIN users u ON u.id = s.user_id
       ${join}
      WHERE s.tenant_id = $1
      ORDER BY u.full_name`,
    params
  );
  return rows;
}

export interface CreateStudentInput {
  fullName: string;
  phone: string;
  password: string;
  parentName?: string;
  parentPhone: string;
  grade?: string;
  rollNo?: string;
  batchId: number;
}

export async function createStudent(tenantId: number, actorUserId: number, input: CreateStudentInput) {
  const { fullName, phone, password, parentName, parentPhone, grade, rollNo, batchId } = input;
  const hash = await bcrypt.hash(password, 10);

  return withTransaction(async (client) => {
    // Verify batch belongs to tenant before creating anything.
    const b = await client.query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
    if (!b.rowCount) throw ApiError.badRequest('INVALID_BATCH', 'Batch not found for this tenant');

    const user = (
      await client.query<{ id: number }>(
        `INSERT INTO users (tenant_id, role, full_name, phone, password_hash)
       VALUES ($1,'student',$2,$3,$4) RETURNING id`,
        [tenantId, fullName, phone, hash]
      )
    ).rows[0];

    const student = (
      await client.query<{ id: number; rollNo: string | null; parentPhone: string; grade: string | null }>(
        `INSERT INTO students (tenant_id, user_id, roll_no, parent_name, parent_phone, grade)
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING id, roll_no AS "rollNo", parent_phone AS "parentPhone", grade`,
        [tenantId, user.id, rollNo || null, parentName || null, parentPhone, grade || null]
      )
    ).rows[0];

    await client.query(
      `INSERT INTO batch_enrollments (tenant_id, batch_id, student_id) VALUES ($1,$2,$3)`,
      [tenantId, batchId, student.id]
    );

    await writeAudit(
      {
        tenantId,
        actorUserId,
        action: 'student_created',
        entity: 'student',
        entityId: student.id,
        meta: { fullName, phone, batchId },
      },
      client
    );

    return { ...student, id: student.id, fullName, userId: user.id };
  });
}

export async function deleteStudent(tenantId: number, actorUserId: number, id: number): Promise<void> {
  // Deleting the user cascades to students + enrollments.
  const { rows } = await query<{ user_id: number }>(
    `SELECT user_id FROM students WHERE id=$1 AND tenant_id=$2`,
    [id, tenantId]
  );
  if (!rows[0]) throw ApiError.notFound('STUDENT_NOT_FOUND');
  await query(`DELETE FROM users WHERE id=$1 AND tenant_id=$2`, [rows[0].user_id, tenantId]);
  await writeAudit({ tenantId, actorUserId, action: 'student_deleted', entity: 'student', entityId: id });
}

/* ─────────────── Batches ─────────────── */
export interface BatchItem {
  id: number;
  name: string;
  grade: string | null;
  studentCount: number;
}

export async function listBatches(tenantId: number): Promise<BatchItem[]> {
  const { rows } = await query<BatchItem>(
    `SELECT b.id, b.name, b.grade,
            (SELECT count(*)::int FROM batch_enrollments be WHERE be.batch_id=b.id) AS "studentCount"
       FROM batches b WHERE b.tenant_id=$1 ORDER BY b.created_at DESC`,
    [tenantId]
  );
  return rows;
}

export async function createBatch(
  tenantId: number,
  { name, grade }: { name: string; grade?: string }
): Promise<{ id: number; name: string; grade: string | null }> {
  const { rows } = await query<{ id: number; name: string; grade: string | null }>(
    `INSERT INTO batches (tenant_id, name, grade) VALUES ($1,$2,$3)
     RETURNING id, name, grade`,
    [tenantId, name, grade || null]
  );
  return rows[0];
}

/* ─────────────── Subjects ─────────────── */
export async function listSubjects(tenantId: number): Promise<{ id: number; name: string }[]> {
  const { rows } = await query<{ id: number; name: string }>(
    `SELECT id, name FROM subjects WHERE tenant_id=$1 ORDER BY name`,
    [tenantId]
  );
  return rows;
}

export async function createSubject(
  tenantId: number,
  { name }: { name: string }
): Promise<{ id: number; name: string }> {
  const { rows } = await query<{ id: number; name: string }>(
    `INSERT INTO subjects (tenant_id, name) VALUES ($1,$2) RETURNING id, name`,
    [tenantId, name]
  );
  return rows[0];
}

/* ─────────────── Timetable (teacher allocation) ─────────────── */
export interface TimetableItem {
  id: number;
  dayOfWeek: number;
  startTime: string;
  endTime: string;
  batch: string;
  subject: string | null;
  teacher: string;
  batchId: number;
  teacherId: number;
  subjectId: number | null;
}

export async function listTimetable(
  tenantId: number,
  day?: string | number | null
): Promise<TimetableItem[]> {
  const params: unknown[] = [tenantId];
  let where = '';
  if (day !== undefined && day !== null && day !== '') {
    params.push(Number(day));
    where = `AND tt.day_of_week = $2`;
  }
  const { rows } = await query<TimetableItem>(
    `SELECT tt.id, tt.day_of_week AS "dayOfWeek", tt.start_time AS "startTime",
            tt.end_time AS "endTime",
            b.name AS batch, sub.name AS subject, u.full_name AS teacher,
            tt.batch_id AS "batchId", tt.teacher_id AS "teacherId", tt.subject_id AS "subjectId"
       FROM timetable tt
       JOIN batches b ON b.id = tt.batch_id
       LEFT JOIN subjects sub ON sub.id = tt.subject_id
       JOIN users u ON u.id = tt.teacher_id
      WHERE tt.tenant_id = $1 ${where}
      ORDER BY tt.day_of_week, tt.start_time`,
    params
  );
  return rows;
}

export interface CreateTimetableInput {
  batchId: number;
  subjectId?: number;
  teacherId: number;
  dayOfWeek: number;
  startTime: string;
  endTime: string;
}

export async function createTimetableEntry(tenantId: number, input: CreateTimetableInput) {
  const { batchId, subjectId, teacherId, dayOfWeek, startTime, endTime } = input;
  // Ownership checks
  const checks = await query<{ batch_ok: number | null; teacher_ok: number | null; subject_ok: number | null }>(
    `SELECT
       (SELECT 1 FROM batches WHERE id=$2 AND tenant_id=$1) AS batch_ok,
       (SELECT 1 FROM users WHERE id=$3 AND tenant_id=$1 AND role='teacher') AS teacher_ok,
       (SELECT 1 FROM subjects WHERE id=$4 AND tenant_id=$1) AS subject_ok`,
    [tenantId, batchId, teacherId, subjectId ?? null]
  );
  if (!checks.rows[0].batch_ok) throw ApiError.badRequest('INVALID_BATCH');
  if (!checks.rows[0].teacher_ok) throw ApiError.badRequest('INVALID_TEACHER');
  if (subjectId != null && !checks.rows[0].subject_ok) throw ApiError.badRequest('INVALID_SUBJECT');

  const { rows } = await query(
    `INSERT INTO timetable (tenant_id, batch_id, subject_id, teacher_id, day_of_week, start_time, end_time)
     VALUES ($1,$2,$3,$4,$5,$6,$7)
     RETURNING id, batch_id AS "batchId", teacher_id AS "teacherId", day_of_week AS "dayOfWeek",
               start_time AS "startTime", end_time AS "endTime"`,
    [tenantId, batchId, subjectId || null, teacherId, dayOfWeek, startTime, endTime]
  );
  return rows[0];
}

/* ─────────────── Fees ─────────────── */
export interface FeeRow {
  studentId: number;
  name: string;
  total: number;
  paid: number;
  pending: number;
  parentName: string | null;
  parentPhone: string | null;
}

export type FeeStatusFilter = 'pending' | 'paid';

export async function listFees(tenantId: number, status?: FeeStatusFilter | null): Promise<FeeRow[]> {
  // Per-student totals: sum of applicable fee structures minus payments.
  // `pending` is a computed column, so the status filter has to be applied in
  // an outer query rather than the WHERE clause of the aggregation itself.
  const { rows } = await query<FeeRow>(
    `SELECT * FROM (
       SELECT s.id AS "studentId", u.full_name AS name,
              COALESCE(fs.total,0)::int AS total,
              COALESCE(fp.paid,0)::int AS paid,
              (COALESCE(fs.total,0) - COALESCE(fp.paid,0))::int AS pending,
              s.parent_name AS "parentName", s.parent_phone AS "parentPhone"
         FROM students s
         JOIN users u ON u.id = s.user_id
         LEFT JOIN (
           SELECT be.student_id, sum(f.amount) AS total
             FROM batch_enrollments be
             JOIN fee_structures f ON f.batch_id = be.batch_id AND f.tenant_id = $1
            GROUP BY be.student_id
         ) fs ON fs.student_id = s.id
         LEFT JOIN (
           SELECT student_id, sum(amount_paid) AS paid
             FROM fee_payments WHERE tenant_id = $1 GROUP BY student_id
         ) fp ON fp.student_id = s.id
        WHERE s.tenant_id = $1
     ) fees
     WHERE $2::text IS NULL
        OR ($2 = 'pending' AND pending > 0)
        OR ($2 = 'paid' AND pending <= 0)
     ORDER BY pending DESC, name`,
    [tenantId, status ?? null]
  );
  return rows;
}

export interface CreateFeeStructureInput {
  batchId?: number;
  title: string;
  amount: number;
  dueDate?: string;
}

export async function createFeeStructure(
  tenantId: number,
  actorUserId: number,
  { batchId, title, amount, dueDate }: CreateFeeStructureInput
) {
  if (batchId) {
    const b = await query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
    if (!b.rowCount) throw ApiError.badRequest('INVALID_BATCH');
  }
  const { rows } = await query(
    `INSERT INTO fee_structures (tenant_id, batch_id, title, amount, due_date)
     VALUES ($1,$2,$3,$4,$5) RETURNING id, title, amount, due_date AS "dueDate", batch_id AS "batchId"`,
    [tenantId, batchId || null, title, amount, dueDate || null]
  );
  await writeAudit({
    tenantId,
    actorUserId,
    action: 'fee_structure_created',
    entity: 'fee_structure',
    entityId: rows[0].id,
    meta: { title, amount, batchId },
  });
  return rows[0];
}

export interface RecordPaymentInput {
  studentId: number;
  feeStructureId?: number;
  amountPaid: number;
  method?: 'cash' | 'upi' | 'card';
}

/** Postgres unique-violation error code. */
const PG_UNIQUE_VIOLATION = '23505';

export async function recordPayment(
  tenantId: number,
  actorUserId: number,
  { studentId, feeStructureId, amountPaid, method }: RecordPaymentInput
) {
  const s = await query(`SELECT 1 FROM students WHERE id=$1 AND tenant_id=$2`, [studentId, tenantId]);
  if (!s.rowCount) throw ApiError.badRequest('INVALID_STUDENT');

  // receipt_no is UNIQUE; the generator includes a short random suffix, so on
  // the rare collision we just regenerate and retry rather than losing the payment.
  const MAX_ATTEMPTS = 5;
  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    const receiptNo = generateReceiptNo(tenantId);
    try {
      const { rows } = await query(
        `INSERT INTO fee_payments (tenant_id, student_id, fee_structure_id, amount_paid, method, receipt_no)
         VALUES ($1,$2,$3,$4,$5,$6)
         RETURNING id, amount_paid AS "amountPaid", method, receipt_no AS "receiptNo", paid_on AS "paidOn"`,
        [tenantId, studentId, feeStructureId || null, amountPaid, method || 'cash', receiptNo]
      );
      await writeAudit({
        tenantId,
        actorUserId,
        action: 'fee_payment_recorded',
        entity: 'fee_payment',
        entityId: rows[0].id,
        meta: { studentId, amountPaid, method: method || 'cash', receiptNo },
      });
      return { payment: rows[0], receiptNo };
    } catch (err) {
      const code = (err as { code?: string }).code;
      const isLastAttempt = attempt === MAX_ATTEMPTS;
      if (code !== PG_UNIQUE_VIOLATION || isLastAttempt) throw err;
      // else: receipt_no collision — loop and try a freshly generated one.
    }
  }
  // Unreachable, but keeps TypeScript's control-flow analysis happy.
  throw ApiError.conflict('RECEIPT_GENERATION_FAILED', 'Could not generate a unique receipt number');
}

/** Build a free wa.me reminder link (no paid API) for a student's pending fees. */
export async function feeReminderLink(
  tenantId: number,
  studentId: number
): Promise<{ waUrl: string; pending: number }> {
  const { rows } = await query<{
    studentName: string;
    parentName: string | null;
    parentPhone: string;
    instituteName: string;
    pending: number;
  }>(
    `SELECT u.full_name AS "studentName", s.parent_name AS "parentName", s.parent_phone AS "parentPhone",
            t.name AS "instituteName",
            (COALESCE(fs.total,0) - COALESCE(fp.paid,0))::int AS pending
       FROM students s
       JOIN users u ON u.id = s.user_id
       JOIN tenants t ON t.id = s.tenant_id
       LEFT JOIN (
         SELECT be.student_id, sum(f.amount) AS total
           FROM batch_enrollments be
           JOIN fee_structures f ON f.batch_id = be.batch_id AND f.tenant_id=$1
          GROUP BY be.student_id
       ) fs ON fs.student_id = s.id
       LEFT JOIN (
         SELECT student_id, sum(amount_paid) AS paid FROM fee_payments WHERE tenant_id=$1 GROUP BY student_id
       ) fp ON fp.student_id = s.id
      WHERE s.id=$2 AND s.tenant_id=$1`,
    [tenantId, studentId]
  );
  if (!rows[0]) throw ApiError.notFound('STUDENT_NOT_FOUND');
  const r = rows[0];
  const msg = feeReminderMessage({
    parentName: r.parentName,
    studentName: r.studentName,
    feeTitle: 'total',
    pending: r.pending,
    instituteName: r.instituteName,
  });
  return { waUrl: buildWaUrl(r.parentPhone, msg), pending: r.pending };
}

/* ─────────────── Reports ─────────────── */
export interface PerformanceReport {
  avgAttendance: string | null;
  avgMarksPct: string | null;
}

export async function performanceReport(
  tenantId: number,
  batchId: number | null
): Promise<PerformanceReport> {
  const params: unknown[] = [tenantId];
  let attWhere = '';
  let resWhere = '';
  if (batchId) {
    params.push(batchId);
    attWhere = `AND a.batch_id = $2`;
    resWhere = `AND t.batch_id = $2`;
  }
  const { rows } = await query<PerformanceReport>(
    `SELECT
       (SELECT ROUND(100.0 * count(*) FILTER (WHERE a.status='present') / NULLIF(count(*),0), 1)
          FROM attendance a WHERE a.tenant_id=$1 ${attWhere}) AS "avgAttendance",
       (SELECT ROUND(AVG(100.0 * tr.marks_obtained / NULLIF(t.max_marks,0)), 1)
          FROM test_results tr JOIN tests t ON t.id=tr.test_id
         WHERE tr.tenant_id=$1 ${resWhere}) AS "avgMarksPct"`,
    params
  );
  return rows[0];
}

/* ─────────────── Branding ─────────────── */
export interface BrandingInfo {
  name: string;
  logoUrl: string | null;
  primaryColor: string | null;
}

export async function getBranding(tenantId: number): Promise<BrandingInfo> {
  const { rows } = await query<BrandingInfo>(
    `SELECT name, logo_url AS "logoUrl", primary_color AS "primaryColor"
       FROM tenants WHERE id=$1`,
    [tenantId]
  );
  return rows[0];
}

export async function updateBranding(
  tenantId: number,
  actorUserId: number,
  { logoUrl, primaryColor }: { logoUrl?: string; primaryColor?: string }
): Promise<BrandingInfo> {
  const { rows } = await query<BrandingInfo>(
    `UPDATE tenants SET
       logo_url = COALESCE($2, logo_url),
       primary_color = COALESCE($3, primary_color)
     WHERE id=$1
     RETURNING name, logo_url AS "logoUrl", primary_color AS "primaryColor"`,
    [tenantId, logoUrl ?? null, primaryColor ?? null]
  );
  await writeAudit({
    tenantId,
    actorUserId,
    action: 'branding_updated',
    entity: 'tenant',
    entityId: tenantId,
    meta: { logoUrl, primaryColor },
  });
  return rows[0];
}
