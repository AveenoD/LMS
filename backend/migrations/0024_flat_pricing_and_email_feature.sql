-- ============================================================
-- Adds a per-tier flat monthly price (institutes billed by flat rate
-- instead of per-student pay this fixed amount for that tier's features,
-- instead of the single global DEFAULT_PLAN_AMOUNT). Also updates the
-- seeded per-student prices to the new 19/29/49 pricing, adds the new
-- 'email_notifications' feature key to Pro/Elite, and removes the stale
-- 'custom_branding' key that shouldn't have survived migration 0023's
-- cleanup on any newly-created rows.
-- ============================================================

ALTER TABLE plan_catalog
  ADD COLUMN IF NOT EXISTS flat_price_monthly INT;

-- Backfill + update seeded plans with new pricing and feature set.
UPDATE plan_catalog
   SET price_monthly = 19,
       flat_price_monthly = 1499,
       features = '["student_management","batch_management","digital_attendance","fee_management","video_library"]'::jsonb
 WHERE name = 'Basic';

UPDATE plan_catalog
   SET price_monthly = 29,
       flat_price_monthly = 2499,
       features = '["student_management","batch_management","digital_attendance","fee_management","video_library","whatsapp_reminders","email_notifications","live_classes","performance_reports","online_tests","doubt_solving"]'::jsonb
 WHERE name = 'Pro';

UPDATE plan_catalog
   SET price_monthly = 49,
       flat_price_monthly = 3999,
       features = '["student_management","batch_management","digital_attendance","fee_management","video_library","whatsapp_reminders","email_notifications","live_classes","performance_reports","online_tests","doubt_solving","teacher_accounts"]'::jsonb
 WHERE name = 'Elite';

-- Any other plan a super_admin created since launch: default its flat
-- price to its existing per-student monthly rate x 80 (this migration's
-- Basic/Pro/Elite breakeven point), so nothing is left NULL.
UPDATE plan_catalog
   SET flat_price_monthly = price_monthly * 80
 WHERE flat_price_monthly IS NULL;

ALTER TABLE plan_catalog
  ALTER COLUMN flat_price_monthly SET NOT NULL;
