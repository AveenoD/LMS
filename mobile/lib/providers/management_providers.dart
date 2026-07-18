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
final feesProvider = FutureProvider.family<List<dynamic>, String?>((ref, status) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return [];
  }
  final api = ref.watch(apiServiceProvider);
  String endpoint = '/admin/fees';
  if (status != null && status.isNotEmpty && status != 'all') {
    endpoint += '?status=$status';
  }
  final response = await api.get(endpoint);
  return response as List<dynamic>;
});

// Provides fee analytics data
final feeAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return {};
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/fees/analytics');
  return response as Map<String, dynamic>;
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

// Provides the logged-in coaching_admin's own notification inbox
final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return [];
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/notifications');
  return response as List<dynamic>;
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final canAccess = await _canAccessManagement();
  if (!canAccess) {
    return 0;
  }
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/admin/notifications/unread-count') as Map<String, dynamic>;
  return response['count'] as int? ?? 0;
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

Future<void> updateStudent(ApiService api, int id, {
  String? fullName,
  String? phone,
  String? password,
  String? parentPhone,
  int? batchId,
  String? parentName,
  String? grade,
  String? rollNo,
}) async {
  final body = <String, dynamic>{
    if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
    if (phone != null && phone.isNotEmpty) 'phone': phone,
    if (password != null && password.isNotEmpty) 'password': password,
    if (parentPhone != null && parentPhone.isNotEmpty) 'parentPhone': parentPhone,
    if (batchId != null) 'batchId': batchId,
    if (parentName != null) 'parentName': parentName,
    if (grade != null) 'grade': grade,
    if (rollNo != null) 'rollNo': rollNo,
  };
  await api.put('/admin/students/$id', body);
}

Future<void> deleteStudent(ApiService api, int id) async {
  await api.delete('/admin/students/$id');
}

Future<Map<String, dynamic>> suspendStudent(ApiService api, int id) async {
  return await api.patch('/admin/students/$id/suspend', {}) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> getStudentDetails(ApiService api, int id) async {
  return await api.get('/admin/students/$id/details') as Map<String, dynamic>;
}

final studentDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return getStudentDetails(api, id);
});

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
    'subjectId': ?subjectId,
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
    'batchId': ?batchId,
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
    'feeStructureId': ?feeStructureId,
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

Future<void> markNotificationRead(ApiService api, int id) async {
  await api.patch('/admin/notifications/$id/read', {});
}

/// Broadcasts a notification to students in the caller's own institute —
/// every student, or filtered by batch. Returns `{recipientCount}`.
Future<Map<String, dynamic>> broadcastToStudents(
  ApiService api, {
  required String title,
  String? body,
  int? batchId,
}) async {
  final requestBody = <String, dynamic>{
    'title': title,
    if (body != null && body.isNotEmpty) 'body': body,
    'batchId': ?batchId,
  };
  return await api.post('/admin/notifications/broadcast', requestBody) as Map<String, dynamic>;
}
