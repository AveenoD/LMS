import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// ─── Student Dashboard (single endpoint returns everything) ──────────────────

final studentDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.get('/student/dashboard');
  return data as Map<String, dynamic>;
});

// ─── Student Learn / Subjects ────────────────────────────────────────────────

final studentSubjectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/subjects') as List<dynamic>;
});

final studentChaptersProvider = FutureProvider.family<List<dynamic>, int>((ref, subjectId) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/subjects/$subjectId/chapters') as List<dynamic>;
});

final studentChapterContentProvider = FutureProvider.family<List<dynamic>, int>((ref, chapterId) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/chapters/$chapterId/content') as List<dynamic>;
});

// ─── Today's Live Classes ────────────────────────────────────────────────────

final studentTodayLiveProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/live/today') as List<dynamic>;
});

// ─── Student Fees ────────────────────────────────────────────────────────────

final studentFeesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/fees') as Map<String, dynamic>;
});

// ─── Notifications ───────────────────────────────────────────────────────────

final studentNotificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/notifications') as List<dynamic>;
});
// ─── Tests & Quiz ────────────────────────────────────────────────────────────

final studentTestsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/tests') as Map<String, dynamic>;
});

// ─── Profile ─────────────────────────────────────────────────────────────────

final studentProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/profile') as Map<String, dynamic>;
});

final studentAttendanceProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/attendance/monthly') as List<dynamic>;
});

final studentPerformanceProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/student/performance') as List<dynamic>;
});
