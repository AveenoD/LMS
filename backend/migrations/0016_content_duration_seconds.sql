-- ============================================================
-- Exact video duration, in seconds — duration_minutes alone rounds
-- (e.g. a 3:34 video was shown as "4 min"), which reads as wrong/misleading.
-- duration_minutes stays as a coarse floor(seconds/60) fallback for any
-- display that only needs "about how long"; duration_seconds is the
-- source of truth for exact mm:ss display.
-- ============================================================

ALTER TABLE content ADD COLUMN duration_seconds INT NOT NULL DEFAULT 0;

-- Best-effort backfill for existing rows: minutes*60 is only an
-- approximation (the original seconds were never stored), but it's
-- closer than leaving it at 0.
UPDATE content SET duration_seconds = duration_minutes * 60 WHERE duration_minutes > 0;
