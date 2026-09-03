-- ============================================================
-- Multi-Tenant Campus — Initial Schema (0001)
-- Golden rule: every tenant-owned table has tenant_id NOT NULL
-- REFERENCES tenants(id), and every query filters by it.
-- ============================================================

-- ---------- TENANTS ----------
CREATE TABLE IF NOT EXISTS tenants (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(150) NOT NULL,
  slug          VARCHAR(60) UNIQUE NOT NULL,
  logo_url      TEXT,
  primary_color VARCHAR(7) DEFAULT '#2563EB',
  city          VARCHAR(80),
  contact_phone VARCHAR(15),
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- SUBSCRIPTIONS ----------
CREATE TABLE IF NOT EXISTS subscriptions (
  id                SERIAL PRIMARY KEY,
  tenant_id         INT UNIQUE NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  plan              VARCHAR(20) NOT NULL DEFAULT 'flat',       -- flat | per_student
  amount            INT NOT NULL DEFAULT 2500,
  status            VARCHAR(20) NOT NULL DEFAULT 'trial',      -- trial|active|past_due|suspended
  trial_ends_at     TIMESTAMPTZ,
  next_billing_date TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- USERS ----------
CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  tenant_id     INT REFERENCES tenants(id) ON DELETE CASCADE,  -- NULL only for super_admin
  role          VARCHAR(20) NOT NULL,                          -- super_admin|coaching_admin|teacher|student
  full_name     VARCHAR(120) NOT NULL,
  phone         VARCHAR(15) NOT NULL,
  email         VARCHAR(120),
  password_hash TEXT NOT NULL,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, phone)
);
-- Super admins have tenant_id NULL; enforce global phone uniqueness for them.
CREATE UNIQUE INDEX IF NOT EXISTS uniq_superadmin_phone
  ON users (phone) WHERE tenant_id IS NULL;

-- ---------- STUDENTS ----------
CREATE TABLE IF NOT EXISTS students (
  id           SERIAL PRIMARY KEY,
  tenant_id    INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id      INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  roll_no      VARCHAR(30),
  parent_name  VARCHAR(120),
  parent_phone VARCHAR(15) NOT NULL,
  grade        VARCHAR(30),
  joined_at    DATE DEFAULT now()
);

-- ---------- SUBJECTS ----------
CREATE TABLE IF NOT EXISTS subjects (
  id        SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name      VARCHAR(80) NOT NULL
);

-- ---------- BATCHES ----------
CREATE TABLE IF NOT EXISTS batches (
  id         SERIAL PRIMARY KEY,
  tenant_id  INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name       VARCHAR(80) NOT NULL,
  grade      VARCHAR(30),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------- BATCH ENROLLMENTS ----------
CREATE TABLE IF NOT EXISTS batch_enrollments (
  id         SERIAL PRIMARY KEY,
  tenant_id  INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id   INT NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
  student_id INT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE (batch_id, student_id)
);

-- ---------- TIMETABLE (teacher allocation) ----------
CREATE TABLE IF NOT EXISTS timetable (
  id          SERIAL PRIMARY KEY,
  tenant_id   INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id    INT NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
  subject_id  INT REFERENCES subjects(id),
  teacher_id  INT NOT NULL REFERENCES users(id),
  day_of_week SMALLINT NOT NULL,     -- 0=Sun .. 6=Sat
  start_time  TIME NOT NULL,
  end_time    TIME NOT NULL
);

-- ---------- ATTENDANCE ----------
CREATE TABLE IF NOT EXISTS attendance (
  id           SERIAL PRIMARY KEY,
  tenant_id    INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  timetable_id INT REFERENCES timetable(id),
  batch_id     INT NOT NULL REFERENCES batches(id),
  student_id   INT NOT NULL REFERENCES students(id),
  date         DATE NOT NULL,
  status       VARCHAR(10) NOT NULL DEFAULT 'present', -- present|absent|late
  marked_by    INT REFERENCES users(id),
  UNIQUE (student_id, date, batch_id)
);

-- ---------- FEE STRUCTURES ----------
CREATE TABLE IF NOT EXISTS fee_structures (
  id        SERIAL PRIMARY KEY,
  tenant_id INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id  INT REFERENCES batches(id),
  title     VARCHAR(100) NOT NULL,
  amount    INT NOT NULL,
  due_date  DATE
);

-- ---------- FEE PAYMENTS ----------
CREATE TABLE IF NOT EXISTS fee_payments (
  id               SERIAL PRIMARY KEY,
  tenant_id        INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  student_id       INT NOT NULL REFERENCES students(id),
  fee_structure_id INT REFERENCES fee_structures(id),
  amount_paid      INT NOT NULL,
  paid_on          DATE NOT NULL DEFAULT now(),
  method           VARCHAR(20) DEFAULT 'cash',  -- cash|upi|card
  receipt_no       VARCHAR(40) UNIQUE
);

-- ---------- CONTENT (VOD / unlisted YouTube) ----------
CREATE TABLE IF NOT EXISTS content (
  id          SERIAL PRIMARY KEY,
  tenant_id   INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id    INT REFERENCES batches(id),
  subject_id  INT REFERENCES subjects(id),
  title       VARCHAR(150) NOT NULL,
  youtube_url TEXT NOT NULL,
  created_by  INT REFERENCES users(id),
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- ---------- LIVE CLASSES ----------
CREATE TABLE IF NOT EXISTS live_classes (
  id           SERIAL PRIMARY KEY,
  tenant_id    INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id     INT NOT NULL REFERENCES batches(id),
  title        VARCHAR(150) NOT NULL,
  meet_url     TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  teacher_id   INT REFERENCES users(id)
);

-- ---------- TESTS & RESULTS ----------
CREATE TABLE IF NOT EXISTS tests (
  id         SERIAL PRIMARY KEY,
  tenant_id  INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  batch_id   INT REFERENCES batches(id),
  subject_id INT REFERENCES subjects(id),
  title      VARCHAR(150) NOT NULL,
  max_marks  INT NOT NULL,
  test_date  DATE
);

CREATE TABLE IF NOT EXISTS test_results (
  id             SERIAL PRIMARY KEY,
  tenant_id      INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  test_id        INT NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
  student_id     INT NOT NULL REFERENCES students(id),
  marks_obtained INT NOT NULL,
  UNIQUE (test_id, student_id)
);

-- ---------- NOTIFICATIONS ----------
CREATE TABLE IF NOT EXISTS notifications (
  id         SERIAL PRIMARY KEY,
  tenant_id  INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id    INT REFERENCES users(id),
  title      VARCHAR(150) NOT NULL,
  body       TEXT,
  is_read    BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------- LEADS (demo bookings from marketing site) ----------
-- Global (no tenant) — these are prospective customers, not tenant data.
CREATE TABLE IF NOT EXISTS leads (
  id             SERIAL PRIMARY KEY,
  owner_name     VARCHAR(120) NOT NULL,
  institute_name VARCHAR(150) NOT NULL,
  phone          VARCHAR(15) NOT NULL,
  city           VARCHAR(80),
  student_count  INT,
  message        TEXT,
  source         VARCHAR(40) DEFAULT 'marketing_site',
  status         VARCHAR(20) NOT NULL DEFAULT 'new',  -- new|contacted|converted|lost
  is_read        BOOLEAN NOT NULL DEFAULT false,
  notified       BOOLEAN NOT NULL DEFAULT false,       -- email/telegram fired?
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- AUDIT LOG ----------
CREATE TABLE IF NOT EXISTS audit_log (
  id            SERIAL PRIMARY KEY,
  tenant_id     INT REFERENCES tenants(id),
  actor_user_id INT REFERENCES users(id),
  action        VARCHAR(80),
  entity        VARCHAR(60),
  entity_id     INT,
  meta          JSONB,
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- INDEXES on tenant_id + common lookups
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_users_tenant           ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_students_tenant         ON students(tenant_id);
CREATE INDEX IF NOT EXISTS idx_batches_tenant          ON batches(tenant_id);
CREATE INDEX IF NOT EXISTS idx_enroll_tenant_batch     ON batch_enrollments(tenant_id, batch_id);
CREATE INDEX IF NOT EXISTS idx_timetable_tenant_day    ON timetable(tenant_id, day_of_week);
CREATE INDEX IF NOT EXISTS idx_attendance_tenant_date  ON attendance(tenant_id, date);
CREATE INDEX IF NOT EXISTS idx_fee_pay_tenant_student  ON fee_payments(tenant_id, student_id);
CREATE INDEX IF NOT EXISTS idx_content_tenant_batch    ON content(tenant_id, batch_id);
CREATE INDEX IF NOT EXISTS idx_live_tenant_time        ON live_classes(tenant_id, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_notif_tenant_user       ON notifications(tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_leads_status            ON leads(status, created_at DESC);
