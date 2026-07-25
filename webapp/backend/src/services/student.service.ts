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

export interface StudentDashboard {
  nextLiveClass: LiveClassItem | null;
  pendingFees: number;
  recentVideos: VideoItem[];
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
    await query<VideoItem>(
      `SELECT c.id, c.title, c.file_url AS "fileUrl", c.content_type AS "contentType", ch.name AS chapter, sub.name AS subject
       FROM content c 
       LEFT JOIN chapters ch ON ch.id = c.chapter_id
       LEFT JOIN subjects sub ON sub.id = ch.subject_id
       WHERE c.tenant_id=$1 AND (c.batch_id = ANY($2::int[]) OR c.batch_id IS NULL)
      ORDER BY c.created_at DESC LIMIT 5`,
      [tenantId, safeBatches]
    )
  ).rows;

  return { nextLiveClass: nextLive, pendingFees: fees.pending, recentVideos };
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
