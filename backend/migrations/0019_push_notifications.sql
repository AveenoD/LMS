-- ============================================================
-- Push notification support.
--
-- 1) device_tokens — one row per (user, device). A user can have multiple
--    devices (phone + tablet); token is unique so re-registering the same
--    device just refreshes last_seen_at instead of duplicating.
--
-- 2) notifications gains `type` + `entity_id` so the mobile app can deep-link
--    a tapped notification to the right screen (e.g. type='test_reminder',
--    entity_id=<test id> -> open Test Detail for that test). Both nullable —
--    existing broadcast rows (manual admin messages) have no natural entity.
-- ============================================================

CREATE TABLE device_tokens (
  id            SERIAL PRIMARY KEY,
  user_id       INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tenant_id     INT REFERENCES tenants(id) ON DELETE CASCADE,
  token         TEXT NOT NULL,
  platform      VARCHAR(10) NOT NULL, -- android|ios
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (token)
);
CREATE INDEX idx_device_tokens_user ON device_tokens (user_id);

ALTER TABLE notifications ADD COLUMN type VARCHAR(30);
ALTER TABLE notifications ADD COLUMN entity_id INT;
