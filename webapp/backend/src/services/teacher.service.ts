import { query, withTransaction } from '../config/db.js';
import ApiError from '../utils/ApiError.js';
import { buildWaUrl, absentMessage } from './whatsapp.service.js';

/** Today's classes for this teacher (by current day_of_week). */
export interface ScheduleClass {
  timetableId: number;
  batch: string;
  subject: string | null;
  startTime: string;
  endTime: string;
  batchId: number;
}

export async function todaySchedule(
  tenantId: number,
  teacherId: number
): Promise<{ day: number; count: number; classes: ScheduleClass[] }> {
  const dow = new Date().getDay();
  const { rows } = await query<ScheduleClass>(
    `SELECT tt.id AS "timetableId", b.name AS batch, sub.name AS subject,
            tt.start_time AS "startTime", tt.end_time AS "endTime",
            tt.batch_id AS "batchId"
       FROM timetable tt
       JOIN batches b ON b.id = tt.batch_id
       LEFT JOIN subjects sub ON sub.id = tt.subject_id
      WHERE tt.tenant_id=$1 AND tt.teacher_id=$2 AND tt.day_of_week=$3
      ORDER BY tt.start_time`,
    [tenantId, teacherId, dow]
  );
  return { day: dow, count: rows.length, classes: rows };
}

/** Students of a batch (for attendance). Verifies batch belongs to tenant. */
export interface BatchStudent {
  studentId: number;
  name: string;
  rollNo: string | null;
}

export async function batchStudents(tenantId: number, batchId: number): Promise<BatchStudent[]> {
  const b = await query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
  if (!b.rowCount) throw ApiError.notFound('BATCH_NOT_FOUND');
  const { rows } = await query<BatchStudent>(
    `SELECT s.id AS "studentId", u.full_name AS name, s.roll_no AS "rollNo"
       FROM batch_enrollments be
       JOIN students s ON s.id = be.student_id
       JOIN users u ON u.id = s.user_id
      WHERE be.tenant_id=$1 AND be.batch_id=$2
      ORDER BY u.full_name`,
    [tenantId, batchId]
  );
  return rows;
}

export type AttendanceStatus = 'present' | 'absent' | 'late';

export interface AttendanceRecord {
  studentId: number;
  status: AttendanceStatus;
}

export interface MarkAttendanceInput {
  batchId: number;
  timetableId?: number;
  date: string;
  records: AttendanceRecord[];
}

export interface AbsentReminder {
  studentId: number;
  name: string;
  waUrl: string;
}

/**
 * Bulk attendance upsert. Returns free wa.me links for every absent student's
 * parent (no paid WhatsApp API).
 */
export async function markAttendance(
  tenantId: number,
  teacherId: number,
  { batchId, timetableId, date, records }: MarkAttendanceInput
): Promise<{ saved: number; absentReminders: AbsentReminder[] }> {
  const b = await query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
  if (!b.rowCount) throw ApiError.badRequest('INVALID_BATCH');

  const instituteRow = await query<{ name: string }>(`SELECT name FROM tenants WHERE id=$1`, [tenantId]);
  const instituteName = instituteRow.rows[0]?.name || '';

  const absentReminders: AbsentReminder[] = [];

  await withTransaction(async (client) => {
    for (const r of records) {
      await client.query(
        `INSERT INTO attendance (tenant_id, timetable_id, batch_id, student_id, date, status, marked_by)
         VALUES ($1,$2,$3,$4,$5,$6,$7)
         ON CONFLICT (student_id, date, batch_id)
         DO UPDATE SET status = EXCLUDED.status, marked_by = EXCLUDED.marked_by, timetable_id = EXCLUDED.timetable_id`,
        [tenantId, timetableId || null, batchId, r.studentId, date, r.status, teacherId]
      );

      if (r.status === 'absent') {
        const s = await client.query<{ name: string; phone: string }>(
          `SELECT u.full_name AS name, st.parent_phone AS phone
             FROM students st JOIN users u ON u.id=st.user_id
            WHERE st.id=$1 AND st.tenant_id=$2`,
          [r.studentId, tenantId]
        );
        if (s.rows[0]) {
          const msg = absentMessage({ studentName: s.rows[0].name, instituteName, date });
          absentReminders.push({
            studentId: r.studentId,
            name: s.rows[0].name,
            waUrl: buildWaUrl(s.rows[0].phone, msg),
          });
        }
      }
    }
  });

  return { saved: records.length, absentReminders };
}

/* Content (VOD) */
export interface ContentItem {
  id: number;
  title: string;
  youtubeUrl: string;
  batch: string | null;
  batchId: number | null;
}

export async function listContent(tenantId: number, teacherId: number): Promise<ContentItem[]> {
  const { rows } = await query<ContentItem>(
    `SELECT c.id, c.title, c.youtube_url AS "youtubeUrl", b.name AS batch, c.batch_id AS "batchId"
       FROM content c LEFT JOIN batches b ON b.id=c.batch_id
      WHERE c.tenant_id=$1 AND c.created_by=$2
      ORDER BY c.created_at DESC`,
    [tenantId, teacherId]
  );
  return rows;
}

export interface CreateContentInput {
  title: string;
  youtubeUrl: string;
  batchId?: number;
  subjectId?: number;
}

export async function createContent(
  tenantId: number,
  teacherId: number,
  { title, youtubeUrl, batchId, subjectId }: CreateContentInput
) {
  if (batchId) {
    const b = await query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
    if (!b.rowCount) throw ApiError.badRequest('INVALID_BATCH');
  }
  const { rows } = await query(
    `INSERT INTO content (tenant_id, batch_id, subject_id, title, youtube_url, created_by)
     VALUES ($1,$2,$3,$4,$5,$6)
     RETURNING id, title, youtube_url AS "youtubeUrl", batch_id AS "batchId"`,
    [tenantId, batchId || null, subjectId || null, title, youtubeUrl, teacherId]
  );
  return rows[0];
}

/* Live classes */
export interface CreateLiveClassInput {
  title: string;
  meetUrl: string;
  batchId: number;
  scheduledAt: string;
}

export async function createLiveClass(
  tenantId: number,
  teacherId: number,
  { title, meetUrl, batchId, scheduledAt }: CreateLiveClassInput
) {
  const b = await query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
  if (!b.rowCount) throw ApiError.badRequest('INVALID_BATCH');
  const { rows } = await query(
    `INSERT INTO live_classes (tenant_id, batch_id, title, meet_url, scheduled_at, teacher_id)
     VALUES ($1,$2,$3,$4,$5,$6)
     RETURNING id, title, meet_url AS "meetUrl", scheduled_at AS "scheduledAt", batch_id AS "batchId"`,
    [tenantId, batchId, title, meetUrl, scheduledAt, teacherId]
  );
  return rows[0];
}

/** Free wa.me link to reply to a student's doubt. */
export async function doubtLink(
  tenantId: number,
  _teacherId: number,
  studentId: number,
  text?: string
): Promise<{ waUrl: string }> {
  const { rows } = await query<{ name: string; phone: string; institute: string }>(
    `SELECT u.full_name AS name, u.phone, t.name AS institute
       FROM students s JOIN users u ON u.id=s.user_id JOIN tenants t ON t.id=s.tenant_id
      WHERE s.id=$1 AND s.tenant_id=$2`,
    [studentId, tenantId]
  );
  if (!rows[0]) throw ApiError.notFound('STUDENT_NOT_FOUND');
  const msg = text || `Hello ${rows[0].name}, regarding your doubt - ${rows[0].institute}`;
  return { waUrl: buildWaUrl(rows[0].phone, msg) };
}
