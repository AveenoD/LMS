import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Auth
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';

// Super Admin
import 'screens/superadmin/superadmin_dashboard.dart';
import 'screens/superadmin/institutes_list.dart';
import 'screens/superadmin/register_institute.dart';
import 'screens/superadmin/plan_catalog.dart';
import 'screens/superadmin/leads_inbox.dart';
import 'screens/superadmin/subscriptions_list.dart';

// Coaching Admin
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/students_list.dart';
import 'screens/admin/teachers_list.dart';
import 'screens/admin/batches_timetable.dart';
import 'screens/admin/fee_management.dart';
import 'screens/admin/performance_reports.dart';
import 'screens/admin/branding_screen.dart';
import 'screens/admin/subscription_billing.dart';

// Teacher
import 'screens/teacher/teacher_layout.dart';
import 'screens/teacher/todays_schedule.dart';
import 'screens/teacher/mark_attendance.dart';
import 'screens/teacher/content_library.dart';
import 'screens/teacher/live_classes.dart';

// Student
import 'screens/student/student_layout.dart';
import 'screens/student/student_home.dart';
import 'screens/student/video_lectures.dart';
import 'screens/student/live_classes.dart';
import 'screens/student/fee_summary.dart';
import 'screens/student/payment_receipt.dart';
import 'screens/student/student_profile.dart';

// Public
import 'screens/public/pricing_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Auth Routes
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    
    // Public Route
    GoRoute(path: '/pricing', builder: (context, state) => const PricingPageScreen()),

    // Super Admin Routes
    GoRoute(path: '/superadmin/dashboard', builder: (context, state) => const SuperAdminDashboard()),
    GoRoute(path: '/superadmin/tenants', builder: (context, state) => const InstitutesListScreen()),
    GoRoute(path: '/superadmin/tenants/new', builder: (context, state) => const RegisterInstituteScreen()),
    GoRoute(path: '/superadmin/plans', builder: (context, state) => const PlanCatalogScreen()),
    GoRoute(path: '/superadmin/leads', builder: (context, state) => const LeadsInboxScreen()),
    GoRoute(path: '/superadmin/subscriptions', builder: (context, state) => const SubscriptionsListScreen()),

    // Coaching Admin Routes
    GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(path: '/admin/students', builder: (context, state) => const StudentsListScreen()),
    GoRoute(path: '/admin/teachers', builder: (context, state) => const TeachersListScreen()),
    GoRoute(path: '/admin/batches', builder: (context, state) => const BatchesTimetableScreen()),
    GoRoute(path: '/admin/fees', builder: (context, state) => const FeeManagementScreen()),
    GoRoute(path: '/admin/reports', builder: (context, state) => const PerformanceReportsScreen()),
    GoRoute(path: '/admin/branding', builder: (context, state) => const BrandingScreen()),
    GoRoute(path: '/admin/subscription', builder: (context, state) => const SubscriptionBillingScreen()),

    // Teacher Routes (with ShellRoute for bottom nav)
    ShellRoute(
      builder: (context, state, child) => TeacherLayout(child: child),
      routes: [
        GoRoute(path: '/teacher/schedule', builder: (context, state) => const TodaysScheduleScreen()),
        GoRoute(path: '/teacher/attendance', builder: (context, state) => const MarkAttendanceScreen()),
        GoRoute(path: '/teacher/content', builder: (context, state) => const ContentLibraryScreen()),
        GoRoute(path: '/teacher/live', builder: (context, state) => const LiveClassesScreen()),
      ],
    ),

    // Student Routes (with ShellRoute for bottom nav)
    ShellRoute(
      builder: (context, state, child) => StudentLayout(child: child),
      routes: [
        GoRoute(path: '/student/home', builder: (context, state) => const StudentHomeScreen()),
        GoRoute(path: '/student/videos', builder: (context, state) => const StudentVideoLecturesScreen()),
        GoRoute(path: '/student/live', builder: (context, state) => const StudentLiveClassesScreen()),
        GoRoute(path: '/student/fees', builder: (context, state) => const FeeSummaryScreen()),
        GoRoute(
          path: '/student/fees/receipt/:id',
          builder: (context, state) => PaymentReceiptScreen(paymentId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/student/profile', builder: (context, state) => const StudentProfileScreen()),
      ],
    ),
  ],
);
