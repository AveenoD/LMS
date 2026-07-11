-- ============================================================
-- Notification broadcast support indexes (0004)
-- The `notifications` table (0001) already has the right shape for
-- broadcasts (tenant_id, user_id, title, body, is_read) — no column
-- changes needed. These indexes back the two new query patterns:
-- unread-count lookups per user, and super_admin filtering tenants by city.
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications (user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_tenants_city ON tenants (city);
