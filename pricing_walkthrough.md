# Pricing Plan Integration — Walkthrough

> **Scope:** Pure analysis. Koi implementation nahi. Current backend ke hisab se kya kya changes aur additions chahiye.

---

## 1. Gap Analysis — Current Backend vs. New Pricing

### Current `subscriptions` Table (Existing)

| Column | Current Value | Problem |
|---|---|---|
| `plan` | `'flat'` or `'per_student'` | Sirf 2 options hain, aapke paas ab **3 named plans** hain (Basic, Pro, Elite) |
| `amount` | `INT` (flat ₹2500) | Per-student amount store nahi hoti; billing cycle nahi pata |
| — | Missing | `billing_cycle` column hai hi nahi (`monthly/quarterly/yearly`) |
| — | Missing | Plan ke andar kaun kaun si **features** enabled hain, yeh track nahi hota |

**Conclusion:** `subscriptions` table ko extend karna padega.

---

## 2. Database — Kya Add Karna Padega

### New Table: `plan_catalog` (Super Admin manage karega)
Super Admin apni marzi se plans define karega. Yeh table hardcode nahi hai — Super Admin dashboard se dynamically manage hogi.

```
plan_catalog
├── id (PK)
├── name          → 'Basic' | 'Pro' | 'Elite'
├── price_monthly → ₹20, ₹30, ₹50 (per student)
├── price_quarterly→ ₹15, ₹25, ₹40 (per student)
├── price_yearly  → ₹12, ₹22, ₹35 (per student)
├── features      → JSONB array (e.g. ["attendance","fees","live_classes"])
├── is_active     → boolean (Super Admin disable kar sake)
└── created_at
```

### Modify: `subscriptions` Table
Current columns ke saath 3 naye columns add honge:

```
subscriptions (existing + new columns)
├── plan_id         → FK → plan_catalog (ab 'flat' string nahi, proper reference)
├── billing_cycle   → 'monthly' | 'quarterly' | 'yearly'
├── per_student_rate→ INT (snapshot at time of payment, e.g. ₹22)
├── student_count   → INT (billing ke time snapshot, kitne students hain)
└── amount          → (existing column, ab calculated: per_student_rate × student_count)
```

> **Why snapshot?** Agar aage plan price change ho, toh purani subscriptions affect na hon.

---

## 3. Super Admin — Kya Manage Karega

Super Admin ke paas 2 areas honge:

### 3A. Plan Management (CRUD on `plan_catalog`)
Super Admin ka dashboard mein ek **"Plan Management"** section hoga jahan wo:
- Naaya plan create kar sake (e.g., ek "Enterprise" plan baad mein add karna ho)
- Existing plan ki prices update kar sake
- Kisi plan ko `is_active = false` kar ke hide kar sake (existing subscribers affect nahi honge)
- Features toggle kar sake per plan

### 3B. Tenant Subscription Management
Jab koi institute onboard ho, Super Admin uska plan assign karega:
- Tenant ka plan select karna (`Basic/Pro/Elite`)
- Billing cycle choose karna (`Monthly/Quarterly/Yearly`)
- Student count dekh sakta hai (auto-calculate hoga)
- Manually status change karna (`trial → active → suspended`)
- Payment history dekhna

---

## 4. New API Endpoints (Super Admin)

Existing `superadmin.routes.js` mein yeh routes add honge:

```
GET  /superadmin/plans              → Saare plans list (plan_catalog)
POST /superadmin/plans              → Naya plan create
PUT  /superadmin/plans/:id          → Plan prices ya features update
DEL  /superadmin/plans/:id          → Plan deactivate

GET  /superadmin/tenants/:id/subscription   → Ek tenant ki subscription detail
PUT  /superadmin/tenants/:id/subscription   → Plan ya cycle change karna
```

---

## 5. Feature Gating — Sabse Important Part

Aapka pricing table 3 plans mein alag alag features deta hai. Backend ko yeh enforce karna padega.

### Features per Plan:

| Feature | Basic | Pro | Elite |
|---|:---:|:---:|:---:|
| Student & Batch Management | ✅ | ✅ | ✅ |
| Digital Attendance | ✅ | ✅ | ✅ |
| Fee Management | ✅ | ✅ | ✅ |
| Video Library | ✅ | ✅ | ✅ |
| Auto-WhatsApp Reminders | ❌ | ✅ | ✅ |
| Live Classes | ❌ | ✅ | ✅ |
| Performance Reports | ❌ | ✅ | ✅ |
| Online Tests | ❌ | ✅ | ✅ |
| Custom Branding | ❌ | ❌ | ✅ |
| Teacher Accounts (Max 3) | ❌ | ❌ | ✅ |

### How to Enforce — `featureGuard` Middleware
Existing `subscriptionGuard.js` ki tarah ek **naya middleware** banana padega:

```
featureGuard('live_classes')
  ↓
1. req.user.tenantId se subscription fetch karo
2. Subscription se plan_id nikalo
3. plan_catalog se features JSONB check karo
4. Agar feature array mein 'live_classes' hai → next()
5. Nahi hai → 403 { code: 'PLAN_UPGRADE_REQUIRED', requiredPlan: 'Pro' }
```

**Specific routes par apply hoga:**

```
POST /teacher/live-classes          → featureGuard('live_classes')
POST /teacher/attendance + WA link  → featureGuard('whatsapp_reminders')
PUT  /admin/branding                → featureGuard('custom_branding')
POST /admin/teachers                → featureGuard('teacher_accounts')
POST /admin/tests                   → featureGuard('online_tests')
```

---

## 6. Billing Amount Calculation

Aapka pricing per-student hai, toh amount dynamically calculate hogi:

```
Billing Cycle: Yearly
Plan: Pro
Per-student rate (yearly): ₹22/month
Student count: 80

Amount = 80 students × ₹22 × 12 months = ₹21,120 / year
```

**Quarterly example:**
```
80 students × ₹25 × 3 months = ₹6,000 / quarter
```

Yeh calculation `POST /payments/create-order` ke andar hogi jab Razorpay order create ho.

---

## 7. Overall Data Flow — Ek Tenant Onboard Hone Se Payment Tak

```
[Super Admin Creates Tenant]
       ↓
  plan_catalog se plan select (e.g., Pro, Yearly)
       ↓
  subscription row insert:
    status='trial', billing_cycle='yearly',
    plan_id=2 (Pro), trial_ends_at=now()+7d
       ↓
[Trial Period — 7 Days]
  featureGuard checks plan features
  Basic features work, Pro features blocked if Basic plan
       ↓
[Day 8 — subscriptionGuard fires]
  Coaching Admin ko payment screen dikhti hai
       ↓
[POST /payments/create-order]
  Student count fetch karo (COUNT from students table)
  Per-student rate × student_count × months = final amount
  Razorpay order create
       ↓
[POST /payments/verify]
  Signature verify
  subscription.status = 'active'
  subscription.student_count = snapshot (current count)
  subscription.per_student_rate = plan ka rate
  next_billing_date = now() + (30/90/365 days based on cycle)
       ↓
[Cron Job]
  2 days before next_billing_date → reminder WhatsApp
  2 days after next_billing_date unpaid → status='past_due'
```

---

## 8. Frontend Pricing Table — Backend Se Connection

Aapka `PricingTable` component abhi static data use karta hai. Production mein:

```
GET /public/plans
  ↓
plan_catalog fetch karo (is_active = true only)
  ↓
prices aur features dynamically return honge
  ↓
Frontend render karega
```

> **Benefit:** Agar Super Admin ne koi plan ki price update ki, toh website automatically reflect karega. Hardcode nahi rehega.

---

## Summary — Kya Kya Naya Chahiye

| Area | Change Type | Status |
|---|---|---|
| `plan_catalog` table | New table | ✅ Done |
| `subscriptions` table | 3 columns add | ✅ Done |
| `featureGuard` middleware | New middleware | ✅ Done (Verified) |
| Super Admin Plan CRUD APIs | New routes | ✅ Done |
| `GET /public/plans` (for frontend) | New public route | ✅ Done |
| WebApp `PricingTable` Component | React implementation | ✅ Done |
| Billing amount calculation in payment | Modify existing | 🔴 High |
| Plan snapshot on payment | Modify existing | 🟡 Medium |

