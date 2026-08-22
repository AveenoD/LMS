# Database Migrations

Consolidated reference for every migration under `backend/migrations/`.
Source of truth is always the `.sql` file itself — this doc is a readable
index, not a replacement for it.

## How to run

```bash
cd backend
npm run db:migrate        # applies any migration not yet in _migrations
npm run db:migrate -- --fresh   # ⚠️ drops the public schema first, then re-applies everything
npm run db:reset          # --fresh migrate + reseed demo data (dev only)
```

Migrations are tracked in an auto-created `_migrations` table (filename +
applied_at) — re-running `db:migrate` is safe, it skips whatever's already
applied. Point `DATABASE_URL` at your Supabase connection string before
running these against Supabase instead of a local Postgres.

---

## 0001 — `0001_init.sql`
**Initial schema.** Every table the app is built on: `tenants`, `subscriptions`,
`users` (global phone-unique from the start for `tenant_id IS NULL` rows —
see 0003), `students`, `subjects`, `batches`, `batch_enrollments`, `timetable`,
`attendance`, `fee_structures`, `fee_payments`, `content` (video library),
`live_classes`, `tests`/`test_results`, `notifications`, `leads`, `audit_log`.

Golden rule baked in from this migration onward: every tenant-owned table has
`tenant_id NOT NULL REFERENCES tenants(id)`, and every query filters by it —
tenant isolation is enforced at the query layer, from the JWT only.

## 0002 — `0002_pricing_plans.sql`
**Per-student pricing plan catalog.** Adds `plan_catalog` (name, tagline, 3
price tiers — monthly/quarterly/yearly, `features` JSONB array, `is_active`,
`display_order`) and extends `subscriptions` with `plan_catalog_id`,
`billing_cycle`, `per_student_rate`, `student_count_snapshot`. Seeds 3 default
plans (Basic/Pro/Elite) with `ON CONFLICT (name) DO NOTHING`. Adds a trigger to
auto-update `plan_catalog.updated_at` on every row update.

This is what `featureGuard` middleware reads to gate the 12 `FeatureKey`s
(`student_management`, `batch_management`, `digital_attendance`,
`fee_management`, `video_library`, `whatsapp_reminders`, `live_classes`,
`performance_reports`, `online_tests`, `doubt_solving`, `custom_branding`,
`teacher_accounts`) per tenant's assigned plan.

## 0003 — `0003_global_phone_uniqueness.sql`
**Single login form for every role.** Drops the old `UNIQUE (tenant_id, phone)`
constraint and the `uniq_superadmin_phone` partial index, replacing both with
one global `UNIQUE (phone)` index across all users. This is what let login
drop the institute `slug` field — the backend now resolves a user (and, for
non-super-admin roles, their institute/branding) from phone alone, since phone
numbers are guaranteed unique platform-wide, not just within one tenant.

⚠️ Requires every phone number in the `users` table to already be globally
unique before this runs — if two tenants happen to share a phone value (e.g.
leftover test data), the `CREATE UNIQUE INDEX` step will fail until the
duplicate is resolved.

## 0004 — `0004_notification_broadcast_indexes.sql`
**Notification broadcast support indexes.** No schema change — the
`notifications` table (from 0001: `tenant_id`, `user_id`, `title`, `body`,
`is_read`, `created_at`) already had the right shape for broadcasts. Adds two
indexes: `idx_notifications_user_unread` on `(user_id, is_read)` for fast
unread-count badges, and `idx_tenants_city` on `tenants(city)` for Super
Admin's area/location-filtered broadcasts.

Backs the reusable `broadcastNotification()` service
(`src/services/notificationCenter.service.ts`), used by both:
- `POST /superadmin/notifications/broadcast` — Super Admin → coaching_admins,
  optionally filtered by institute city
- `POST /admin/notifications/broadcast` — Coaching Admin → students in their
  own institute, optionally filtered by batch
