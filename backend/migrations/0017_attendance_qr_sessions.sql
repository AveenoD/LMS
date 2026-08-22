-- ============================================================
-- QR-code based attendance. A teacher generates a time-limited
-- session (random token + expiry); students scan it within the
-- window to mark themselves present. Expiry is always enforced
-- server-side (now() vs expires_at), never trusting the client clock.
-- ============================================================

CREATE TABLE attendance_sessions (
  id           SERIAL PRIMARY KEY,
  tenant_id    INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id     INT NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
  timetable_id INT REFERENCES timetable(id),
  created_by   INT NOT NULL REFERENCES users(id),
  token        VARCHAR(64) NOT NULL UNIQUE,
  date         DATE NOT NULL,
  expires_at   TIMESTAMPTZ NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_attendance_sessions_batch_date ON attendance_sessions(batch_id, date);

-- Ties an attendance row back to the QR session that created it (null for
-- manually-marked rows), so a teacher's live "who's scanned" list can be
-- scoped to exactly this session instead of every present-marked row that
-- day.
ALTER TABLE attendance ADD COLUMN session_id INT REFERENCES attendance_sessions(id) ON DELETE SET NULL;
