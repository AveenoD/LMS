import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Provides a list of students
final studentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/students');
  return response as List<dynamic>;
});

// Provides a list of teachers
final teachersProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/teachers');
  return response as List<dynamic>;
});

// Provides a list of batches
final batchesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/batches');
  return response as List<dynamic>;
});

// Provides a list of subjects
final subjectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/subjects');
  return response as List<dynamic>;
});

// Provides the timetable
final timetableProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/timetable');
  return response as List<dynamic>;
});

// Provides fee records
final feesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/fees');
  return response as List<dynamic>;
});

// Provides performance reports
final performanceReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/reports/performance');
  return response as Map<String, dynamic>;
});

// Provides branding settings
final brandingProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/branding');
  return response as Map<String, dynamic>;
});
