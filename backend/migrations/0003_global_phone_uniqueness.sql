-- ============================================================
-- Global phone uniqueness (0003)
-- Login is now phone + password only (no institute slug) — every
-- login lookup must resolve a phone number to exactly one user
-- across the whole platform, not just within one tenant.
-- ============================================================

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_tenant_id_phone_key;
DROP INDEX IF EXISTS uniq_superadmin_phone;

CREATE UNIQUE INDEX IF NOT EXISTS uniq_users_phone ON users (phone);
