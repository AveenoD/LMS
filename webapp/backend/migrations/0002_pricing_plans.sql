-- ============================================================
-- Migration 0002: Per-Student Pricing Plans
-- Adds plan_catalog table and extends subscriptions table
-- ============================================================

-- ---------- PLAN CATALOG (Super Admin managed) ----------
CREATE TABLE IF NOT EXISTS plan_catalog (
  id               SERIAL PRIMARY KEY,
  name             VARCHAR(40) NOT NULL UNIQUE,        -- 'Basic' | 'Pro' | 'Elite'
  tagline          TEXT,                               -- UI subtitle
  price_monthly    INT NOT NULL,                       -- ₹ per student per month
  price_quarterly  INT NOT NULL,                       -- ₹ per student per month (quarterly rate)
  price_yearly     INT NOT NULL,                       -- ₹ per student per month (yearly rate)
  features         JSONB NOT NULL DEFAULT '[]',        -- array of feature keys
  is_active        BOOLEAN NOT NULL DEFAULT true,      -- Super Admin can hide plans
  display_order    SMALLINT NOT NULL DEFAULT 0,        -- UI sort order
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- EXTEND SUBSCRIPTIONS ----------
ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS plan_catalog_id    INT REFERENCES plan_catalog(id),
  ADD COLUMN IF NOT EXISTS billing_cycle      VARCHAR(20) NOT NULL DEFAULT 'monthly',  -- monthly|quarterly|yearly
  ADD COLUMN IF NOT EXISTS per_student_rate   INT,           -- snapshot at payment time (₹/student/mo)
  ADD COLUMN IF NOT EXISTS student_count_snapshot INT;       -- snapshot at payment time

-- Index for fast plan lookups
CREATE INDEX IF NOT EXISTS idx_plan_catalog_active ON plan_catalog(is_active, display_order);
CREATE INDEX IF NOT EXISTS idx_subscriptions_plan  ON subscriptions(plan_catalog_id);

-- ---------- SEED DEFAULT PLANS ----------
INSERT INTO plan_catalog (name, tagline, price_monthly, price_quarterly, price_yearly, features, display_order)
VALUES
  (
    'Basic',
    'Apni coaching ko digital banayein, bina kisi jhanjhat ke.',
    20, 15, 12,
    '["student_management","batch_management","digital_attendance","fee_management","video_library"]',
    1
  ),
  (
    'Pro',
    'Smart automation jo aapka time bachaye. Ideal for growing institutes.',
    30, 25, 22,
    '["student_management","batch_management","digital_attendance","fee_management","video_library","whatsapp_reminders","live_classes","performance_reports","online_tests","doubt_solving"]',
    2
  ),
  (
    'Elite',
    'Apna khud ka digital brand banayein. For premium setups.',
    50, 40, 35,
    '["student_management","batch_management","digital_attendance","fee_management","video_library","whatsapp_reminders","live_classes","performance_reports","online_tests","doubt_solving","custom_branding","teacher_accounts"]',
    3
  )
ON CONFLICT (name) DO NOTHING;

-- Trigger to auto-update updated_at on plan_catalog
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_plan_catalog_updated_at ON plan_catalog;
CREATE TRIGGER trg_plan_catalog_updated_at
  BEFORE UPDATE ON plan_catalog
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
