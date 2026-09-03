# Campus — Backend (TypeScript)

Multi-Tenant Campus: an ERP + LMS for coaching institutes. This is the core
API server, now written entirely in **TypeScript** (Node.js + Express 4 +
PostgreSQL).

## Tech Stack
- **Language**: TypeScript (ESM, `NodeNext` module resolution), strict mode
- **Runtime**: Node.js + Express 4
- **DB**: PostgreSQL (single DB, `tenant_id` on every tenant-owned table)
- **Auth**: JWT access (15m) + refresh (30d), bcryptjs password hashing
- **Validation**: Zod via a `validate(schema)` middleware
- **Payments**: Razorpay (with a dev mock fallback when keys are absent)
- **Notifications (FREE)**: SMTP email + Telegram Bot + in-app leads inbox
- **wa.me deep links**: free click-to-chat for fee reminders / absentee / doubts
- **Jobs**: `node-cron` daily billing sweep
- **Process manager**: PM2 (app `campus-api`, port `4000`)

## Scripts
| Command | Description |
|---|---|
| `npm run typecheck` | Type-check with `tsc --noEmit` (must be zero errors) |
| `npm run build` | Compile `src/**/*.ts` → `dist/**/*.js` |
| `npm start` | Run the compiled server (`node dist/app.js`) |
| `npm run dev` | Run with hot reload via `tsx watch src/app.ts` |
| `npm run db:migrate` | Apply SQL migrations (`tsx src/db/migrate.ts`) |
| `npm run db:seed` | Seed demo data |
| `npm run db:reset` | Fresh migrate + seed |

## Run locally (sandbox)
```bash
npm install
npm run build
npm run db:migrate
npm run db:seed
pm2 start ecosystem.config.cjs   # serves dist/app.js on :4000
curl http://localhost:4000/health
```

## Project Structure
```
src/
├── app.ts                     # Express bootstrap + route mounting
├── types/                     # AuthUser, JWT payloads, Express Request augmentation
├── config/                    # env (typed), db (pg pool + generic query<T>)
├── utils/                     # logger, ApiError, asyncHandler, jwt, receipt
├── middleware/                # auth, roleGuard, subscriptionGuard, validate, errorHandler, rateLimiter
├── db/
│   ├── rows.ts                # raw row types (snake_case)
│   ├── migrate.ts / seed.ts   # DB scripts
│   └── repositories/          # tenantRepo, userRepo
├── services/                  # auth, admin, teacher, student, superadmin, lead, notification, whatsapp, razorpay
├── controllers/               # thin HTTP handlers (helpers.ts provides tenantId/userId)
├── validators/                # zod schemas
├── routes/                    # per-role routers
└── jobs/                      # billing.job.ts (cron)
```

## Roles & Isolation
- `super_admin` — global (`tenant_id` NULL); manages tenants, subscriptions, leads inbox, analytics.
- `coaching_admin` — per tenant; teachers/students/batches/subjects/timetable/fees/branding. Writes are gated by `subscriptionGuard` (trial expiry / past_due → 403; reads stay open).
- `teacher` — schedule, attendance (+ absentee wa.me links), content, live classes, doubt links.
- `student` — dashboard, videos, live classes, fees/receipts, ask-doubt wa.me link.

**Tenant isolation** is enforced from `req.user.tenantId` (decoded from the JWT), never from the request body.

## Key API Entry Points (base `/api/v1`)
- `POST /auth/login` — `{ phone, password }` (single login form for every role — phone is globally unique)
- `POST /auth/refresh`, `GET /auth/me`, `POST /auth/logout`
- `POST /leads` — **PUBLIC** demo booking (rate-limited) → persists + fires free notifications
- `GET /superadmin/analytics|tenants|subscriptions|leads`, `POST /superadmin/tenants`
- `GET /admin/dashboard|students|teachers|batches|fees|...`, writes under `subscriptionGuard`
- `GET /admin/fees/:studentId/remind` — free wa.me fee reminder link
- `GET /teacher/schedule/today`, `POST /teacher/attendance`, `GET /teacher/doubt-link/:studentId`
- `GET /student/dashboard|videos|live/today|fees`, `GET /student/ask-doubt?teacherId=&chapter=`
- `POST /payments/create-order`, `POST /payments/verify`, `GET /payments/subscription`
- `GET /health`

## Demo Logins (password: `Password@123`)
- super_admin: `918888800000`
- Apex admin: `919000000011` — starts on **trial**
- Apex teacher: `919000000012`
- Apex student: `919000000013`
- Pioneer admin: `919000000021` — **active** subscription

## Notifications (all FREE)
Configure in `.env` (see `.env.example`):
- **Email**: `NOTIFY_EMAIL_ENABLED=true` + SMTP creds (e.g. Gmail App Password)
- **Telegram**: `NOTIFY_TELEGRAM_ENABLED=true` + bot token + chat id
- **In-app**: always on — leads persist to the `leads` table (Super Admin inbox)

If none are configured, lead submission still succeeds (in-app inbox always works).

## Status
- ✅ Full backend converted to TypeScript — `tsc` passes with **zero errors**
- ✅ Compiled build runs under PM2; full API smoke test passes end-to-end
- ✅ Trial-lock → pay → unlock flow verified (subscriptionGuard async middleware wrapped in `asyncHandler`)
- **Last updated**: 2026-07-07
