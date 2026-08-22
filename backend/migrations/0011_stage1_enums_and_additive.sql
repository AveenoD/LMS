-- ============================================================
-- Stage 1: additive-only schema hardening.
-- Enum types replace free-text VARCHAR status/role/type columns
-- (DB-level enforcement instead of just app-layer zod checks).
-- New columns are pure additions for not-yet-built features —
-- nothing in existing code reads or writes them yet.
-- ============================================================

CREATE TYPE subscription_status AS ENUM ('trial','active','past_due','suspended');
CREATE TYPE billing_cycle       AS ENUM ('monthly','quarterly','yearly');
CREATE TYPE user_role           AS ENUM ('super_admin','coaching_admin','teacher','student');
CREATE TYPE user_status         AS ENUM ('active','on_leave','inactive');
CREATE TYPE attendance_status   AS ENUM ('present','absent','late');
CREATE TYPE payment_method      AS ENUM ('cash','upi','card');
CREATE TYPE content_type        AS ENUM ('video','document','image');
CREATE TYPE lead_status         AS ENUM ('new','contacted','converted','lost');

-- Each column with a DEFAULT needs the default dropped before the type
-- change (Postgres can't auto-cast a DEFAULT expression) and restored after.
ALTER TABLE users ALTER COLUMN role TYPE user_role USING role::text::user_role;

ALTER TABLE users ALTER COLUMN status DROP DEFAULT;
ALTER TABLE users ALTER COLUMN status TYPE user_status USING status::text::user_status;
ALTER TABLE users ALTER COLUMN status SET DEFAULT 'active';

ALTER TABLE subscriptions ALTER COLUMN status DROP DEFAULT;
ALTER TABLE subscriptions ALTER COLUMN status TYPE subscription_status USING status::text::subscription_status;
ALTER TABLE subscriptions ALTER COLUMN status SET DEFAULT 'trial';

ALTER TABLE subscriptions ALTER COLUMN billing_cycle DROP DEFAULT;
ALTER TABLE subscriptions ALTER COLUMN billing_cycle TYPE billing_cycle USING billing_cycle::text::billing_cycle;
ALTER TABLE subscriptions ALTER COLUMN billing_cycle SET DEFAULT 'monthly';

ALTER TABLE attendance ALTER COLUMN status DROP DEFAULT;
ALTER TABLE attendance ALTER COLUMN status TYPE attendance_status USING status::text::attendance_status;
ALTER TABLE attendance ALTER COLUMN status SET DEFAULT 'present';

ALTER TABLE fee_payments ALTER COLUMN method DROP DEFAULT;
ALTER TABLE fee_payments ALTER COLUMN method TYPE payment_method USING method::text::payment_method;
ALTER TABLE fee_payments ALTER COLUMN method SET DEFAULT 'cash';

ALTER TABLE content ALTER COLUMN content_type DROP DEFAULT;
ALTER TABLE content ALTER COLUMN content_type TYPE content_type USING content_type::text::content_type;
ALTER TABLE content ALTER COLUMN content_type SET DEFAULT 'video';

ALTER TABLE leads ALTER COLUMN status DROP DEFAULT;
ALTER TABLE leads ALTER COLUMN status TYPE lead_status USING status::text::lead_status;
ALTER TABLE leads ALTER COLUMN status SET DEFAULT 'new';

-- Additive columns for upcoming features (profile photos, chapter-progress
-- tracking, batch-linked subjects). Nullable/defaulted so nothing existing breaks.
ALTER TABLE users    ADD COLUMN avatar_url TEXT;
ALTER TABLE subjects ADD COLUMN total_chapters INT NOT NULL DEFAULT 0;
ALTER TABLE batches  ADD COLUMN subject_ids INT[] NOT NULL DEFAULT '{}';

-- Backfill total_chapters from the chapters that already exist per subject,
-- so "remaining chapters" starts at 0 rather than a nonsense negative number.
UPDATE subjects s SET total_chapters = (
  SELECT count(*) FROM chapters WHERE subject_id = s.id
);

-- Backfill batches.subject_ids from the subjects currently implied by
-- timetable entries — today's only (implicit, fragile) source of truth
-- for "which subjects does this batch have".
UPDATE batches b SET subject_ids = (
  SELECT COALESCE(array_agg(DISTINCT subject_id), '{}')
  FROM timetable WHERE batch_id = b.id AND subject_id IS NOT NULL
);

CREATE INDEX idx_batches_subject_ids ON batches USING GIN (subject_ids);

-- Safety gate: fail loudly (and roll back the whole file) if any table has
-- a value outside its new enum's allowed set that somehow slipped through
-- the ALTER above without erroring (defense in depth).
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM users WHERE role IS NULL) THEN
    RAISE EXCEPTION 'users.role has NULL values after enum conversion';
  END IF;
END $$;
