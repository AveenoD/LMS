import { query, withTransaction } from '../config/db.js';
import ApiError from '../utils/ApiError.js';
import { buildWaUrl, absentMessage } from './whatsapp.service.js';
import * as https from 'https';

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
            tt.batch_id AS "batchId",
            EXISTS(
              SELECT 1 FROM attendance a 
              WHERE a.batch_id = tt.batch_id 
                AND a.timetable_id = tt.id 
                AND a.date = CURRENT_DATE
            ) AS "isAttendanceMarked"
       FROM timetable tt
       JOIN batches b ON b.id = tt.batch_id
       LEFT JOIN subjects sub ON sub.id = tt.subject_id
      WHERE tt.tenant_id=$1 AND tt.teacher_id=$2 AND tt.day_of_week=$3
      ORDER BY tt.start_time`,
    [tenantId, teacherId, dow]
  );
  return { day: dow, count: rows.length, classes: rows };
}

export interface MyBatch {
  id: number;
  name: string;
  studentCount: number;
  progress: number; // Placeholder for now
}

export async function myBatches(tenantId: number, teacherId: number): Promise<MyBatch[]> {
  // Find distinct batches assigned to this teacher in timetable
  const { rows } = await query<MyBatch>(
    `SELECT b.id, b.name, 
            (SELECT COUNT(*) FROM batch_enrollments be WHERE be.batch_id = b.id) AS "studentCount",
            0 AS progress
       FROM batches b
      WHERE b.tenant_id = $1
        AND b.id IN (SELECT DISTINCT batch_id FROM timetable WHERE tenant_id = $1 AND teacher_id = $2)
      ORDER BY b.name`,
    [tenantId, teacherId]
  );
  return rows;
}

/** Students of a batch (for attendance). Verifies batch belongs to tenant. */
export interface BatchStudent {
  studentId: number;
  name: string;
  rollNo: string | null;
}

export async function batchStudents(tenantId: number, batchId: number, date?: string): Promise<any[]> {
  const b = await query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
  if (!b.rowCount) throw ApiError.notFound('BATCH_NOT_FOUND');
  
  if (date) {
    const { rows } = await query(
      `SELECT s.id AS "studentId", u.full_name AS name, s.roll_no AS "rollNo", a.status
         FROM batch_enrollments be
         JOIN students s ON s.id = be.student_id
         JOIN users u ON u.id = s.user_id
         LEFT JOIN attendance a ON a.student_id = s.id AND a.date = $3 AND a.batch_id = $2
        WHERE be.tenant_id=$1 AND be.batch_id=$2
        ORDER BY u.full_name`,
      [tenantId, batchId, date]
    );
    return rows;
  } else {
    const { rows } = await query(
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

/* Chapters */
export interface ChapterItem {
  id: number;
  subjectId: number;
  name: string;
}

export async function listChapters(tenantId: number, subjectId?: number): Promise<ChapterItem[]> {
  const params: any[] = [tenantId];
  let q = `SELECT id, subject_id AS "subjectId", name FROM chapters WHERE tenant_id=$1`;
  if (subjectId) {
    params.push(subjectId);
    q += ` AND subject_id=$2`;
  }
  q += ` ORDER BY created_at DESC`;
  const { rows } = await query<ChapterItem>(q, params);
  return rows;
}

export async function createChapter(tenantId: number, subjectId: number, name: string): Promise<ChapterItem> {
  const sub = await query(`SELECT 1 FROM subjects WHERE id=$1 AND tenant_id=$2`, [subjectId, tenantId]);
  if (!sub.rowCount) throw ApiError.badRequest('INVALID_SUBJECT');
  
  const { rows } = await query<ChapterItem>(
    `INSERT INTO chapters (tenant_id, subject_id, name)
     VALUES ($1,$2,$3)
     RETURNING id, subject_id AS "subjectId", name`,
    [tenantId, subjectId, name]
  );
  return rows[0];
}

export async function listSubjects(tenantId: number): Promise<{ id: number; name: string }[]> {
  const { rows } = await query<{ id: number; name: string }>(
    `SELECT id, name FROM subjects WHERE tenant_id=$1 ORDER BY name`,
    [tenantId]
  );
  return rows;
}

/* Content (VOD & Notes) */
export interface ContentItem {
  id: number;
  title: string;
  fileUrl: string;
  contentType: string;
  chapterId: number;
  chapterName: string;
  subjectId: number;
  batchId: number | null;
}

export async function listContent(tenantId: number, teacherId: number, chapterId?: number): Promise<ContentItem[]> {
  const params: any[] = [tenantId, teacherId];
  let q = `
    SELECT c.id, c.title, c.file_url AS "fileUrl", c.content_type AS "contentType",
           c.chapter_id AS "chapterId", ch.name AS "chapterName", ch.subject_id AS "subjectId",
           c.batch_id AS "batchId"
      FROM content c
      JOIN chapters ch ON ch.id = c.chapter_id
     WHERE c.tenant_id=$1 AND c.created_by=$2
  `;
  if (chapterId) {
    params.push(chapterId);
    q += ` AND c.chapter_id=$3`;
  }
  q += ` ORDER BY c.created_at DESC`;
  
  const { rows } = await query<ContentItem>(q, params);
  return rows;
}

export interface CreateContentInput {
  title: string;
  fileUrl: string;
  contentType: string;
  batchId?: number;
  chapterId: number;
}

export async function createContent(
  tenantId: number,
  teacherId: number,
  { title, fileUrl, contentType, batchId, chapterId }: CreateContentInput
) {
  if (batchId) {
    const b = await query(`SELECT 1 FROM batches WHERE id=$1 AND tenant_id=$2`, [batchId, tenantId]);
    if (!b.rowCount) throw ApiError.badRequest('INVALID_BATCH');
  }
  const ch = await query(`SELECT subject_id FROM chapters WHERE id=$1 AND tenant_id=$2`, [chapterId, tenantId]);
  if (!ch.rowCount) throw ApiError.badRequest('INVALID_CHAPTER');

  let durationMinutes = 0;
  if (contentType === 'video' && fileUrl) {
    try {
      durationMinutes = await new Promise<number>((resolve) => {
        if (!fileUrl.includes('youtube.com') && !fileUrl.includes('youtu.be')) return resolve(0);
        https.get(fileUrl, (res) => {
          let data = '';
          res.on('data', chunk => data += chunk);
          res.on('end', () => {
            const match = data.match(/<meta itemprop="duration" content="([^"]+)">/);
            if (match && match[1]) {
              let minutes = 0;
              const h = match[1].match(/(\d+)H/);
              const m = match[1].match(/(\d+)M/);
              const s = match[1].match(/(\d+)S/);
              if (h) minutes += parseInt(h[1]) * 60;
              if (m) minutes += parseInt(m[1]);
              if (s && parseInt(s[1]) > 30) minutes += 1;
              resolve(minutes);
            } else {
              resolve(0);
            }
          });
        }).on('error', () => resolve(0));
      });
    } catch (e) {
      durationMinutes = 0;
    }
  }

  const { rows } = await query(
    `INSERT INTO content (tenant_id, batch_id, subject_id, chapter_id, content_type, title, file_url, created_by, duration_minutes)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
     RETURNING id, title, file_url AS "fileUrl", content_type AS "contentType", chapter_id AS "chapterId", batch_id AS "batchId", duration_minutes AS "durationMinutes"`,
    [tenantId, batchId || null, ch.rows[0].subject_id, chapterId, contentType, title, fileUrl, teacherId, durationMinutes]
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
