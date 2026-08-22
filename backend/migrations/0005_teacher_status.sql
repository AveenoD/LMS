-- 0005: Add teacher status tracking (active, on_leave, inactive)
-- Adds status column and leave date range to the users table

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS leave_start DATE,
  ADD COLUMN IF NOT EXISTS leave_end DATE;
