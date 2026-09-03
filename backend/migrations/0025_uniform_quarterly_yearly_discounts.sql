-- ============================================================
-- Replaces the old inconsistent per-tier quarterly/yearly discounts
-- (Basic was 25%/40% off, Pro 16.7%/26.7%, Elite 20%/30% — no shared
-- formula) with a uniform 15% off quarterly / 30% off yearly across
-- every tier, applied to the new 19/29/49 monthly prices from
-- migration 0024.
-- ============================================================

UPDATE plan_catalog
   SET price_quarterly = ROUND(price_monthly * 0.85),
       price_yearly    = ROUND(price_monthly * 0.70)
 WHERE name IN ('Basic', 'Pro', 'Elite');
