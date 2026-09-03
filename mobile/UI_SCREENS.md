# Campus — Complete UI Screen Specifications
> **Agent Instructions:** Read the ENTIRE Design System (Section 0) first.
> Build each screen using ONLY the tokens defined here.
> No gradients. No red for actions. One brass-gold CTA per screen.

---

## 0. DESIGN SYSTEM

### 0.1 Color Palette
```dart
class AppColors {
  static const inkGreen    = Color(0xFF1F2E27); // Nav, headings, dark chrome
  static const paper       = Color(0xFFF4F6F3); // Scaffold/page background
  static const brassGold   = Color(0xFFA87D26); // Primary CTA only (1 per screen)
  static const chalkTeal   = Color(0xFF2E6656); // Positive states, success, selected
  static const redInk      = Color(0xFFA93327); // Warnings/errors ONLY, never CTA
  static const cardSurface = Color(0xFFFFFFFF); // All card surfaces
  static const inkGreen10  = Color(0x1A1F2E27); // Subtle backgrounds
  static const chalkTeal10 = Color(0x1A2E6656);
  static const redInk10    = Color(0x1AA93327);
  static const brassGold10 = Color(0x1AA87D26);
  static const textPrimary = Color(0xFF1F2E27);
  static const textSecond  = Color(0xFF6B7280);
  static const divider     = Color(0xFFE5E7EB);
}
```

### 0.2 Typography
```
Heading font : Playfair Display  (Google Fonts)
Body font    : Plus Jakarta Sans (Google Fonts)

displayLg  = Playfair Display, 32, w700
displayMd  = Playfair Display, 24, w700
displaySm  = Playfair Display, 20, w600
headingMd  = Plus Jakarta Sans, 18, w700
headingSm  = Plus Jakarta Sans, 16, w600
bodyLg     = Plus Jakarta Sans, 15, w400
bodyMd     = Plus Jakarta Sans, 14, w400
bodySm     = Plus Jakarta Sans, 12, w400
labelMd    = Plus Jakarta Sans, 14, w600
labelSm    = Plus Jakarta Sans, 12, w600
caption    = Plus Jakarta Sans, 11, w400
```

### 0.3 Spacing & Radius
```
xs=4  sm=8  md=16  lg=24  xl=32  xxl=48
radiusSm=8  radiusMd=12  radiusLg=16  radiusXl=24  radiusFull=999
```

### 0.4 Shadows
```dart
BoxShadow cardShadow     = BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0,2));
BoxShadow elevatedShadow = BoxShadow(color: Color(0x1A1F2E27), blurRadius: 20, offset: Offset(0,4));
```

### 0.5 Buttons
```
PRIMARY   bg=brassGold  text=white    radius=12  pad=H24 V14  trailing Icons.arrow_forward
SECONDARY bg=white      text=inkGreen radius=12  pad=H24 V14  border=1.5px inkGreen
TERTIARY  bg=inkGreen   text=white    radius=12  pad=H24 V14
TEXTLINK  text=chalkTeal  14 Semibold  trailing arrow 14px
```

### 0.6 Cards
```
bg=white  radius=16  shadow=cardShadow  padding=16
Default: no border. Selected state: 1.5px chalkTeal border.
```

### 0.7 AppBar
```
bg=inkGreen  title=Playfair Display 18 Bold white  icons=white  elevation=0
```

### 0.8 Bottom Navigation
```
bg=inkGreen  selected=brassGold  unselected=white60%  height=64  icons=outlined  label=PJS 10px
```

### 0.9 Input Fields
```
bg=paper  radius=12  height=52  border=1.5px
default=divider  focused=chalkTeal  error=redInk
label=PJS 12 Semibold textSecond (floats on focus)
prefix icon=inkGreen 50%
```

### 0.10 Status Chips
```
active/present/paid/converted  bg=chalkTeal10  text=chalkTeal
trial/pending/new              bg=brassGold10  text=brassGold
expired/absent/overdue/lost    bg=redInk10     text=redInk
late                           bg=orange10     text=orange
Style: pad H:10 V:4  radius=999  text=11pt Semibold
```

---

## 1. AUTH SCREENS

### [1.1] SPLASH
Route: /splash

```
Scaffold(bg=inkGreen)
CENTER:
  Logo SVG white 80x80
  SizedBox h:16
  "Campus"  Playfair Display 36 Bold white
  "Run your institute. Delight every student."  PJS 14 white70%
BOTTOM pb:48:
  CircularProgressIndicator(color=brassGold strokeWidth=2)
```
Logic: check stored JWT -> route by role or -> /login

---

### [1.2] LOGIN
Route: /login
API: POST /api/v1/auth/login

```
Scaffold(bg=paper)

TOP PANEL (inkGreen, borderRadius bottom:32, pad H:24 top:60 bottom:40):
  Logo white 48x48
  "Campus"  PD 28 Bold white
  Tagline  PJS 13 white70%

CARD (white, margin H:24, radius:24, shadow:elevatedShadow, pad:24):
  "Welcome Back"    PD 22 Bold inkGreen
  "Sign in to continue"  PJS 13 textSecond
  SizedBox h:24

  InputField "Institute Slug" (Icons.business_outlined)
    [hidden when Super Admin mode active]
  InputField "Phone" (Icons.phone_outlined, keyboardType=phone)
  InputField "Password" (Icons.lock_outline, obscure, eye-toggle suffix)

  Row [Spacer | TextLink "Super Admin? ->"]

  SizedBox h:24
  PRIMARY BUTTON "Sign In ->" (full width)
  "Powered by Campus"  caption center textSecond
```
Error: Bottom snackbar bg=redInk10 text=redInk. Never red field borders except validation.

---

## 2. SUPER ADMIN SCREENS

### [2.1] SUPER ADMIN DASHBOARD
Route: /superadmin/dashboard
APIs: GET /superadmin/analytics | GET /superadmin/leads?limit=3

```
Scaffold(bg=paper)
AppBar(inkGreen): "Campus" | actions:[NotifBadge(count=unread), CircleAvatar]

Body SingleChildScrollView pad:16:

  "Good morning, Admin!" PD 20 Bold inkGreen
  "Here's your platform overview"  bodySm textSecond
  SizedBox h:20

  GridView(2 cols, gap:12) -- KPI CARDS
    Each card: white radius:16 shadow pad:16
    top: icon 24px chalkTeal + label bodySm textSecond
    mid: value PD 28 Bold inkGreen
    Cards: Total Tenants | Active Tenants | Total Students | MRR(brassGold)

  SizedBox h:20
  Row ["Trials Expiring" headingSm | Spacer | TextLink "View all ->"]
  HorizontalListView h:120
    Card white radius:12 pad:12 w:180
    instituteName labelMd | "Trial ends in X days" bodySm | StatusChip(pending)

  SizedBox h:20
  Row ["New Demo Requests" headingSm | Spacer | TextLink "View all ->"]
  ListView 3 items -- LeadTile
    Card white radius:12 pad H:16 V:12
    left border 3px brassGold if unread
    Row[CircleAvatar(44,inkGreen10,initials) | Column(name,institute,city+count) | StatusChip]
```

---

### [2.2] INSTITUTES LIST
Route: /superadmin/tenants
API: GET /superadmin/tenants

```
Scaffold(bg=paper)
AppBar: "Institutes" | action: PRIMARY "Add New +"

Body pad:16:
  SearchBar
  ListView -- TenantCard
    Card white radius:16 shadow pad:16 mb:12
    Row[
      Column[instituteName headingSm | "slug:..." caption | Row[StatusChip | "X students"]]
      Column(end)[planName labelSm chalkTeal | nextBillingDate caption]
    ]
    Divider color:divider V:12
    Row[TextLink "View Details ->" | Spacer | block/activate IconButton]
```

---

### [2.3] REGISTER INSTITUTE
Route: /superadmin/tenants/new
API: POST /superadmin/tenants

```
Scaffold(bg=paper)
AppBar: "Register Institute" (back button)

Body SingleChildScrollView pad:16:
  "Institute Details"  displaySm
  "Fill in the coaching centre information"  bodySm textSecond
  SizedBox h:24

  SectionHeader("Institute Information")
  InputField "Institute Name"    (Icons.school_outlined)
  InputField "Slug"              (Icons.link_outlined)  helper: "Lowercase hyphens only"
  InputField "City"              [optional]
  InputField "Contact Phone"     [optional]
  InputField "Brand Color #hex"  [optional] suffix=color preview circle
  SizedBox h:24

  SectionHeader("Admin Account")
  InputField "Admin Name" | InputField "Admin Phone" | InputField "Password" (obscure)
  SizedBox h:24

  SectionHeader("Plan Assignment")
  DropdownField "Billing Cycle" [monthly|quarterly|yearly]
  DropdownField "Plan" (fetched from /superadmin/plans)
  SizedBox h:32

  PRIMARY BUTTON "Register Institute ->" (full width)
```

---

### [2.4] PLAN CATALOG
Route: /superadmin/plans
API: GET /superadmin/plans

```
Scaffold(bg=paper)
AppBar: "Plan Catalog" | action: "Add Plan +"

Body pad:16 -- ListView PlanCard
  Card white radius:16 shadow pad:20 mb:12
  Row[planName PD20Bold inkGreen | Spacer | StatusChip(active/inactive)]
  Row gap:16
    PriceBlock("Monthly","Rs.X/student")
    PriceBlock("Quarterly","Rs.X/student")
    PriceBlock("Yearly","Rs.X/student") + "Best" badge brassGold
  Wrap feature chips (bg=inkGreen10 text=inkGreen radius=999)
  Divider V:12
  Row[TextLink "Edit ->" | Spacer | IconButton(delete, redInk)]
```

---

### [2.5] LEADS INBOX
Route: /superadmin/leads
API: GET /superadmin/leads

```
Scaffold(bg=paper)
AppBar: "Demo Requests"

Body pad:16:
  HorizontalFilterChips [All|New|Contacted|Converted|Lost]
    selected: bg=inkGreen text=white
    unselected: bg=paper border=divider text=textSecond

  ListView -- LeadDetailCard
    Card white radius:16 shadow pad:16 mb:12
    left border 3px brassGold if unread
    Row[CircleAvatar(44,inkGreen) | Column[Row[ownerName|Spacer|time] | instituteName]]
    Row gap:8 [InfoChip(city) | InfoChip(count) | InfoChip(phone)]
    if message: Text bodySm textSecond maxLines:2
    Divider V:12
    Row[StatusDropdown [new|contacted|converted|lost] | Spacer | SECONDARY "WhatsApp ->"]
```

---

### [2.6] SUBSCRIPTIONS
Route: /superadmin/subscriptions
API: GET /superadmin/subscriptions

```
Scaffold(bg=paper)
AppBar: "Subscriptions"

Body pad:16:
  FilterChips [All | Active | Trial | Past Due | Expired]
  ListView -- SubscriptionTile
    Card white radius:12 shadow pad:16 mb:8
    Row[instituteName headingSm | Spacer | StatusChip]
    Row[planName bodySm chalkTeal | " . " | billingCycle bodySm textSecond]
    Row["Rs.{amount}" labelMd | Spacer | "Next: {date}" caption textSecond]
    TextLink "Manage ->"
```

---

## 3. COACHING ADMIN SCREENS

Admin navigation: Side Drawer (or NavRail on tablet)
Items: Dashboard | Students | Teachers | Batches | Fees | Reports | Branding | Subscription

---

### [3.1] ADMIN DASHBOARD
Route: /admin/dashboard
API: GET /admin/dashboard

```
Scaffold(bg=paper)

TOP PANEL (inkGreen, borderRadius bottom:32, pad H:20 top:50 bottom:20):
  Row[
    Column["Good morning!" bodySm white70% | instituteName PD22Bold white]
    CircleAvatar(brassGold,44,initials)
  ]
  SizedBox h:20
  Row gap:12 -- 3 mini StatCards (bg=white15, radius:12, pad:12)
    each: icon white20 + value PD18Bold white + label caption white70%
    Students | Teachers | Batches

Body SingleChildScrollView pad H:16 top:20:

  -- FEE OVERVIEW --
  Card white radius:16 shadow pad:20
    "Fee Collection"  headingSm
    Row[
      SizedBox 90x90: Stack[
        CircularProgressIndicator(value=collected/total, color=chalkTeal, bg=divider)
        Center: "75%\nCollected" labelMd
      ]
      SizedBox w:20
      Column[
        FeeRow("Collected", amount, chalkTeal)
        FeeRow("Pending", amount, redInk)
      ]
    ]
    PRIMARY BUTTON "Collect Fee ->" (full width)

  SizedBox h:16

  -- ATTENDANCE TODAY --
  Card white radius:16 shadow pad:20
    Row["Attendance Today" headingSm | Spacer | "X/Y Present" labelMd chalkTeal]
    SizedBox h:16
    Wrap -- student dots CircleAvatar size:32
      green=present grey=absent yellow=late

  SizedBox h:16

  -- QUICK ACTIONS --
  "Quick Actions"  headingSm
  GridView 2cols gap:12
    QuickActionCard = Card white radius:16 shadow pad:16
    Container(48x48, bg=color10, radius:12): icon(color,24) + label(labelMd, mt:12)
    Add Student(brassGold) | Mark Attendance(chalkTeal) | Record Fee(inkGreen) | Reports(chalkTeal)
```

---

### [3.2] STUDENTS LIST
Route: /admin/students
API: GET /admin/students

```
Scaffold(bg=paper)
AppBar: "Students" | action: Icons.filter_list_outlined

Body Column:
  Pad H:16 V:12: SearchBar + HorizontalBatchChips
  ListView -- StudentTile
    Card white radius:12 shadow pad H:16 V:12 margin H:16 mb:8
    Row[
      CircleAvatar(44, bg=inkGreen10, initials color=inkGreen)
      SizedBox w:12
      Column flex:1 [fullName labelMd | rollNo+" . "+grade bodySm textSecond | batchName caption chalkTeal]
      Column end [FeeStatusChip | Icons.chevron_right textSecond]
    ]

FAB: brassGold Icons.add -> Add Student bottom sheet
```

---

### [3.3] ADD STUDENT (Bottom Sheet)
API: POST /admin/students

```
DraggableScrollableSheet(initial:0.75, max:0.95)
  handle pill grey center
  pad H:24
  "Enroll New Student"  PD20Bold
  SizedBox h:24
  InputField "Full Name"    (Icons.person_outline)
  InputField "Phone"        (Icons.phone_outlined)
  InputField "Password"     (Icons.lock_outline, obscure)
  InputField "Parent Name"  [optional]
  InputField "Parent Phone"
  InputField "Grade"        [optional]
  InputField "Roll No"      [optional]
  DropdownField "Batch"     (from /admin/batches)
  SizedBox h:24
  PRIMARY BUTTON "Enroll Student ->" (full width)
```

---

### [3.4] TEACHERS LIST
Route: /admin/teachers
API: GET /admin/teachers

```
Scaffold(bg=paper)
AppBar: "Teachers"

Body pad:16 -- ListView TeacherCard
  Card white radius:12 shadow pad H:16 V:12 mb:8
  Row[CircleAvatar(44,inkGreen) | SizedBox(12) | Column[fullName labelMd | phone bodySm textSecond] | Icons.delete_outline redInk]

FAB: brassGold -> Add Teacher (same bottom sheet pattern as student)
```

---

### [3.5] BATCHES & TIMETABLE
Route: /admin/batches
APIs: GET /admin/batches | GET /admin/timetable

```
Scaffold(bg=paper)
AppBar: "Batches"
TabBar [Batches | Timetable] indicator: brassGold 3px underline

TAB 1 -- Batches:
  ListView BatchCard
    Card white radius:12 shadow pad:16 mb:8
    Row[batchName headingSm | Spacer | Chip(grade)]
    "X students enrolled"  bodySm textSecond
    Row[TextLink "View Students ->" | Spacer | TextLink "Add to Timetable ->"]

TAB 2 -- Timetable:
  DaySelector horizontal (Mon Tue Wed Thu Fri Sat)
    selected: inkGreen pill text=white
    unselected: white border text=inkGreen
  SizedBox h:16
  ListView TimetableSlot
    Card white radius:12 shadow pad:16 mb:8
    Row[
      Column(w:60,center)[startTime labelMd inkGreen | Divider h:8 | endTime caption textSecond]
      SizedBox w:16
      Column[batchName labelMd | subjectName bodySm textSecond | Row[personIcon | teacherName bodySm chalkTeal]]
    ]
```

---

### [3.6] FEE MANAGEMENT
Route: /admin/fees
API: GET /admin/fees

```
Scaffold(bg=paper)
AppBar: "Fee Management"
TabBar [Overview | Structures | Payments]

TAB 1 -- Overview:
  SummaryCard (inkGreen bg, radius:16, pad:20, full width)
    "Total Collected"  bodySm white70%
    "Rs.4,50,000"  PD28Bold white
    "Pending: Rs.75,000"  bodySm brassGold

  SizedBox h:16
  FilterChips [All | Pending | Overdue | Paid]
  ListView FeeStudentTile
    Card white radius:12 shadow pad H:16 V:12
    Row[
      studentName labelMd
      Spacer
      Column end ["Rs.X paid" bodySm chalkTeal | "Rs.X pending" bodySm redInk]
      IconButton(Icons.message_outlined, brassGold) -> WhatsApp
    ]

TAB 2 -- Structures: ListView + FAB(add)
TAB 3 -- Payments: ListView chronological
```

---

### [3.7] PERFORMANCE REPORTS
Route: /admin/reports
API: GET /admin/reports/performance [Pro/Elite only]

```
Scaffold(bg=paper)
AppBar: "Performance Reports"

if plan=Basic: show UpgradeBanner

Body SingleChildScrollView pad:16:
  DropdownField "Select Batch" (full width)
  SizedBox h:20
  Row gap:12 [StatCard("Avg Attendance","87.4%",chalkTeal) | StatCard("Avg Marks","72.1%",brassGold)]
  SizedBox h:20
  "Top Performers"  headingSm
  ListView 5 items
    Card white radius:12 shadow pad H:16 V:12 mb:8
    Row[
      "#{n}" PD18Bold brassGold w:36
      CircleAvatar(40,inkGreen)
      SizedBox w:12
      Column[studentName labelMd | Row[MiniStat("Marks",%) | MiniStat("Attend",%)]]
    ]
```

---

### [3.8] BRANDING
Route: /admin/branding
API: GET/PUT /admin/branding [Elite only]

```
Scaffold(bg=paper)
AppBar: "Branding"

Body SingleChildScrollView pad:16:
  Card white radius:16 shadow pad:20
    "Preview"  headingSm
    FakeAppBar(bg=primaryColor, logo, instituteName)

  SizedBox h:20
  "Institute Logo"  labelMd
  Row[
    Container(80x80,radius:12,border=divider): CachedNetworkImage or icon placeholder
    SizedBox w:16
    Column[SECONDARY "Upload Logo" | "PNG, JPG. Max 2MB"  caption textSecond]
  ]

  SizedBox h:20
  "Primary Brand Color"  labelMd
  InputField(value=hex, prefix=colorCircle)

  SizedBox h:32
  if Elite: PRIMARY BUTTON "Save Branding ->"
  else: UpgradeBanner("Custom branding requires Elite plan")
```

---

### [3.9] SUBSCRIPTION / BILLING
Route: /admin/subscription
APIs: GET /payments/subscription | POST /payments/create-order

```
Scaffold(bg=paper)
AppBar: "Subscription"

Body SingleChildScrollView pad:16:
  Card (inkGreen bg, radius:20, shadow, pad:24)
    Row["Current Plan" bodySm white70% | Spacer | StatusChip(status)]
    planName  PD24Bold white
    billingCycle  bodySm brassGold
    SizedBox h:16
    Divider white20
    SizedBox h:16
    Row[InfoBlock("Students",count) | InfoBlock("Rs./student",rate) | InfoBlock("Next Bill",date)]
    all text: white

  SizedBox h:20
  Card white radius:16 shadow pad:20
    "Next Invoice Estimate"  headingSm
    SizedBox h:16
    CalcRow("Students", count)
    CalcRow("Rate", "Rs.{rate}")
    CalcRow("Cycle", months+" months")
    Divider V:12
    CalcRow("Total", "Rs.{total}", bold=true, color=brassGold, size=18)

  SizedBox h:24
  if not active: PRIMARY BUTTON "Pay Now -- Rs.{total} ->"
  else: SECONDARY BUTTON "Manage Plan"
```

---

## 4. TEACHER SCREENS

Bottom Navigation (inkGreen, 4 tabs):
  Schedule    Icons.calendar_today_outlined    /teacher/schedule
  Attendance  Icons.check_circle_outline       /teacher/attendance
  Content     Icons.play_circle_outline        /teacher/content
  Live        Icons.videocam_outlined          /teacher/live

---

### [4.1] TODAY'S SCHEDULE
Route: /teacher/schedule
API: GET /teacher/schedule/today

```
Scaffold(bg=paper)
AppBar(inkGreen): "Today's Schedule" + date subtitle

Body pad:16:
  DateStrip horizontal 7 days
    Each: Column[dayAbbrev caption | dateNum labelMd]
    selected: Container(36x36, bg=brassGold, radius=full) text=white
    today: text=brassGold bold

  SizedBox h:20
  if empty:
    EmptyState(Icons.event_available_outlined, "No classes today", "Enjoy your free time!")
  else:
    ListView ScheduleCard
      Card white radius:16 shadow pad:16 mb:12
      Row[
        Column(w:56,center)[startTime labelMd inkGreen | endTime caption textSecond]
        Container(w:2, h=full, bg=chalkTeal, margin H:12)
        Column flex:1 [batchName headingSm | subjectName bodySm textSecond | SizedBox h:8 | SECONDARY "Take Attendance ->" compact]
      ]
```

---

### [4.2] MARK ATTENDANCE
Route: /teacher/attendance
APIs: GET /teacher/batches/{id}/students | POST /teacher/attendance

```
Scaffold(bg=paper)
AppBar: "Mark Attendance"

Body Column:
  Pad H:16 V:12:
    DropdownField "Select Batch"
    SizedBox h:8
    DatePickerField (default: today)

  Divider

  ListView students -- AttendanceTile
    Padding H:16 V:6
    Row[
      CircleAvatar(40, inkGreen, initials)
      SizedBox w:12
      Column flex:1 [fullName labelMd | rollNo caption textSecond]
      ToggleButtons([P, A, L], radius:8, size:36x36)
        P Present -> chalkTeal when selected
        A Absent  -> redInk when selected
        L Late    -> brassGold when selected
    ]

  BottomBar (white, shadow above, pad H:16 V:12):
    Row["X students . Y present" bodySm textSecond | Spacer | PRIMARY "Submit ->"]
```

---

### [4.3] CONTENT LIBRARY
Route: /teacher/content
API: GET /teacher/content

```
Scaffold(bg=paper)
AppBar: "Video Library"

Body Column:
  Pad H:16 V:12: SearchBar + HorizontalSubjectChips

  ListView ContentCard
    Card white radius:16 shadow margin H:16 mb:12
    Stack[
      YouTubeThumbnail(h:160, radiusTop:16)
      Positioned(bottom:8, right:8): Container(bg=inkGreen80, radius:4, pad H:8 V:4) "YouTube" caption white
    ]
    Padding 16:
      title  labelMd
      batch+" . "+subject  bodySm textSecond
      Row[calendarIcon 12px | date caption]

FAB: brassGold -> Upload Content bottom sheet
  DraggableSheet initial:0.6
    "Add Video Lecture"  PD18Bold
    SizedBox h:20
    InputField "Lecture Title"
    InputField "YouTube URL" (Icons.link_outlined)
    DropdownField "Batch" [optional]
    DropdownField "Subject" [optional]
    SizedBox h:20
    PRIMARY BUTTON "Upload ->"
```

---

### [4.4] LIVE CLASSES (Teacher)
Route: /teacher/live
API: POST /teacher/live-classes [Pro/Elite only]

```
Scaffold(bg=paper)
AppBar: "Live Classes"

Body:
  if plan=Basic:
    UpgradeBanner("Live Classes require Pro plan", Icons.videocam_off_outlined, "Upgrade Now")
  else:
    ListView LiveClassCard
      Card white radius:16 shadow margin H:16 mb:12 pad:16
      Row[StatusChip(upcoming/live/ended) | Spacer | scheduledAt labelSm brassGold]
      SizedBox h:8
      title  headingSm
      batchName  bodySm textSecond
      if joinable: PRIMARY BUTTON "Join Now ->" (opens meetUrl)

    FAB: brassGold -> Schedule Live Class
      DraggableSheet
        "Schedule Live Class"  PD18Bold
        InputField "Title"
        InputField "Google Meet URL"
        DropdownField "Batch"
        DateTimePicker "Scheduled At"
        PRIMARY BUTTON "Schedule ->"
```

---

## 5. STUDENT SCREENS

Bottom Navigation (inkGreen, 5 tabs):
  Home     Icons.home_outlined                      /student/home
  Videos   Icons.play_circle_outline                /student/videos
  Live     Icons.videocam_outlined                  /student/live
  Fees     Icons.account_balance_wallet_outlined    /student/fees
  Profile  Icons.person_outline                     /student/profile

---

### [5.1] STUDENT HOME
Route: /student/home
API: GET /student/dashboard

```
Scaffold(bg=paper)

TOP PANEL (inkGreen, borderRadius bottom:32, pad H:20 top:50 bottom:24):
  Row[
    Column["Hello, {name}!" bodySm white70% | instituteName PD20Bold white]
    CircleAvatar(brassGold, 44, initials)
  ]
  SizedBox h:20
  if nextLiveClass != null:
    Card(white15, radius:12, pad:12)
      Row[Icons.videocam white 20 | "Live Soon" bodySm brassGold]
      title  labelMd white
      scheduledAt  caption white70%

Body SingleChildScrollView pad H:16 top:20:

  if pendingFees > 0:
    FeeAlertCard (white, radius:12, border:1.5px brassGold, pad H:16 V:12)
    Row[Icons.warning_amber brassGold | Column["Fee Due" | "Rs.X pending"] | Spacer | TextLink "Pay ->"]

  SizedBox h:20
  Row["Recent Lectures" headingSm | Spacer | TextLink "See all ->"]
  HorizontalListView h:200
    VideoCard w:160 Card white radius:12 shadow
    YouTubeThumbnail(h:100, radiusTop:12) + Padding 10[title labelSm maxLines:2 | subject caption]

  SizedBox h:20
  "Today's Schedule"  headingSm
  ListView non-scroll 3 items -- mini ScheduleCard
```

---

### [5.2] VIDEO LECTURES (Student)
Route: /student/videos
API: GET /student/videos

```
Scaffold(bg=paper)
AppBar: "Video Library"

Body Column:
  Pad H:16 V:12: SearchBar + HorizontalSubjectChips

  GridView 2cols gap:12 pad H:16
    ContentGridCard = Card white radius:12 shadow
    Stack[
      YouTubeThumbnail(h:100, radiusTop:12)
      Center: Container(32x32, bg=brassGold, radius=full) Icons.play_arrow white
    ]
    Padding 10:
      title  labelSm maxLines:2
      subject  caption textSecond
```

---

### [5.3] LIVE CLASSES (Student)
Route: /student/live
API: GET /student/live/today

```
Scaffold(bg=paper)
AppBar: "Live Classes"

Body pad:16:
  DateStrip (same as teacher [4.1])
  SizedBox h:20
  ListView LiveClassCard (same design as teacher, join button opens meetUrl)
```

---

### [5.4] FEE SUMMARY
Route: /student/fees
API: GET /student/fees

```
Scaffold(bg=paper)
AppBar: "My Fees"

Body SingleChildScrollView pad:16:
  Card (inkGreen bg, radius:20, shadow, pad:24)
    "Total Fee"  bodySm white70%
    "Rs.{total}"  PD28Bold white
    SizedBox h:16
    Row[FeeBlock("Paid","Rs.{paid}",chalkTeal) | FeeBlock("Pending","Rs.{pending}",brassGold)]

  SizedBox h:20
  "Payment History"  headingSm
  ListView PaymentRow
    Card white radius:12 shadow pad H:16 V:12 mb:8
    Row[
      Container(bg=chalkTeal10, radius:8, pad:10): Icons.receipt_outlined chalkTeal
      SizedBox w:12
      Column flex:1 ["Rs.{amount}" labelMd | paidOn+" . "+method bodySm textSecond]
      TextLink "Receipt ->"
    ]
```

---

### [5.5] PAYMENT RECEIPT
Route: /student/fees/receipt/{paymentId}
API: GET /student/fees/receipt/{paymentId}

```
Scaffold(bg=paper)
AppBar: "Payment Receipt" | action: Icons.share_outlined

Body Center pad:24:
  Card white radius:20 shadow:elevatedShadow pad:24

    Row[logo/icon | instituteName PD18Bold]
    DashedDivider V:16

    Center:
      Container(bg=chalkTeal10, radius=full, pad:16): Icons.check_circle_outline chalkTeal 48
      SizedBox h:12
      "Payment Successful"  PD22Bold chalkTeal

    SizedBox h:24
    ReceiptRow("Receipt No", receiptNo)
    ReceiptRow("Student",    studentName)
    ReceiptRow("Date",       paidOn)
    ReceiptRow("Method",     method.toUpperCase())
    Divider V:12
    ReceiptRow("Amount Paid", "Rs.{amount}", bold=true, inkGreen, size=20)
```

---

### [5.6] STUDENT PROFILE
Route: /student/profile
API: GET /auth/me

```
Scaffold(bg=paper)
AppBar(inkGreen): "My Profile"

Body SingleChildScrollView pad:16:
  Center:
    CircleAvatar(80, inkGreen, initials)
    SizedBox h:12
    fullName  PD22Bold inkGreen
    instituteName  bodySm textSecond
    batchName  caption chalkTeal

  SizedBox h:24
  ProfileSection("Account Details")
    ProfileRow(Icons.phone_outlined, "Phone", phone)
    ProfileRow(Icons.groups_outlined, "Batch", batchName)
    ProfileRow(Icons.grade_outlined, "Grade", grade)
    ProfileRow(Icons.numbers_outlined, "Roll No", rollNo)

  SizedBox h:16
  TERTIARY BUTTON "Logout" (full width)
```

---

## 6. PUBLIC SCREENS

### [6.1] PRICING PAGE
Route: /pricing
API: GET /api/v1/public/plans

```
Scaffold(bg=paper)

HERO (inkGreen bg, pad H:24 V:48):
  "Simple, Honest Pricing"  PD28Bold white center
  "Pay only for your active students."  bodySm white70% center
  SizedBox h:24
  BillingToggle Row(bg=white20, radius=full, pad:4)
    [Monthly | Quarterly | Yearly]
    selected: bg=brassGold text=white
    unselected: transparent text=white70%

Body SingleChildScrollView:
  ListView 3 plan cards
    PlanCard = Card white radius:20 shadow:elevatedShadow pad:24 margin H:16 mb:16
    if Pro plan: border=2px brassGold + badge top-right (bg=brassGold text=white radius=full pad H:12 V:4) "Most Popular"

    planName  PD22Bold inkGreen
    tagline  bodySm textSecond maxLines:2
    SizedBox h:16
    Row(baseline)["Rs." bodyLg | price PD36Bold inkGreen | "/student/mo" bodySm textSecond]
    billedText  caption textSecond
    Divider V:16

    Feature list:
      Each Row h:32:
        Icons.check_circle_outline chalkTeal 18
        SizedBox w:10
        feature  bodyMd

    SizedBox h:20
    PRIMARY BUTTON "Start Free Trial ->" (full width)

  Footer pad H:24 V:32:
    "7-day free trial . No setup fee . Cancel anytime"  bodySm textSecond center
```

---

## 7. REUSABLE COMPONENTS

### C1 -- EmptyState
```dart
Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
  Icon(icon, size: 64, color: AppColors.inkGreen.withOpacity(0.2)),
  SizedBox(height: 16),
  Text(title, style: AppText.headingSm, textAlign: TextAlign.center),
  SizedBox(height: 8),
  Text(subtitle, style: AppText.bodySm, textAlign: TextAlign.center),
  if (actionLabel != null) ...[SizedBox(height: 24), PrimaryButton(label: actionLabel, onTap: onAction)],
]))
```

### C2 -- UpgradeBanner
```dart
// bg=brassGold10, border=1.5px brassGold, radius=12, pad=16
// Row: lock icon(brassGold,24) + Column(featureName+" locked", "Upgrade to "+plan) + TextButton("Upgrade ->")
```

### C3 -- SectionHeader
```dart
// Text(title, style: labelSm, color: textSecond, letterSpacing: 0.8)
// SizedBox(height: 8)
```

### C4 -- StatusChip
```dart
// Container(padding: H:10 V:4, radius: 999, bg=config.bg)
// Text(label, 11pt Semibold, color=config.text)
// configs: active/present/paid=chalkTeal | pending/trial/new=brassGold | expired/absent/lost=redInk | late=orange
```

### C5 -- InfoChip
```dart
// Container(bg=inkGreen10, radius=999, pad H:10 V:4)
// Row: Icon(icon, inkGreen, 12) + SizedBox(w:4) + Text(label, caption, inkGreen)
```

### C6 -- CalcRow
```dart
// Row: Text(label, bodyMd, textSecond) + Spacer + Text(value, style varies)
// Padding(V: 6)
```

### C7 -- ReceiptRow
```dart
// Row: Text(label, bodySm, textSecond) + Spacer + Text(value, labelMd, inkGreen)
// Padding(V: 6)
```

---

## 8. NAVIGATION FLOW

```
/splash
  no token -> /login
  has token:
    super_admin    -> /superadmin/dashboard
    coaching_admin -> /admin/dashboard
    teacher        -> /teacher/schedule
    student        -> /student/home

/login -> on success -> respective dashboard

Admin Drawer: Dashboard | Students | Teachers | Batches | Fees | Reports | Branding | Subscription
Teacher BottomNav: Schedule | Attendance | Content | Live
Student BottomNav: Home | Videos | Live | Fees | Profile
```

---

## 9. API BASE & AUTH

```dart
const BASE_URL_DEV  = "http://10.0.2.2:4000/api/v1"; // Android emulator
const BASE_URL_PROD = "https://YOUR_PROD_URL/api/v1";

// All protected requests:
headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer {accessToken}"
}

// On 401: POST /auth/refresh {refreshToken}
// On refresh fail: clear tokens -> /login
```

---

## 10. STRICT DESIGN RULES

### DO
- paper (#F4F6F3) = scaffold background, always
- white cards with cardShadow (black5%, blur:12, offset:0,2)
- brassGold = ONE primary CTA per screen, always with arrow icon
- chalkTeal = positive/success/selected states only
- redInk = warnings/errors ONLY, never action buttons
- Playfair Display = headings/display text
- Plus Jakarta Sans = all body/UI text
- radius 16 for cards, 12 for tiles/chips, 999 for pills
- 16px horizontal gutters everywhere
- Outlined icons only
- Soft shadows only (blurRadius max 20)

### NEVER DO
- No LinearGradient anywhere
- No red on action buttons
- No over-decorated cards
- No purple, bright blue, bright green (off-brand)
- No filled icons
- No fontSize below 11 or above 36
- No random tile background colors
- No third font families beyond Playfair Display and Plus Jakarta Sans
