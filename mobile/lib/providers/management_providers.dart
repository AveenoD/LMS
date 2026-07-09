import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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

// Provides performance reports. `batchId` is optional — null means "all
// batches", matching the backend's `GET /admin/reports/performance?batchId=`.
final performanceReportProvider = FutureProvider.family<Map<String, dynamic>, int?>((
  ref,
  batchId,
) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return {}; // Return empty map for non-coaching_admin roles
  }
  final api = ref.watch(apiServiceProvider);
  final endpoint = batchId != null ? '/admin/reports/performance?batchId=$batchId' : '/admin/reports/performance';
  final response = await api.get(endpoint);
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

// ─────────────────────────── Write actions ───────────────────────────
// Plain helper functions (not providers) — screens call these directly via
// `ref.read(apiServiceProvider)`, then `ref.invalidate(...)` the relevant
// list provider above to refetch. Every endpoint/method/body shape here
// matches the backend's admin routes + zod validators exactly.

Future<Map<String, dynamic>> createTeacher(ApiService api, {
  required String fullName,
  required String phone,
  required String password,
  String? email,
}) async {
  final body = <String, dynamic>{
    'fullName': fullName,
    'phone': phone,
    'password': password,
    if (email != null && email.isNotEmpty) 'email': email,
  };
  return await api.post('/admin/teachers', body) as Map<String, dynamic>;
}

Future<void> deleteTeacher(ApiService api, int id) async {
  await api.delete('/admin/teachers/$id');
}

Future<Map<String, dynamic>> createStudent(ApiService api, {
  required String fullName,
  required String phone,
  required String password,
  required String parentPhone,
  required int batchId,
  String? parentName,
  String? grade,
  String? rollNo,
}) async {
  final body = <String, dynamic>{
    'fullName': fullName,
    'phone': phone,
    'password': password,
    'parentPhone': parentPhone,
    'batchId': batchId,
    if (parentName != null && parentName.isNotEmpty) 'parentName': parentName,
    if (grade != null && grade.isNotEmpty) 'grade': grade,
    if (rollNo != null && rollNo.isNotEmpty) 'rollNo': rollNo,
  };
  return await api.post('/admin/students', body) as Map<String, dynamic>;
}

Future<void> deleteStudent(ApiService api, int id) async {
  await api.delete('/admin/students/$id');
}

Future<Map<String, dynamic>> createBatch(ApiService api, {
  required String name,
  String? grade,
}) async {
  final body = <String, dynamic>{
    'name': name,
    if (grade != null && grade.isNotEmpty) 'grade': grade,
  };
  return await api.post('/admin/batches', body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> createSubject(ApiService api, {required String name}) async {
  return await api.post('/admin/subjects', {'name': name}) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> createTimetableEntry(ApiService api, {
  required int batchId,
  required int teacherId,
  required int dayOfWeek,
  required String startTime,
  required String endTime,
  int? subjectId,
}) async {
  final body = <String, dynamic>{
    'batchId': batchId,
    'teacherId': teacherId,
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    if (subjectId != null) 'subjectId': subjectId,
  };
  return await api.post('/admin/timetable', body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> createFeeStructure(ApiService api, {
  required String title,
  required int amount,
  int? batchId,
  String? dueDate,
}) async {
  final body = <String, dynamic>{
    'title': title,
    'amount': amount,
    if (batchId != null) 'batchId': batchId,
    if (dueDate != null && dueDate.isNotEmpty) 'dueDate': dueDate,
  };
  return await api.post('/admin/fees/structures', body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> recordPayment(ApiService api, {
  required int studentId,
  required int amountPaid,
  String method = 'cash',
  int? feeStructureId,
}) async {
  final body = <String, dynamic>{
    'studentId': studentId,
    'amountPaid': amountPaid,
    'method': method,
    if (feeStructureId != null) 'feeStructureId': feeStructureId,
  };
  return await api.post('/admin/fees/payments', body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> sendFeeReminder(ApiService api, int studentId) async {
  return await api.post('/admin/fees/$studentId/remind', {}) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> updateBranding(ApiService api, {
  String? logoUrl,
  String? primaryColor,
}) async {
  final body = <String, dynamic>{
    if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
    if (primaryColor != null && primaryColor.isNotEmpty) 'primaryColor': primaryColor,
  };
  return await api.put('/admin/branding', body) as Map<String, dynamic>;
}
