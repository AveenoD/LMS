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
