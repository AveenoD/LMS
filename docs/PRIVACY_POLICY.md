# Privacy Policy — Campus

**Last updated:** September 1, 2026

This Privacy Policy describes how Campus ("we," "us," "our") collects, uses, stores, and shares information through:

- the **Campus mobile app** (Android/iOS, used by coaching institute admins, teachers, and students), and
- the **Campus marketing website** (campusweb.co.in — informational pages and the demo-booking/contact forms).

Campus is a software platform that coaching institutes ("institutes") use to manage their own students, teachers, attendance, fees, tests, and related academic operations. Each institute is a separate customer ("tenant") of Campus, and its coaching admin(s) control what student and teacher data is entered into the platform on the institute's behalf.

If you are a student or parent, your institute — not Campus — is typically the one that created your account and entered your information. Questions about a specific student's data are often best directed to your institute first.

---

## 1. Information We Collect

### 1.1 Account information (all roles)
When an institute's coaching admin creates an account for a teacher or student, or when a coaching admin registers their institute, we store:

- Full name
- Phone number (used as the login identifier; must be unique across the platform)
- Email address (optional)
- Role (coaching admin, teacher, or student)
- Password (never stored in plain text — see Section 5)
- Profile photo, if uploaded

### 1.2 Student-specific information
For each student, an institute additionally stores:

- Roll number and grade/class
- Parent/guardian name (optional) and parent/guardian phone number (required)
- Batch/subject enrollment, attendance records, test scores and submitted answers, and fee payment history

### 1.3 Teacher-specific information
For each teacher, an institute additionally stores:

- Status (active, on leave, or inactive) and leave dates, if applicable
- If the teacher chooses to connect a Google account (optional, used only for scheduling live classes — see Section 3), we store a long-lived Google refresh token and the connected Google account's email address.

### 1.4 Prospective-customer information (demo requests / contact form)
If you submit the "Book a Demo" or contact form on our website, we collect: your name, institute name, phone number, email (optional), city, approximate student count, and any message you write. This information is used only to follow up about a possible institute subscription and is not shared with any institute's students or teachers.

### 1.5 Payment information
When an institute pays for a subscription, payment is processed by **Razorpay**, a third-party payment gateway. We do not collect or store your card, UPI, or bank details — those are entered directly into Razorpay's own secure checkout. We store only: the subscription amount, a payment reference ID, and a payment-verification signature, so we can confirm a payment succeeded.

For fees a student pays to their institute directly (e.g., in cash, at the institute's office), the institute's coaching admin manually records the amount and payment method in the app. Campus does not process or touch this money — it is a record-keeping entry made by the institute.

### 1.6 Push notification tokens
If you allow notifications, your device registers a push-notification token with us (via Firebase Cloud Messaging) so we can deliver in-app alerts (e.g., "fee due," "new class assigned," "test scheduled"). If a token stops working (e.g., the app was uninstalled), we delete it automatically the next time we try to use it and it fails.

### 1.7 What we do NOT collect
We do not collect your precise location, biometric data, or government ID numbers. We do not use any third-party analytics, advertising, or crash-tracking tools in the app or website (as of the date of this policy) — we do not track your behavior for advertising purposes, and no data is sold to advertisers.

---

## 2. How We Use Information

We use the information above to:

- Operate your institute's account: attendance tracking, fee tracking, batch/subject management, test creation and scoring, and academic reporting
- Send you notifications relevant to your role (fee reminders, attendance alerts, new content, live class schedules, test reminders) via in-app notifications, push notifications, and, for institutes on plans that include it, email
- Let a teacher generate a WhatsApp message to a parent's phone number (see Section 3.4) — this only opens the teacher's own WhatsApp app with a pre-filled message; we do not send WhatsApp messages ourselves
- Process subscription payments and maintain billing records
- Respond to demo requests and support inquiries
- Maintain the security and integrity of the platform (e.g., detecting invalid login attempts)

---

## 3. Third Parties We Share Information With

We work with the following service providers, each of whom processes a limited, specific set of data on our behalf:

### 3.1 Supabase (database hosting)
All platform data is stored in a PostgreSQL database hosted by Supabase, located in the Mumbai (ap-south-1) AWS region. Supabase does not use this data for its own purposes — it is our data processor.

### 3.2 Vercel (application hosting)
Our backend and website run on Vercel's hosting infrastructure. Vercel processes requests to operate the service but does not receive separate access to your stored data beyond what is necessary to run the application.

### 3.3 Firebase Cloud Messaging (push notifications)
We send your device's push token, along with a notification title and message body, to Firebase (a Google service) so it can deliver the notification to your device. We do not send your name, phone number, or other account fields to Firebase as structured data — only the notification text itself, which may incidentally mention a name (e.g., "Payment received, thank you!").

### 3.4 WhatsApp — deep links only, not the WhatsApp Business API
When a teacher or coaching admin uses the "remind via WhatsApp" feature, the app builds a `wa.me` link containing a pre-filled message and opens the user's own installed WhatsApp app. **No message or phone number is transmitted to WhatsApp, Meta, or any third-party messaging service by Campus itself** — the message is only actually sent if the teacher or admin manually presses send inside their own WhatsApp app. We do not use the paid WhatsApp Business API and do not have visibility into whether a message was actually delivered or read.

### 3.5 Google (optional, teacher-initiated only)
If a teacher chooses to connect their Google account, we request permission to create and manage Google Calendar events (specifically, the `calendar.events` scope) so we can generate Google Meet links for live classes. We also read the connected account's email address to display which Google account is linked. We store a Google refresh token so the teacher does not need to reconnect every session. This connection is entirely optional, initiated by the teacher, and used only to create/delete the teacher's own calendar events — no student data is ever sent to Google.

### 3.6 Razorpay (payments)
Described in Section 1.5. Razorpay receives the payment amount, currency, and order metadata (institute ID and billing period, not personal names) needed to process a transaction. Razorpay's own privacy policy governs how it handles your payment card/bank details.

### 3.7 Email delivery (Resend)
For institutes on a subscription plan that includes email notifications, we send notification emails (the same content as push notifications) via Resend, a transactional email provider, to the email address on file for the relevant user. If a student, teacher, or admin has no email address on file, they do not receive these emails — only in-app and push notifications.

### 3.8 Internal operational notifications
When someone submits a demo request or contact form, a summary of that submission is sent to our own internal email inbox and Telegram channel so our team can follow up. This is an internal tool for us, not a data-sharing arrangement with any outside company.

### 3.9 Cloudinary (file uploads)
Course content (videos, PDFs, images) and profile photos that institutes upload are stored with Cloudinary, a media-hosting provider. We do not send this content to any other third party.

We do not sell your personal information to anyone, and we do not share it with advertisers.

---

## 4. Data Storage on Your Device

The mobile app stores a local, on-device cache of recent data (such as your dashboard, attendance, and fee information) so the app loads quickly and can show recent data with a weak connection. This cache is stored in the app's local storage on your device and is automatically cleared when you log out. Your login session token is also stored locally on your device in the app's standard local storage.

---

## 5. How We Protect Your Information

- Passwords are never stored in plain text — they are hashed using bcrypt before being saved.
- Login sessions use time-limited access tokens (valid for 15 minutes) and longer-lived refresh tokens (valid for 30 days) to keep you signed in without repeatedly re-entering your password. These tokens identify your account by an internal ID only — they do not contain your name, phone number, or email.
- All connections to our servers use HTTPS encryption.

No method of storage or transmission is 100% secure, and we cannot guarantee absolute security, but we take reasonable, industry-standard measures to protect your information.

---

## 6. Data Retention and Deletion

- Your institute's coaching admin controls student and teacher records within their institute. If a coaching admin removes a student or teacher from the platform, that person's account and associated records (attendance, test results, fee history, notifications) are permanently deleted from our systems — this action cannot be undone by us.
- A coaching admin can also **suspend** a student's or teacher's access without deleting their data — this is reversible and simply blocks that person from logging in until reactivated.
- If an institute's subscription lapses, we do not delete the institute's data. The institute's coaching admin retains the ability to view existing records; some actions that create new data may be limited until the subscription is renewed.
- Demo request / contact form submissions are retained so we can track and follow up on sales inquiries; we do not currently have an automatic deletion schedule for this data.
- At present, we do not offer a fully self-service "delete my account" or "export my data" feature within the app. If you would like your personal data deleted or exported, please contact us using the details in Section 9, or ask your institute's coaching admin to remove your account (Section 6, first bullet).

---

## 7. Children's Data

Campus is used by coaching institutes to manage students of varying ages, including students under 18. Student accounts are created and managed by the institute's coaching admin, not by the student signing up on their own — the admin sets the student's initial password when creating the account. We require institutes to collect a parent/guardian contact phone number for every student record.

We do not knowingly allow students to create their own accounts without an institute's involvement, and we do not collect information directly from a student that goes beyond what their institute has chosen to enter (e.g., we do not ask students for a birthdate or age). If you are a parent and have concerns about your child's data on the platform, please contact your institute's coaching admin first, or reach us directly using Section 9.

---

## 8. Your Choices

- **Notifications:** you can disable push notifications for the app in your device's system settings.
- **WhatsApp reminders:** these only open your own WhatsApp app with a pre-filled message — you choose whether to send it.
- **Google account connection:** a teacher can disconnect their Google account at any time from within the app; this deletes the stored refresh token.
- **Account data:** see Section 6 for how to request deletion.

---

## 9. Contact Us

If you have questions about this Privacy Policy or how your information is handled, contact us at:

- **Email:** support@campusweb.co.in
- **Phone:** +91 98765 43210
- **Location:** Mumbai, Maharashtra, India

---

## 10. Changes to This Policy

We may update this Privacy Policy from time to time as the platform evolves. We will update the "Last updated" date at the top of this page when changes are made. Continued use of the app or website after changes take effect means you accept the updated policy.
