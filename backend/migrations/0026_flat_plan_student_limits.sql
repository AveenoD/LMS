-- ============================================================
-- Adds a per-tier student cap for the flat-rate billing mode. Flat pricing
-- previously had no ceiling, so a large institute could pick the cheapest
-- flat tier and onboard an unlimited number of students for a fixed price
-- — undercutting the per-student tiers entirely. Each tier's cap is set
-- close to where the flat rate and that tier's per-student rate roughly
-- break even, keeping the two billing modes consistent with each other.
-- ============================================================

ALTER TABLE plan_catalog
  ADD COLUMN IF NOT EXISTS flat_student_limit INT;

UPDATE plan_catalog SET flat_student_limit = 50  WHERE name = 'Basic';
UPDATE plan_catalog SET flat_student_limit = 150 WHERE name = 'Pro';
UPDATE plan_catalog SET flat_student_limit = 400 WHERE name = 'Elite';

-- Any other plan a super_admin created since launch: default to 100 so
-- nothing is left NULL (super_admin can adjust it from the plan editor).
UPDATE plan_catalog
   SET flat_student_limit = 100
 WHERE flat_student_limit IS NULL;

ALTER TABLE plan_catalog
  ALTER COLUMN flat_student_limit SET NOT NULL;
