-- ============================================================
-- Stage 3: split teacher-only fields off `users` into a `teachers`
-- table, matching the existing `students` subtype pattern (a
-- coaching_admin or student never has status/leave_start/leave_end,
-- so those columns were always meaningless on 3 of the 4 roles).
--
-- Deliberately NOT repointing timetable.teacher_id / attendance.marked_by /
-- content.created_by / live_classes.teacher_id to teachers.id — those keep
-- referencing users.id unchanged. Repointing them would touch 6+ query
-- sites across 5 service files for a purely cosmetic gain; the actual
-- problem (teacher fields living on the shared users table) is already
-- fully fixed by this split alone.
-- ============================================================

CREATE TABLE teachers (
  id          SERIAL PRIMARY KEY,
  tenant_id   INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id     INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status      user_status NOT NULL DEFAULT 'active',
  leave_start DATE,
  leave_end   DATE
);

INSERT INTO teachers (tenant_id, user_id, status, leave_start, leave_end)
SELECT tenant_id, id, status, leave_start, leave_end
FROM users WHERE role = 'teacher';

-- Verification gate: every teacher user must have exactly one teachers row.
DO $$
DECLARE teacher_user_count INT; teacher_row_count INT;
BEGIN
  SELECT count(*) INTO teacher_user_count FROM users WHERE role = 'teacher';
  SELECT count(*) INTO teacher_row_count FROM teachers;
  IF teacher_user_count != teacher_row_count THEN
    RAISE EXCEPTION 'teacher backfill mismatch: % teacher users vs % teachers rows',
      teacher_user_count, teacher_row_count;
  END IF;
END $$;

ALTER TABLE users DROP COLUMN status;
ALTER TABLE users DROP COLUMN leave_start;
ALTER TABLE users DROP COLUMN leave_end;

CREATE INDEX idx_teachers_tenant ON teachers(tenant_id);
