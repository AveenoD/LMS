import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Helper function to check if user can access management features
Future<bool> _canAccessManagement() async {
  final prefs = await SharedPreferences.getInstance();
  final userRole = prefs.getString('user_role');
  return userRole ==
      'coaching_admin'; // Only coaching_admin can manage students, teachers, etc.
}

// Provides a list of students
final studentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return []; // Return empty list for non-coaching_admin roles
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/students');
  return response as List<dynamic>;
});

// Provides a list of teachers
final teachersProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return [];
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/teachers');
  return response as List<dynamic>;
});

// Provides a list of batches
final batchesProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return [];
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/batches');
  return response as List<dynamic>;
});

// Provides a list of subjects
final subjectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return [];
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/subjects');
  return response as List<dynamic>;
});

// Provides the timetable
final timetableProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return [];
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/timetable');
  return response as List<dynamic>;
});

// Provides fee records
final feesProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return [];
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/fees');
  return response as List<dynamic>;
});

// Provides performance reports
final performanceReportProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return {}; // Return empty map for non-coaching_admin roles
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/reports/performance');
  return response as Map<String, dynamic>;
});

// Provides branding settings
final brandingProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return {};
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/branding');
  return response as Map<String, dynamic>;
});
