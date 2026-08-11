-- ============================================================
-- Stage 2: tests.test_date (DATE) -> tests.scheduled_at (TIMESTAMPTZ)
-- Enables scheduling a test at any date AND time (not just a bare date).
-- ============================================================

ALTER TABLE tests ADD COLUMN scheduled_at TIMESTAMPTZ;

UPDATE tests SET scheduled_at = test_date::timestamptz WHERE test_date IS NOT NULL;

ALTER TABLE tests DROP COLUMN test_date;
