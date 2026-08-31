-- ============================================================
-- The app has no way to know when a Google Meet call actually ends —
-- Google doesn't push that event anywhere, and the "LIVE" badge is purely
-- computed from scheduled_at + a fixed window. So teachers get a manual
-- "Mark as Ended" action; ended_at set means the class is treated as past
-- regardless of the scheduled-time window.
-- ============================================================

ALTER TABLE live_classes ADD COLUMN ended_at TIMESTAMPTZ;
