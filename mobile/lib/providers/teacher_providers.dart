import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class TeacherShellTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setTab(int index) => state = index;
}

final teacherShellTabIndexProvider = NotifierProvider<TeacherShellTabIndexNotifier, int>(() {
  return TeacherShellTabIndexNotifier();
});

final todayScheduleProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/teacher/schedule/today');
});

final myBatchesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/teacher/batches');
});

final batchStudentsProvider = FutureProvider.family<List<dynamic>, int>((ref, batchId) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/teacher/batches/$batchId/students');
});

final attendanceBatchStudentsProvider = FutureProvider.family<List<dynamic>, ({int batchId, String date})>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final batchId = params.batchId;
  final date = params.date;
  return await api.get('/teacher/batches/$batchId/students?date=$date');
});

final testsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/teacher/tests');
});

final testQuestionsProvider = FutureProvider.family<List<dynamic>, int>((ref, testId) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/teacher/tests/$testId/questions');
});

final teacherContentProvider = FutureProvider.family<List<dynamic>, int?>((ref, chapterId) async {
  final api = ref.read(apiServiceProvider);
  final query = chapterId != null ? '?chapterId=$chapterId' : '';
  return await api.get('/teacher/content$query');
});

final teacherSubjectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/teacher/subjects');
});

final teacherChaptersProvider = FutureProvider.family<List<dynamic>, int?>((ref, subjectId) async {
  final api = ref.read(apiServiceProvider);
  final query = subjectId != null ? '?subjectId=$subjectId' : '';
  return await api.get('/teacher/chapters$query');
});

/// Same report shape as admin's `studentDetailsProvider` — same backend
/// data (admin.service.getStudentDetails), just via the teacher-scoped
/// route that checks the student is in one of this teacher's batches.
final teacherStudentDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, studentId) async {
  final api = ref.read(apiServiceProvider);
  return await api.get('/teacher/students/$studentId/details') as Map<String, dynamic>;
});
