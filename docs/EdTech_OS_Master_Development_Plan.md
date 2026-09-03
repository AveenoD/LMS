# 🚀 Master Development Plan — Multi-Tenant Campus

> **Purpose of this document:** This is a *complete, executable engineering blueprint*. It is written so that a small AI coding assistant (e.g. Gemini Pro) can follow it **phase-by-phase and build the entire product flawlessly**. Every decision has already been made for you — schemas, endpoints, folder structures, screens, navigation, and copy‑paste‑ready build prompts. Do not improvise; follow the spec.

---

## 📑 Table of Contents

1. [Executive Summary & Vision](#1-executive-summary--vision)
2. [System Architecture](#2-system-architecture)
3. [Business Flow (Lead → Paid Client)](#3-business-flow-lead--paid-client)
4. [Multi-Tenant Database Design](#4-multi-tenant-database-design)
5. [Backend Design (Node.js + Express)](#5-backend-design-nodejs--express)
6. [Flutter App Architecture](#6-flutter-app-architecture)
7. [Screen-by-Screen UI & Navigation](#7-screen-by-screen-ui--navigation)
8. [Marketing Website (Next.js)](#8-marketing-website-nextjs)
9. [Phase-Wise Execution Roadmap (Gemini-Ready Prompts)](#9-phase-wise-execution-roadmap-gemini-ready-prompts)
10. [Deployment & DevOps](#10-deployment--devops)
11. [Security & Best Practices Checklist](#11-security--best-practices-checklist)
12. [Future Roadmap](#12-future-roadmap)

---

## 1. Executive Summary & Vision

### 1.1 Product Vision
**Multi-Tenant Campus** is a zero-maintenance ERP + LMS that turns any local coaching institute into a fully digital operation in under 24 hours. One Flutter app serves four roles (Super Admin, Coaching Admin, Teacher, Student/Parent). One Node.js backend and one PostgreSQL database serve *all* institutes, isolated by a `tenant_id`.

### 1.2 Target Market
- **Beachhead:** Coaching institutes in **Nashik** (JEE/NEET/board tuition, 50–500 students each).
- **Expansion:** Tier-2/Tier-3 city coaching centers across Maharashtra, then pan-India.

### 1.3 Business Model
- **1-week free trial**, then paid.
- **Pricing:** Flat **₹2,500/month** per institute *(default)* OR per-student pricing (e.g. ₹15/student/month) — configurable per tenant.
- **Lock-in:** After day 7, the Coaching Admin write-panel locks until Razorpay payment succeeds.

### 1.4 Revenue Math (why this is profitable)
| Item | Value |
|---|---|
| Server (DigitalOcean droplet, 2GB RAM) | **₹1,000 / month** |
| Institutes onboarded | 20 |
| Revenue @ ₹2,500 flat | **₹50,000 / month** |
| Gross margin | **~98%** |
| Break-even | **1 paying institute** |

Because the server only moves lightweight JSON (no video, no chat, no live-stream), a single $12 droplet comfortably serves **20+ institutes and thousands of students**.

---

## 2. System Architecture

### 2.1 High-Level Diagram
```
                          ┌──────────────────────────────┐
                          │   MARKETING SITE (Next.js)    │
                          │  Landing + "Book a Demo" form │
                          └──────────────┬───────────────┘
                                         │ POST /api/lead
                                         ▼
   ┌──────────────┐            ┌───────────────────────────┐         ┌──────────────┐
   │ FLUTTER APP  │  HTTPS/JWT │   CORE BACKEND (Node.js)   │  SQL    │ PostgreSQL   │
   │ (1 app,      │◄──────────►│   Express + PM2 + Nginx    │◄───────►│ single DB    │
   │  4 roles)    │   REST     │   DigitalOcean $12 droplet │         │ tenant_id    │
   └──────┬───────┘            └───────────┬───────────────┘         │ isolation    │
          │                                │                          └──────────────┘
          │ url_launcher / in-app player   │ webhook
          ▼                                ▼
 ┌─────────────────┐             ┌──────────────────────┐
 │ EXTERNAL (free) │             │  n8n / WhatsApp       │
 │ • YouTube (VOD) │             │  Cloud (owner alerts) │
 │ • Google Meet   │             └──────────────────────┘
 │ • wa.me (doubts)│
 │ • Razorpay (pay)│
 └─────────────────┘
```

### 2.2 Request Lifecycle
1. User logs in → backend verifies credentials → issues **JWT access token** + **refresh token**.
2. JWT payload carries `{ userId, tenantId, role }`.
3. Every subsequent request includes `Authorization: Bearer <token>`.
4. `authMiddleware` decodes the token and attaches `req.user = { userId, tenantId, role }`.
5. `tenantScope` ensures **every DB query is filtered by `tenant_id = req.user.tenantId`**.
6. `roleGuard(...)` restricts the route to allowed roles.
7. `subscriptionGuard` blocks Coaching Admin *write* actions if the trial expired / payment is due.

### 2.3 Tenant Isolation (end-to-end)
- **Single database, shared schema.** Every tenant-owned table has a `tenant_id` column.
- The `tenant_id` is **never** taken from the request body — it is **always** read from the JWT (`req.user.tenantId`). This prevents a malicious client from reading another tenant's data.
- A repository/query helper (`scopedQuery`) auto-injects `WHERE tenant_id = $tenantId`, so no developer can forget it.

---

## 3. Business Flow (Lead → Paid Client)

### 3.1 Onboarding Funnel
```
1. LEAD GEN      → Owner fills "Book a Demo" on marketing site → webhook alerts YOU on WhatsApp.
2. DEMO          → You show the app.
3. ACCOUNT SETUP → You (Super Admin) create the tenant: name, logo, primary color, plan.
                   Trial starts: subscription_status='trial', trial_ends_at = now()+7 days.
4. BRANDING      → Logo + colors saved → Flutter app renders institute's branding.
5. DATA IMPORT   → Students/teachers added (manually or CSV).
6. 7-DAY TRIAL   → Institute uses live classes, attendance, fees freely.
7. DAY 8 LOCK    → subscriptionGuard blocks admin writes; app shows "Subscribe to continue".
8. PAYMENT       → Razorpay order → verify → subscription_status='active',
                   next_billing_date = now()+30 days → panel unlocks.
9. RENEWAL       → Cron flags institutes whose next_billing_date is near; reminder sent.
```

### 3.2 Trial-Lock Mechanism (technical)
- `subscriptions.status` enum: `trial | active | past_due | suspended`.
- `subscriptions.trial_ends_at` and `next_billing_date` (timestamps).
- **`subscriptionGuard` middleware** runs on all Coaching-Admin write routes (`POST/PUT/DELETE`):
  - If `status === 'trial'` and `now() > trial_ends_at` → **403** `{ code: 'TRIAL_EXPIRED' }`.
  - If `status === 'past_due'` or `'suspended'` → **403** `{ code: 'PAYMENT_REQUIRED' }`.
  - **Read** routes (GET) stay allowed so the institute can still view data (soft lock).
- **Grace period:** 2 days after `next_billing_date` before moving `active → past_due`.

---

## 4. Multi-Tenant Database Design

> **Golden rule:** every tenant-owned table has `tenant_id INTEGER NOT NULL REFERENCES tenants(id)`, and every query filters by it. The `tenants` and `users`(super_admin) rows are the only global data.

### 4.1 Entity Relationship Summary (ASCII)
```
tenants (1) ──< subscriptions (1)
tenants (1) ──< users (N)              [role: coaching_admin | teacher | student]
tenants (1) ──< students (N) ── belongs to ── users (1)
tenants (1) ──< batches (N)
tenants (1) ──< subjects (N)
batches (1) ──< batch_enrollments (N) >── students (1)
tenants (1) ──< timetable (N) >── batches, subjects, users(teacher)
timetable (1) ──< attendance (N) >── students
tenants (1) ──< fee_structures (N) >── batches
fee_structures (1) ──< fee_payments (N) >── students
tenants (1) ──< content (N) >── subjects, batches   [youtube_url]
tenants (1) ──< live_classes (N) >── batches         [meet_url]
tenants (1) ──< tests (N) ──< test_results (N) >── students
tenants (1) ──< notifications (N)
tenants (1) ──< audit_log (N)
```

### 4.2 Table Definitions

#### `tenants` — one row per institute
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | Tenant ID |
| name | VARCHAR(150) | NOT NULL | | Institute name (e.g. "Apex Academy") |
| slug | VARCHAR(60) | UNIQUE NOT NULL | | URL/login slug |
| logo_url | TEXT | | NULL | Branding logo |
| primary_color | VARCHAR(7) | | '#2563EB' | Hex brand color |
| city | VARCHAR(80) | | | e.g. Nashik |
| contact_phone | VARCHAR(15) | | | Owner WhatsApp number |
| is_active | BOOLEAN | NOT NULL | true | Global on/off |
| created_at | TIMESTAMPTZ | NOT NULL | now() | |

#### `subscriptions` — billing state per tenant
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants, UNIQUE NOT NULL | | One subscription per tenant |
| plan | VARCHAR(20) | NOT NULL | 'flat' | 'flat' or 'per_student' |
| amount | INT | NOT NULL | 2500 | ₹ amount |
| status | VARCHAR(20) | NOT NULL | 'trial' | trial/active/past_due/suspended |
| trial_ends_at | TIMESTAMPTZ | | | +7 days from creation |
| next_billing_date | TIMESTAMPTZ | | NULL | Set after first payment |
| created_at | TIMESTAMPTZ | NOT NULL | now() | |

#### `users` — all logins (super_admin is global, others tenant-scoped)
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants | NULL | NULL only for super_admin |
| role | VARCHAR(20) | NOT NULL | | super_admin/coaching_admin/teacher/student |
| full_name | VARCHAR(120) | NOT NULL | | |
| phone | VARCHAR(15) | NOT NULL | | Login identifier (with password) |
| email | VARCHAR(120) | | NULL | Optional |
| password_hash | TEXT | NOT NULL | | bcrypt hash |
| is_active | BOOLEAN | NOT NULL | true | |
| created_at | TIMESTAMPTZ | NOT NULL | now() | |
| **UNIQUE** | | (tenant_id, phone) | | Same phone allowed across tenants |

#### `students` — student profile + parent info (linked to a `users` row of role=student)
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| user_id | INT | FK→users UNIQUE NOT NULL | | The login account |
| roll_no | VARCHAR(30) | | NULL | |
| parent_name | VARCHAR(120) | | | |
| parent_phone | VARCHAR(15) | NOT NULL | | For WhatsApp reminders |
| grade | VARCHAR(30) | | | e.g. "Class 11" |
| joined_at | DATE | | now() | |

#### `subjects`
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| name | VARCHAR(80) | NOT NULL | | e.g. Physics |

#### `batches` — a class group
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| name | VARCHAR(80) | NOT NULL | | e.g. "JEE 2026 Morning" |
| grade | VARCHAR(30) | | | |
| created_at | TIMESTAMPTZ | | now() | |

#### `batch_enrollments` — many-to-many student↔batch
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| batch_id | INT | FK→batches NOT NULL | | |
| student_id | INT | FK→students NOT NULL | | |
| **UNIQUE** | | (batch_id, student_id) | | |

#### `timetable` — teacher allocation / schedule
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| batch_id | INT | FK→batches NOT NULL | | |
| subject_id | INT | FK→subjects | | |
| teacher_id | INT | FK→users NOT NULL | | role=teacher |
| day_of_week | SMALLINT | NOT NULL | | 0=Sun..6=Sat |
| start_time | TIME | NOT NULL | | |
| end_time | TIME | NOT NULL | | |

#### `attendance`
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| timetable_id | INT | FK→timetable | NULL | Which session |
| batch_id | INT | FK→batches NOT NULL | | |
| student_id | INT | FK→students NOT NULL | | |
| date | DATE | NOT NULL | | |
| status | VARCHAR(10) | NOT NULL | 'present' | present/absent/late |
| marked_by | INT | FK→users | | teacher id |
| **UNIQUE** | | (student_id, date, batch_id) | | |

#### `fee_structures`
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| batch_id | INT | FK→batches | NULL | Applies to batch |
| title | VARCHAR(100) | NOT NULL | | e.g. "Term 1 Fee" |
| amount | INT | NOT NULL | | ₹ total |
| due_date | DATE | | | |

#### `fee_payments`
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| student_id | INT | FK→students NOT NULL | | |
| fee_structure_id | INT | FK→fee_structures | | |
| amount_paid | INT | NOT NULL | | |
| paid_on | DATE | NOT NULL | now() | |
| method | VARCHAR(20) | | 'cash' | cash/upi/card |
| receipt_no | VARCHAR(40) | UNIQUE | | Generated |

#### `content` — VOD / videos (unlisted YouTube)
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| batch_id | INT | FK→batches | NULL | Target batch |
| subject_id | INT | FK→subjects | NULL | |
| title | VARCHAR(150) | NOT NULL | | |
| youtube_url | TEXT | NOT NULL | | Unlisted link |
| created_by | INT | FK→users | | teacher |
| created_at | TIMESTAMPTZ | | now() | |

#### `live_classes`
| Column | Type | Constraints | Default | Description |
|---|---|---|---|---|
| id | SERIAL | PK | | |
| tenant_id | INT | FK→tenants NOT NULL | | |
| batch_id | INT | FK→batches NOT NULL | | |
| title | VARCHAR(150) | NOT NULL | | |
| meet_url | TEXT | NOT NULL | | Google Meet / Jitsi |
| scheduled_at | TIMESTAMPTZ | NOT NULL | | |
| teacher_id | INT | FK→users | | |

#### `tests` & `test_results`
`tests`: id, tenant_id(FK), batch_id(FK), subject_id(FK), title, max_marks INT, test_date DATE.
`test_results`: id, tenant_id(FK), test_id(FK), student_id(FK), marks_obtained INT, UNIQUE(test_id, student_id).

#### `notifications`
id, tenant_id(FK), user_id(FK, target), title, body TEXT, is_read BOOLEAN default false, created_at.

#### `audit_log`
id, tenant_id(FK, nullable), actor_user_id(FK), action VARCHAR(80), entity VARCHAR(60), entity_id INT, meta JSONB, created_at.

### 4.3 Full CREATE TABLE SQL (`migrations/0001_init.sql`)
```sql
CREATE TABLE tenants (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(60) UNIQUE NOT NULL,
  logo_url TEXT,
  primary_color VARCHAR(7) DEFAULT '#2563EB',
  city VARCHAR(80),
  contact_phone VARCHAR(15),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE subscriptions (
  id SERIAL PRIMARY KEY,
  tenant_id INT UNIQUE NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  plan VARCHAR(20) NOT NULL DEFAULT 'flat',
  amount INT NOT NULL DEFAULT 2500,
  status VARCHAR(20) NOT NULL DEFAULT 'trial',
  trial_ends_at TIMESTAMPTZ,
  next_billing_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  tenant_id INT REFERENCES tenants(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  email VARCHAR(120),
  password_hash TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, phone)
);

CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  roll_no VARCHAR(30),
  parent_name VARCHAR(120),
  parent_phone VARCHAR(15) NOT NULL,
  grade VARCHAR(30),
  joined_at DATE DEFAULT now()
);

CREATE TABLE subjects (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(80) NOT NULL
);

CREATE TABLE batches (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(80) NOT NULL,
  grade VARCHAR(30),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE batch_enrollments (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id INT NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
  student_id INT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE (batch_id, student_id)
);

CREATE TABLE timetable (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id INT NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
  subject_id INT REFERENCES subjects(id),
  teacher_id INT NOT NULL REFERENCES users(id),
  day_of_week SMALLINT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL
);

CREATE TABLE attendance (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  timetable_id INT REFERENCES timetable(id),
  batch_id INT NOT NULL REFERENCES batches(id),
  student_id INT NOT NULL REFERENCES students(id),
  date DATE NOT NULL,
  status VARCHAR(10) NOT NULL DEFAULT 'present',
  marked_by INT REFERENCES users(id),
  UNIQUE (student_id, date, batch_id)
);

CREATE TABLE fee_structures (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id INT REFERENCES batches(id),
  title VARCHAR(100) NOT NULL,
  amount INT NOT NULL,
  due_date DATE
);

CREATE TABLE fee_payments (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  student_id INT NOT NULL REFERENCES students(id),
  fee_structure_id INT REFERENCES fee_structures(id),
  amount_paid INT NOT NULL,
  paid_on DATE NOT NULL DEFAULT now(),
  method VARCHAR(20) DEFAULT 'cash',
  receipt_no VARCHAR(40) UNIQUE
);

CREATE TABLE content (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id INT REFERENCES batches(id),
  subject_id INT REFERENCES subjects(id),
  title VARCHAR(150) NOT NULL,
  youtube_url TEXT NOT NULL,
  created_by INT REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE live_classes (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id INT NOT NULL REFERENCES batches(id),
  title VARCHAR(150) NOT NULL,
  meet_url TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  teacher_id INT REFERENCES users(id)
);

CREATE TABLE tests (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id INT REFERENCES batches(id),
  subject_id INT REFERENCES subjects(id),
  title VARCHAR(150) NOT NULL,
  max_marks INT NOT NULL,
  test_date DATE
);

CREATE TABLE test_results (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  test_id INT NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
  student_id INT NOT NULL REFERENCES students(id),
  marks_obtained INT NOT NULL,
  UNIQUE (test_id, student_id)
);

CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id INT REFERENCES users(id),
  title VARCHAR(150) NOT NULL,
  body TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  tenant_id INT REFERENCES tenants(id),
  actor_user_id INT REFERENCES users(id),
  action VARCHAR(80),
  entity VARCHAR(60),
  entity_id INT,
  meta JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes on tenant_id + common lookups
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_students_tenant ON students(tenant_id);
CREATE INDEX idx_batches_tenant ON batches(tenant_id);
CREATE INDEX idx_attendance_tenant_date ON attendance(tenant_id, date);
CREATE INDEX idx_fee_payments_tenant_student ON fee_payments(tenant_id, student_id);
CREATE INDEX idx_content_tenant_batch ON content(tenant_id, batch_id);
CREATE INDEX idx_live_tenant_time ON live_classes(tenant_id, scheduled_at);
```

### 4.4 Seed Data (`seed.sql`) — demonstrates isolation
```sql
-- Two institutes
INSERT INTO tenants (id, name, slug, city, contact_phone, primary_color) VALUES
 (1, 'Apex Academy', 'apex', 'Nashik', '919999900001', '#2563EB'),
 (2, 'Pioneer Classes', 'pioneer', 'Nashik', '919999900002', '#16A34A');

INSERT INTO subscriptions (tenant_id, status, trial_ends_at) VALUES
 (1, 'trial', now() + interval '7 days'),
 (2, 'active', NULL);

-- Global super admin (tenant_id NULL). password = "Admin@123" (hash placeholder)
INSERT INTO users (tenant_id, role, full_name, phone, password_hash) VALUES
 (NULL, 'super_admin', 'Platform Owner', '918888800000', '$2b$10$REPLACE_WITH_BCRYPT');

-- Apex users (tenant 1)
INSERT INTO users (tenant_id, role, full_name, phone, password_hash) VALUES
 (1, 'coaching_admin', 'Rajesh Deshmukh', '919000000011', '$2b$10$REPLACE'),
 (1, 'teacher',        'Sunita Patil',    '919000000012', '$2b$10$REPLACE'),
 (1, 'student',        'Aarav Joshi',     '919000000013', '$2b$10$REPLACE');

-- Pioneer users (tenant 2)
INSERT INTO users (tenant_id, role, full_name, phone, password_hash) VALUES
 (2, 'coaching_admin', 'Meena Kulkarni',  '919000000021', '$2b$10$REPLACE'),
 (2, 'teacher',        'Amit Shah',       '919000000022', '$2b$10$REPLACE'),
 (2, 'student',        'Sara Khan',       '919000000023', '$2b$10$REPLACE');

-- ISOLATION PROOF: Aarav (tenant 1) can NEVER see Sara (tenant 2) because every
-- query is `WHERE tenant_id = 1`. Same phone can exist under both tenants.
```

### 4.5 Row-Level Isolation Strategy (application-level)
- **Never** trust `tenant_id` from the request. Read it from `req.user.tenantId` (from JWT).
- Provide a helper so no query forgets the filter:
```js
// src/db/scoped.js
async function scopedQuery(tenantId, text, params = []) {
  // Enforce that tenant-scoped tables include the filter by convention.
  return pool.query(text, params); // callers MUST include WHERE tenant_id = $1
}
// Better: a repository per table, e.g. studentRepo.findAll(tenantId)
```
- Add integration tests: log in as tenant 1, attempt to fetch tenant 2's `student_id` → must return 404, never data.

---

## 5. Backend Design (Node.js + Express)

### 5.1 Folder Structure
```
backend/
├── src/
│   ├── config/
│   │   ├── db.js              # pg Pool
│   │   └── env.js             # loads & validates .env
│   ├── middleware/
│   │   ├── authMiddleware.js  # verify JWT → req.user
│   │   ├── roleGuard.js       # roleGuard('coaching_admin', ...)
│   │   ├── subscriptionGuard.js
│   │   ├── errorHandler.js
│   │   └── rateLimiter.js
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── superadmin.routes.js
│   │   ├── admin.routes.js    # coaching admin
│   │   ├── teacher.routes.js
│   │   ├── student.routes.js
│   │   └── payment.routes.js
│   ├── controllers/           # one per route file
│   ├── services/              # business logic (fees, whatsapp, razorpay, subscription)
│   │   ├── whatsapp.service.js
│   │   ├── razorpay.service.js
│   │   └── subscription.service.js
│   ├── db/
│   │   ├── repositories/      # studentRepo, batchRepo... (auto tenant scope)
│   │   └── scoped.js
│   ├── validators/            # zod/joi schemas per endpoint
│   ├── utils/                 # jwt.js, receipt.js, logger.js
│   ├── jobs/                  # cron: trial-expiry, billing reminders
│   └── app.js                 # express bootstrap
├── migrations/
│   ├── 0001_init.sql
│   └── ...
├── seed.sql
├── ecosystem.config.cjs       # PM2
├── .env
└── package.json
```

### 5.2 Key Middleware
```js
// authMiddleware.js
export function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ code: 'NO_TOKEN' });
  try {
    const payload = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    req.user = { userId: payload.sub, tenantId: payload.tenantId, role: payload.role };
    next();
  } catch { return res.status(401).json({ code: 'INVALID_TOKEN' }); }
}

// roleGuard.js
export const roleGuard = (...roles) => (req, res, next) =>
  roles.includes(req.user.role) ? next() : res.status(403).json({ code: 'FORBIDDEN' });

// subscriptionGuard.js — only on coaching_admin write routes
export async function subscriptionGuard(req, res, next) {
  const sub = await subscriptionService.get(req.user.tenantId);
  const now = new Date();
  if (sub.status === 'trial' && now > new Date(sub.trial_ends_at))
    return res.status(403).json({ code: 'TRIAL_EXPIRED' });
  if (['past_due', 'suspended'].includes(sub.status))
    return res.status(403).json({ code: 'PAYMENT_REQUIRED' });
  next();
}
```

### 5.3 Auth Strategy
- Passwords hashed with **bcrypt** (cost 10).
- **JWT access token** (15 min expiry) + **refresh token** (30 days, stored client-side in secure storage).
- Access token payload: `{ sub: userId, tenantId, role, iat, exp }`.
- Refresh flow: `POST /auth/refresh` with refresh token → new access token.

### 5.4 REST API Specification

**Base URL:** `https://api.campusweb.co.in/api/v1`
All protected routes require `Authorization: Bearer <accessToken>`.

#### 5.4.1 Auth Module
| Method | Path | Role | Request Body | Success Response | Notes |
|---|---|---|---|---|---|
| POST | `/auth/register-tenant` | super_admin | `{name, slug, city, contactPhone, primaryColor, adminName, adminPhone, adminPassword}` | `{tenant, adminUser}` | Creates tenant + subscription(trial) + coaching_admin |
| POST | `/auth/login` | public | `{slug, phone, password}` | `{accessToken, refreshToken, user:{id,role,tenantId}, branding:{logoUrl,primaryColor,name}}` | slug optional for super_admin |
| POST | `/auth/refresh` | public | `{refreshToken}` | `{accessToken}` | |
| GET | `/auth/me` | any | — | `{user, branding}` | |
| POST | `/auth/logout` | any | — | `{success:true}` | client discards tokens |

**Login response example:**
```json
{ "accessToken":"eyJ...", "refreshToken":"eyJ...",
  "user":{"id":13,"role":"student","tenantId":1,"fullName":"Aarav Joshi"},
  "branding":{"name":"Apex Academy","logoUrl":"https://.../apex.png","primaryColor":"#2563EB"} }
```

#### 5.4.2 Super Admin Module (`roleGuard('super_admin')`)
| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| GET | `/superadmin/tenants` | — | `[{id,name,city,status,studentCount}]` | |
| POST | `/superadmin/tenants` | (same as register-tenant) | `{tenant}` | |
| PATCH | `/superadmin/tenants/:id/suspend` | `{isActive}` | `{tenant}` | Global on/off |
| GET | `/superadmin/subscriptions` | — | `[{tenantId,name,status,trialEndsAt,nextBillingDate}]` | |
| GET | `/superadmin/subscriptions/expiring` | `?days=3` | `[...]` | trials ending soon |
| GET | `/superadmin/analytics` | — | `{totalTenants, activeTenants, totalStudents, mrr}` | Global KPIs |

#### 5.4.3 Coaching Admin Module (`roleGuard('coaching_admin')`, writes use `subscriptionGuard`)
| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| GET | `/admin/dashboard` | — | `{studentCount, teacherCount, feesCollected, feesPending}` | |
| GET | `/admin/teachers` | — | `[{id,fullName,phone}]` | |
| POST | `/admin/teachers` | `{fullName,phone,password,email}` | `{teacher}` | write-guarded |
| DELETE | `/admin/teachers/:id` | — | `{success}` | |
| GET | `/admin/students` | `?batchId=` | `[{id,fullName,rollNo,grade,parentPhone}]` | |
| POST | `/admin/students` | `{fullName,phone,password,parentName,parentPhone,grade,rollNo,batchId}` | `{student}` | creates user+student+enrollment |
| DELETE | `/admin/students/:id` | — | `{success}` | |
| GET | `/admin/batches` | — | `[{id,name,grade,studentCount}]` | |
| POST | `/admin/batches` | `{name,grade}` | `{batch}` | |
| GET | `/admin/timetable` | `?day=` | `[{id,batch,subject,teacher,startTime,endTime}]` | |
| POST | `/admin/timetable` | `{batchId,subjectId,teacherId,dayOfWeek,startTime,endTime}` | `{entry}` | teacher allocation |
| GET | `/admin/fees` | `?status=pending` | `[{studentId,name,total,paid,pending}]` | |
| POST | `/admin/fees/structures` | `{batchId,title,amount,dueDate}` | `{feeStructure}` | |
| POST | `/admin/fees/payments` | `{studentId,feeStructureId,amountPaid,method}` | `{payment, receiptNo}` | |
| POST | `/admin/fees/:studentId/remind` | — | `{waUrl}` | returns wa.me reminder link |
| GET | `/admin/reports/performance` | `?batchId=` | `{avgAttendance, avgMarks, topStudents[]}` | |
| GET | `/admin/branding` | — | `{logoUrl,primaryColor,name}` | |
| PUT | `/admin/branding` | `{logoUrl,primaryColor}` | `{branding}` | |

#### 5.4.4 Teacher Module (`roleGuard('teacher')`)
| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| GET | `/teacher/schedule/today` | — | `[{timetableId,batch,subject,startTime,endTime}]` | "Aaj aapki 3 classes hain" |
| GET | `/teacher/batches/:batchId/students` | — | `[{studentId,name,rollNo}]` | for attendance |
| POST | `/teacher/attendance` | `{batchId,timetableId,date,records:[{studentId,status}]}` | `{saved, absentReminders:[waUrl]}` | bulk; auto WA links for absentees |
| GET | `/teacher/content` | — | `[{id,title,youtubeUrl,batch}]` | |
| POST | `/teacher/content` | `{title,youtubeUrl,batchId,subjectId}` | `{content}` | VOD |
| POST | `/teacher/live-classes` | `{title,meetUrl,batchId,scheduledAt}` | `{liveClass}` | |
| GET | `/teacher/doubt-link/:studentId` | `?text=` | `{waUrl}` | wa.me to student |

#### 5.4.5 Student/Parent Module (`roleGuard('student')`)
| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| GET | `/student/dashboard` | — | `{nextLiveClass, pendingFees, recentVideos[]}` | |
| GET | `/student/videos` | `?subjectId=` | `[{id,title,youtubeUrl,subject}]` | |
| GET | `/student/videos/:id` | — | `{id,title,youtubeUrl}` | |
| GET | `/student/live/today` | — | `[{id,title,meetUrl,scheduledAt,joinable:bool}]` | joinable = within window |
| GET | `/student/fees` | — | `{total,paid,pending,payments:[{receiptNo,amount,paidOn}]}` | |
| GET | `/student/fees/receipt/:paymentId` | — | PDF/JSON | receipt |
| GET | `/student/ask-doubt` | `?teacherId=&chapter=` | `{waUrl}` | pre-filled wa.me to teacher |

#### 5.4.6 Payment Module (Razorpay)
| Method | Path | Role | Request | Response | Notes |
|---|---|---|---|---|---|
| POST | `/payments/create-order` | coaching_admin | `{}` | `{orderId, amount, currency, keyId}` | amount from subscription |
| POST | `/payments/verify` | coaching_admin | `{orderId,paymentId,signature}` | `{status:'active', nextBillingDate}` | verify signature server-side |
| GET | `/payments/subscription` | coaching_admin | — | `{status,trialEndsAt,nextBillingDate,amount}` | |

### 5.5 WhatsApp (`wa.me`) Deep Link Construction
No chat server. The backend just builds a URL the client opens.
```js
// whatsapp.service.js
export function buildWaUrl(phone, message) {
  // phone must be full intl format WITHOUT '+': e.g. 919000000013
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`;
}
```
**Fee reminder example:**
```
https://wa.me/919000000013?text=Namaste%20Rajesh%20ji%2C%20Aarav%20ki%20Term%201%20fees%20%E2%82%B95000%20pending%20hai.%20Kripya%20jaldi%20jama%20karein.%20-%20Apex%20Academy
```
**Student doubt example (→ teacher):**
```
https://wa.me/919000000012?text=Sir%2C%20mujhe%20Physics%20Chapter%203%20mein%20doubt%20hai.%20-%20Aarav%20(Apex%20Academy)
```

### 5.6 Razorpay Flow
```
1. Client: POST /payments/create-order
2. Server: razorpay.orders.create({amount: sub.amount*100, currency:'INR'}) → returns order_id + keyId
3. Client: opens Razorpay checkout with order_id → user pays
4. Client: POST /payments/verify {orderId, paymentId, signature}
5. Server: expected = HMAC_SHA256(orderId + '|' + paymentId, RAZORPAY_SECRET)
          if (expected === signature) →
             subscription.status='active';
             subscription.next_billing_date = now()+30d;  → panel unlocks
6. Cron job: 2 days after next_billing_date & unpaid → status='past_due'
```

---

## 6. Flutter App Architecture

### 6.1 Chosen Stack (decisions made — do not substitute)
| Concern | Choice | Reason |
|---|---|---|
| State management | **Riverpod** (`flutter_riverpod`) | Compile-safe, testable, great for role-based providers |
| HTTP client | **Dio** | Interceptors for auth + refresh |
| Routing | **go_router** | Declarative, supports role-based redirects |
| Secure token storage | **flutter_secure_storage** | Encrypted access/refresh tokens |
| Local cache/prefs | **shared_preferences** | Cache branding, last role |
| YouTube playback | **youtube_player_flutter** | Distraction-free in-app player |
| Open WhatsApp/Meet | **url_launcher** | Launch wa.me & Meet links |
| Payments | **razorpay_flutter** | Checkout inside app |

### 6.2 Folder Structure (feature-first)
```
lib/
├── main.dart
├── core/
│   ├── theme/            # app_theme.dart, colors.dart, typography.dart
│   ├── network/
│   │   ├── dio_client.dart      # base Dio + interceptors (auth, refresh, error)
│   │   └── api_endpoints.dart   # all path constants
│   ├── router/
│   │   └── app_router.dart      # go_router + role redirect
│   ├── storage/
│   │   └── secure_storage.dart  # token + branding cache
│   └── constants/
├── models/               # user.dart, tenant_branding.dart, batch.dart, ...
├── features/
│   ├── auth/
│   │   ├── data/ (auth_repository.dart)
│   │   ├── domain/
│   │   └── presentation/ (splash_screen.dart, login_screen.dart, auth_provider.dart)
│   ├── super_admin/
│   │   ├── data/  domain/  presentation/ (dashboard, tenants, subscriptions)
│   ├── coaching_admin/
│   │   └── presentation/ (dashboard, teachers, students, batches, timetable, fees, reports, branding)
│   ├── teacher/
│   │   └── presentation/ (schedule, attendance, content, live_class)
│   └── student/
│       └── presentation/ (dashboard, classroom, video_player, live, fees, ask_doubt)
└── shared/
    └── widgets/          # app_scaffold, loading_view, empty_view, error_view, primary_button
```

### 6.3 Role-Based Routing (go_router)
After login, the JWT's `role` decides which shell loads. Splash validates token first.
```dart
// app_router.dart (pseudocode)
final router = GoRouter(
  initialLocation: '/splash',
  redirect: (ctx, state) {
    final auth = ref.read(authProvider);
    final loggingIn = state.matchedLocation == '/login';
    if (auth.status == AuthStatus.unknown) return '/splash';
    if (auth.status == AuthStatus.unauthenticated) return loggingIn ? null : '/login';
    // authenticated → send to role home
    switch (auth.user!.role) {
      case 'super_admin':    return state.matchedLocation.startsWith('/super') ? null : '/super/dashboard';
      case 'coaching_admin': return state.matchedLocation.startsWith('/admin') ? null : '/admin/dashboard';
      case 'teacher':        return state.matchedLocation.startsWith('/teacher') ? null : '/teacher/schedule';
      case 'student':        return state.matchedLocation.startsWith('/student') ? null : '/student/home';
    }
    return null;
  },
  routes: [ /* ShellRoutes per role with nested screens */ ],
);
```

### 6.4 Dynamic Branding
On login the API returns `branding {logoUrl, primaryColor, name}`. Cache it and inject into ThemeData:
```dart
ThemeData buildTheme(String primaryHex) {
  final primary = Color(int.parse('FF${primaryHex.replaceAll('#','')}', radix: 16));
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    useMaterial3: true,
  );
}
// Apex sees blue #2563EB, Pioneer sees green #16A34A — same app binary.
```

### 6.5 Dio Interceptor (auth + auto-refresh)
```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (o, h) async {
    final token = await storage.readAccessToken();
    if (token != null) o.headers['Authorization'] = 'Bearer $token';
    h.next(o);
  },
  onError: (e, h) async {
    if (e.response?.statusCode == 401) {
      final ok = await authRepo.refresh(); // POST /auth/refresh
      if (ok) return h.resolve(await dio.fetch(e.requestOptions)); // retry
    }
    h.next(e);
  },
));
```

### 6.6 Integrations Cheatsheet
```dart
// Open WhatsApp doubt / reminder
launchUrl(Uri.parse(waUrl), mode: LaunchMode.externalApplication);
// Open Google Meet live class
launchUrl(Uri.parse(meetUrl), mode: LaunchMode.externalApplication);
// Play unlisted YouTube in-app
YoutubePlayer(controller: YoutubePlayerController(
  initialVideoId: YoutubePlayer.convertUrlToId(youtubeUrl)!,
  flags: const YoutubePlayerFlags(autoPlay: false)));
```

---

## 7. Screen-by-Screen UI & Navigation

### 7.1 Design Tokens (default; institutes override `primary`)
| Token | Value | Use |
|---|---|---|
| primary | `#2563EB` (institute-overridable) | Buttons, active nav, links |
| secondary | `#0EA5E9` | Accents |
| success | `#16A34A` | Paid, present |
| warning | `#F59E0B` | Due soon |
| error | `#DC2626` | Absent, overdue |
| neutral-900 | `#111827` | Headings |
| neutral-600 | `#4B5563` | Body |
| neutral-100 | `#F3F4F6` | Backgrounds |
| surface | `#FFFFFF` | Cards |

**Typography:** Inter/Roboto. H1 24/700, H2 20/600, Title 16/600, Body 14/400, Caption 12/400. Card radius 16, button radius 12, spacing scale 4/8/12/16/24.

**Common components (in `shared/widgets`):** `AppScaffold` (app bar shows tenant logo + name), `LoadingView` (shimmer), `EmptyView` (icon + message), `ErrorView` (retry button), `PrimaryButton`, and every list uses **pull-to-refresh** (`RefreshIndicator`).

### 7.2 Auth Flow (shared)
| Screen | Route | Purpose | Components | API |
|---|---|---|---|---|
| Splash | `/splash` | Decide route | Logo, spinner; reads stored token → `GET /auth/me` → route by role; else → login | `/auth/me` |
| Login | `/login` | Sign in | Institute slug field, phone, password, "Login" button, error text | `/auth/login` |

**Splash logic:** read access token → if present call `/auth/me`; on success cache branding + route to role home; on 401 try refresh; if all fail → `/login`.

### 7.3 🎓 Student / Parent
**Bottom Navigation (5 tabs) + floating "Ask Doubt" FAB:**
`Home` (home icon) · `Classroom` (play-circle) · `Live` (video) · `Fees` (receipt) · `Profile` (person). FAB (chat icon) visible on Home & Classroom.

| Screen | Route | Purpose | Key Components | API |
|---|---|---|---|---|
| Home/Dashboard | `/student/home` | Overview | Greeting + logo, "Next Live Class" card w/ countdown, "Pending Fees" alert card, recent videos horizontal list | `/student/dashboard` |
| Classroom (Videos) | `/student/classroom` | Browse VOD | Subject filter chips, video cards (thumbnail, title, subject), tap→player | `/student/videos` |
| Video Player | `/student/video/:id` | Watch | In-app `YoutubePlayer`, title, "Ask Doubt on this" button | `/student/videos/:id` |
| Live | `/student/live` | Join class | Today's classes list; big **"Join Now"** button (enabled only within window) → `url_launcher(meetUrl)` | `/student/live/today` |
| Fees | `/student/fees` | Fee status | Total/Paid/Pending summary, payment history list, "Download Receipt" per row | `/student/fees` |
| Profile | `/student/profile` | Account | Name, batch, parent info, Logout | `/auth/me` |
| Ask Doubt (sheet) | modal | Doubt→WhatsApp | Chapter text field + teacher picker → `GET /student/ask-doubt` → open `waUrl` | `/student/ask-doubt` |

**Nav map:**
```
/student/home ──FAB──► Ask Doubt (wa.me)
   ├─ /student/classroom ─► /student/video/:id ─► Ask Doubt
   ├─ /student/live ─► (Join Now → Google Meet)
   ├─ /student/fees ─► receipt download
   └─ /student/profile ─► logout
```

### 7.4 👨‍🏫 Teacher
**Bottom Navigation (4 tabs):** `Schedule` (calendar) · `Attendance` (checklist) · `Content` (video-plus) · `Profile`.

| Screen | Route | Purpose | Key Components | API |
|---|---|---|---|---|
| Schedule | `/teacher/schedule` | Today's classes | Header "Aaj aapki N classes hain", class cards (batch, subject, time), tap→attendance | `/teacher/schedule/today` |
| Attendance | `/teacher/attendance/:batchId` | Mark attendance | Student list with Present/Absent/Late toggles, "Save" button → shows absentee WA links | `/teacher/batches/:id/students`, `/teacher/attendance` |
| Content | `/teacher/content` | Manage VOD & live | Tab: Videos (list + "Add Video" form: title, YouTube URL, batch) / Live (add Meet link + time) | `/teacher/content`, `/teacher/live-classes` |
| Add Content (sheet) | modal | Create | Title, YouTube URL, batch, subject | `POST /teacher/content` |
| Profile | `/teacher/profile` | Account | Info, Logout | `/auth/me` |

Doubt handling: on any student row, "Reply on WhatsApp" → `GET /teacher/doubt-link/:studentId` → open `waUrl` (no in-app typing).

**Nav map:**
```
/teacher/schedule ─► /teacher/attendance/:batchId (Save → absentee wa.me links)
/teacher/content ─► Add Video / Add Live Class
/teacher/profile ─► logout
```

### 7.5 🏢 Coaching Admin
**Navigation drawer (side menu):** `Dashboard` · `Teachers` · `Students` · `Batches` · `Timetable` · `Fees` · `Reports` · `Branding` · `Settings` · `Logout`. If trial expired → a persistent banner + **"Subscribe Now"** button; write actions blocked (403 handled → paywall dialog).

| Screen | Route | Purpose | Key Components | API |
|---|---|---|---|---|
| Dashboard | `/admin/dashboard` | KPIs | Cards: Students, Teachers, Fees Collected, Fees Pending; trial-countdown banner | `/admin/dashboard`, `/payments/subscription` |
| Teachers | `/admin/teachers` | Manage staff | List + FAB "Add Teacher" (name, phone, password) + delete | `/admin/teachers` |
| Students | `/admin/students` | Directory | Batch filter, list, FAB "Add Student" (full form incl. parent) | `/admin/students` |
| Batches | `/admin/batches` | Class groups | List (name, grade, count) + "Add Batch" | `/admin/batches` |
| Timetable | `/admin/timetable` | Teacher allocation | Weekly grid; "Assign" dialog (batch, subject, teacher, day, time) → shows who's available | `/admin/timetable` |
| Fees | `/admin/fees` | Collection | Pending/Paid tabs, "Record Payment" dialog, per-student **"Send WhatsApp Reminder"** → open `waUrl` | `/admin/fees`, `/admin/fees/payments`, `/admin/fees/:id/remind` |
| Reports | `/admin/reports` | Performance | Avg attendance, avg marks, top students, batch filter | `/admin/reports/performance` |
| Branding | `/admin/branding` | Customize | Logo upload, color picker, live preview | `/admin/branding` |
| Settings/Subscription | `/admin/settings` | Billing | Plan, status, next billing, **"Pay Now"** (Razorpay) | `/payments/*` |

**Nav map:**
```
Drawer
 ├─ Dashboard (trial banner → Subscribe)
 ├─ Teachers ─► add/delete
 ├─ Students ─► add/delete (filter by batch)
 ├─ Batches ─► add
 ├─ Timetable ─► assign teacher (allocation)
 ├─ Fees ─► record payment / send WA reminder
 ├─ Reports
 ├─ Branding ─► logo + color
 └─ Settings ─► Razorpay pay
```

### 7.6 👑 Super Admin
**Navigation drawer:** `Dashboard/Analytics` · `Tenants` · `Subscriptions` · `Settings` · `Logout`.

| Screen | Route | Purpose | Key Components | API |
|---|---|---|---|---|
| Analytics | `/super/dashboard` | Global KPIs | Total tenants, active, total students, MRR chart | `/superadmin/analytics` |
| Tenants | `/super/tenants` | Manage institutes | List (name, city, status, #students), FAB "Add Tenant" (full onboarding form), suspend toggle | `/superadmin/tenants` |
| Add Tenant | `/super/tenants/new` | Onboard | Institute name, slug, city, contact, color, admin name/phone/password | `POST /superadmin/tenants` |
| Subscriptions | `/super/subscriptions` | Billing overview | List w/ status chips; "Expiring in 3 days" filter | `/superadmin/subscriptions`, `/expiring` |
| Settings | `/super/settings` | Account | Logout | |

**Nav map:**
```
Drawer
 ├─ Analytics
 ├─ Tenants ─► Add Tenant / Suspend
 ├─ Subscriptions ─► expiring filter
 └─ Settings ─► logout
```

### 7.7 State Handling Rules (all screens)
- Every data screen has 4 states: **loading** (shimmer), **empty** (illustration + hint), **error** (message + Retry), **data**.
- All lists support **pull-to-refresh**.
- 401 → silent refresh; if refresh fails → force logout to `/login`.
- 403 `TRIAL_EXPIRED`/`PAYMENT_REQUIRED` → show paywall dialog with "Pay Now".

---

## 8. Marketing Website (Next.js)

### 8.1 Pages
| Page | Route | Sections |
|---|---|---|
| Home | `/` | Hero (headline + "Book a Demo" CTA), Features grid (Attendance, Fees, Live Classes, VOD, Doubt-on-WhatsApp), Pricing (₹2,500/mo flat + trial), Testimonials, FAQ, Footer |
| Book a Demo | `/demo` | Form: instituteName, ownerName, phone, city, studentCount → submit |
| Terms/Privacy | `/legal` | Static |

- **Stack:** Next.js + Tailwind CSS. Keep it lightweight and fast.

### 8.2 Lead Capture → Webhook
```
POST /api/lead  (Next.js route handler)
Body: { ownerName, instituteName, phone, city, studentCount }
→ Server forwards to n8n / WhatsApp Cloud webhook:
```
**Webhook payload sent to owner:**
```json
{
  "event": "new_demo_lead",
  "ownerName": "Rajesh Deshmukh",
  "instituteName": "Apex Academy",
  "phone": "919000000011",
  "city": "Nashik",
  "studentCount": 180,
  "receivedAt": "2026-07-07T10:30:00Z"
}
```
n8n workflow then sends YOU a WhatsApp message: *"🔥 New lead: Apex Academy (Nashik), 180 students. Call 919000000011."*

---

## 9. Phase-Wise Execution Roadmap (Gemini-Ready Prompts)

> Execute phases **in order**. Each phase has a Goal, Prerequisites, Deliverables checklist, a **copy-paste prompt for Gemini Pro**, and Acceptance Criteria. Give Gemini this whole document as context, then paste the phase prompt.

### PHASE 0 — Project Setup
- **Goal:** Create three repos/folders: `backend/`, `flutter_app/`, `marketing/`.
- **Prereqts:** Node 20, PostgreSQL 15, Flutter SDK, git.
- **Deliverables:** ☐ git repos ☐ `.env.example` ☐ empty folder structures from §5.1 & §6.2.
- **Gemini Prompt:**
  > "Create three project folders: a Node.js+Express backend, a Flutter app, and a Next.js marketing site, using the exact folder structures in Sections 5.1 and 6.2 of the Master Plan. Initialize git in each with a proper .gitignore. In the backend, set up Express with a `/health` route returning `{status:'ok'}`, a `pg` Pool from `DATABASE_URL`, and PM2 `ecosystem.config.cjs`. Create `.env.example` listing all variables from Section 10.3. Do not add business logic yet."
- **Accept:** `GET /health` returns ok; folders match spec.

### PHASE 1 — Database
- **Goal:** Create schema + seed.
- **Prereqts:** Phase 0.
- **Deliverables:** ☐ `migrations/0001_init.sql` (all tables from §4.3) ☐ `seed.sql` (§4.4) ☐ migration runner script.
- **Gemini Prompt:**
  > "Using Section 4 of the Master Plan, create `migrations/0001_init.sql` with ALL tables exactly as specified (columns, types, constraints, foreign keys, unique constraints, and the indexes at the bottom). Create `seed.sql` with the two tenants (Apex, Pioneer) and sample users. Add an npm script `db:migrate` that runs the migration and `db:seed` that runs the seed against `DATABASE_URL`. Ensure every tenant-owned table has `tenant_id INT NOT NULL REFERENCES tenants(id)`."
- **Accept:** Tables created; `SELECT * FROM tenants` returns 2 rows.

### PHASE 2 — Auth + Tenancy Core
- **Goal:** Login, JWT, middleware.
- **Deliverables:** ☐ bcrypt+JWT util ☐ `authMiddleware`, `roleGuard`, `subscriptionGuard`, `errorHandler`, `rateLimiter` ☐ `/auth/*` endpoints (§5.4.1) ☐ `scopedQuery`/repositories.
- **Gemini Prompt:**
  > "Implement the Auth module from Section 5.4.1 and the middleware from Section 5.2. Passwords use bcrypt (cost 10). Issue JWT access (15m) + refresh (30d) tokens with payload `{sub,tenantId,role}`. `authMiddleware` attaches `req.user`. Implement `roleGuard(...roles)` and `subscriptionGuard` (blocks writes when trial expired / past_due). Implement `/auth/login` (verify slug+phone+password, return tokens + branding), `/auth/refresh`, `/auth/me`, `/auth/logout`. Add a repository helper that forces `WHERE tenant_id=$1` on all tenant tables. Write an integration test proving a tenant-1 token cannot read tenant-2 data."
- **Accept:** Login returns tokens+branding; cross-tenant access returns 404; expired-trial write returns 403 `TRIAL_EXPIRED`.

### PHASE 3 — Super Admin API
- **Deliverables:** ☐ all `/superadmin/*` endpoints (§5.4.2) ☐ `register-tenant` creates tenant + subscription(trial +7d) + coaching_admin.
- **Gemini Prompt:**
  > "Implement the Super Admin module (Section 5.4.2) and `/auth/register-tenant`. Creating a tenant must also create its subscription with status='trial' and trial_ends_at=now()+7 days, and a coaching_admin user (bcrypt password). Implement list/create/suspend tenants, list subscriptions, expiring filter, and global analytics (totalTenants, activeTenants, totalStudents, mrr). Guard all routes with `roleGuard('super_admin')`."
- **Accept:** Creating a tenant returns tenant+admin; analytics reflects seed data.

### PHASE 4 — Coaching Admin API
- **Deliverables:** ☐ all `/admin/*` endpoints (§5.4.3) ☐ WhatsApp reminder service ☐ receipt generation.
- **Gemini Prompt:**
  > "Implement the Coaching Admin module (Section 5.4.3). All routes use `roleGuard('coaching_admin')`; all write routes (POST/PUT/DELETE) also use `subscriptionGuard`. Implement teachers/students/batches CRUD (creating a student creates a users row role='student' + students row + batch_enrollment), timetable teacher-allocation, fee structures + record payment (generate unique receipt_no), the WhatsApp reminder endpoint returning a `wa.me` URL built via `buildWaUrl` (Section 5.5), performance reports, and branding GET/PUT. Every query must be scoped by `req.user.tenantId`."
- **Accept:** Add student→appears in list; record payment→receipt returned; remind→valid wa.me URL.

### PHASE 5 — Teacher API
- **Deliverables:** ☐ all `/teacher/*` endpoints (§5.4.4).
- **Gemini Prompt:**
  > "Implement the Teacher module (Section 5.4.4) guarded by `roleGuard('teacher')`. today's schedule from timetable (day_of_week=today), fetch batch students, bulk attendance save (upsert on the unique key) that also returns `wa.me` links for every absent student's parent_phone, create/list VOD content, add live class Meet link, and doubt-link generator. Scope everything by tenantId."
- **Accept:** Bulk attendance saves; absentees produce parent wa.me links.

### PHASE 6 — Student/Parent API
- **Deliverables:** ☐ all `/student/*` endpoints (§5.4.5).
- **Gemini Prompt:**
  > "Implement the Student module (Section 5.4.5) guarded by `roleGuard('student')`. dashboard (next live class + pending fees + recent videos), list/detail videos (only for the student's enrolled batches), today's live classes with `joinable` flag (true if now within [scheduled_at-10m, scheduled_at+60m]), fee status + payment history, receipt fetch, and ask-doubt returning a pre-filled `wa.me` URL to the chosen teacher (Section 5.5). Scope by tenantId and the student's enrollments."
- **Accept:** Student sees only own-batch videos; ask-doubt returns correct teacher wa.me URL.

### PHASE 7 — Payments (Razorpay)
- **Deliverables:** ☐ `/payments/*` (§5.4.6) ☐ signature verification ☐ trial-expiry & billing cron.
- **Gemini Prompt:**
  > "Implement the Payment module (Section 5.4.6 and flow 5.6) using the `razorpay` SDK. create-order uses subscription.amount×100 INR; verify recomputes HMAC_SHA256(orderId|paymentId, RAZORPAY_SECRET) and on match sets subscription status='active', next_billing_date=now()+30d. Add a daily cron job (`node-cron`) that moves 'active' subscriptions 2 days past next_billing_date to 'past_due', and flags trials expiring in ≤3 days for the super admin. Never trust client-sent amounts."
- **Accept:** Valid signature unlocks panel; invalid signature returns 400; cron flips overdue subs.

### PHASE 8 — Flutter Shell + Auth
- **Deliverables:** ☐ Riverpod/Dio/go_router setup ☐ Splash + Login ☐ role redirect ☐ dynamic branding ☐ token interceptor.
- **Gemini Prompt:**
  > "Build the Flutter foundation from Section 6. Add dependencies: flutter_riverpod, dio, go_router, flutter_secure_storage, shared_preferences, youtube_player_flutter, url_launcher, razorpay_flutter. Implement `dio_client.dart` with the auth+refresh interceptor (6.5), `secure_storage.dart`, `app_router.dart` with the role-based redirect (6.3), Splash (validate token via /auth/me), and Login (slug+phone+password). On login, cache branding and build ThemeData from primaryColor (6.4). Create the four empty role shells with their bottom-nav/drawer from Section 7."
- **Accept:** Login as each seed role routes to the correct shell; Apex shows blue, Pioneer green.

### PHASE 9 — Flutter Role Screens
- **Deliverables:** ☐ every screen in §7.3–7.6 wired to APIs ☐ loading/empty/error/refresh states ☐ wa.me, Meet, YouTube, Razorpay integrations.
- **Gemini Prompt:**
  > "Implement all screens in Sections 7.3–7.6 for the four roles, each wired to its listed API endpoint, with the 4 UI states and pull-to-refresh from Section 7.7. Student: home, classroom, in-app YouTube player, live (Join Now→url_launcher), fees, profile, and Ask-Doubt FAB (→ wa.me). Teacher: schedule, attendance (toggles + save → open absentee wa.me), content add, profile. Coaching Admin: dashboard with trial banner, teachers, students, batches, timetable allocation, fees (record + WhatsApp reminder), reports, branding, settings with Razorpay Pay Now. Super Admin: analytics, tenants (+add/suspend), subscriptions. Handle 403 TRIAL_EXPIRED/PAYMENT_REQUIRED with a paywall dialog."
- **Accept:** Each role can complete its core journey end-to-end against the live backend.

### PHASE 10 — Marketing Site
- **Deliverables:** ☐ Next.js home + demo form ☐ `/api/lead` → webhook.
- **Gemini Prompt:**
  > "Build the Next.js marketing site from Section 8 with Tailwind: home (hero, features, pricing ₹2,500/mo + 1-week trial, testimonials, FAQ) and a Book-a-Demo form. Implement `/api/lead` that validates input and POSTs the payload in Section 8.2 to `N8N_WEBHOOK_URL` from env. Show a success toast on submit."
- **Accept:** Submitting the form fires the webhook with the correct payload.

### PHASE 11 — Deployment
- **Deliverables:** ☐ droplet + Postgres ☐ PM2 + Nginx + SSL ☐ migrations run ☐ Flutter release build ☐ marketing deployed.
- **Gemini Prompt:**
  > "Produce the exact shell commands to deploy per Section 10: provision an Ubuntu DigitalOcean droplet, install Node 20 + PostgreSQL, create the DB, run migrations+seed, start the backend with PM2, configure Nginx as reverse proxy on the API domain with Certbot SSL, and set up a nightly `pg_dump` cron. Then give the commands to build a signed Flutter release APK and to deploy the Next.js site to Vercel."
- **Accept:** Public HTTPS API responds; app connects; marketing site live.

---

## 10. Deployment & DevOps

### 10.1 DigitalOcean Droplet
```bash
# Ubuntu 22.04, 2GB RAM
sudo apt update && sudo apt install -y nginx postgresql certbot python3-certbot-nginx
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs
sudo npm i -g pm2
# Postgres
sudo -u postgres psql -c "CREATE DATABASE campus;"
sudo -u postgres psql -c "CREATE USER campus WITH PASSWORD 'STRONG_PW'; GRANT ALL ON DATABASE campus TO campus;"
```

### 10.2 PM2 (`ecosystem.config.cjs`)
```js
module.exports = { apps: [{ name:'campus-api', script:'src/app.js',
  instances:1, exec_mode:'fork', env:{ NODE_ENV:'production', PORT:4000 } }] };
```
```bash
cd backend && npm run db:migrate && npm run db:seed
pm2 start ecosystem.config.cjs && pm2 save && pm2 startup
```

### 10.3 Environment Variables (`.env`)
```
DATABASE_URL=postgres://campus:STRONG_PW@localhost:5432/campus
JWT_ACCESS_SECRET=<64-char-random>
JWT_REFRESH_SECRET=<64-char-random>
ACCESS_TOKEN_TTL=15m
REFRESH_TOKEN_TTL=30d
RAZORPAY_KEY_ID=rzp_live_xxx
RAZORPAY_SECRET=xxx
N8N_WEBHOOK_URL=https://n8n.yourhost.com/webhook/lead
PORT=4000
```

### 10.4 Nginx + SSL
```nginx
server {
  server_name api.campusweb.co.in;
  location / { proxy_pass http://localhost:4000; proxy_set_header Host $host; }
}
```
```bash
sudo certbot --nginx -d api.campusweb.co.in
```

### 10.5 Backups (nightly `pg_dump`)
```bash
# crontab -e
0 2 * * * pg_dump -U campus campus | gzip > /root/backups/campus_$(date +\%F).sql.gz
```

### 10.6 Flutter Release
```bash
cd flutter_app
flutter build apk --release            # Android
flutter build appbundle --release      # Play Store
flutter build ipa --release            # iOS (on macOS)
```

### 10.7 Marketing (Vercel)
```bash
cd marketing && vercel --prod          # set N8N_WEBHOOK_URL in Vercel env
```

---

## 11. Security & Best Practices Checklist
- ☑ **Tenant isolation:** `tenant_id` always from JWT, never from body; repository enforces the filter.
- ☑ **Passwords:** bcrypt (cost 10), never stored/returned in plaintext.
- ☑ **JWT:** short access (15m) + refresh; secrets ≥64 chars; verify on every request.
- ☑ **Input validation:** zod/joi on every endpoint; reject unknown fields.
- ☑ **SQL injection:** parameterized queries only (`$1,$2`); never string-concat SQL.
- ☑ **Rate limiting:** `express-rate-limit` on `/auth/*` (e.g. 10/min) and global.
- ☑ **HTTPS everywhere:** enforced via Nginx + Certbot.
- ☑ **Secrets:** only in `.env` (git-ignored); never in client code.
- ☑ **Razorpay:** verify HMAC signature server-side; never trust client amount.
- ☑ **Least privilege:** `roleGuard` on every route; students can't hit admin routes.
- ☑ **CORS:** restrict to app + marketing origins.
- ☑ **Audit log:** record sensitive admin actions in `audit_log`.

---

## 12. Future Roadmap (Not Yet Implemented)
1. **Push notifications** (FCM) — class reminders, fee due alerts.
2. **In-app UPI payment** for student fees (currently admin records manually).
3. **Advanced analytics** — attendance trends, revenue charts per institute.
4. **Offline mode** — cache videos list & schedule (Hive).
5. **Report card PDF** generation & share.
6. **Multi-language** UI (Hindi/Marathi/English).
7. **CSV bulk import** of students/teachers during onboarding.
8. **Auto-recurring billing** via Razorpay Subscriptions API.

---

### ✅ How to Use This Document with Gemini Pro
1. Paste this entire document as context/system input.
2. Execute **Phase 0 → Phase 11 in order**, one phase per prompt.
3. After each phase, verify the **Acceptance Criteria** before moving on.
4. Keep the schema (§4) and API spec (§5.4) as the single source of truth — never let generated code deviate from them.

*End of Master Development Plan.*
