import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/teacher_providers.dart';
import '../../services/api_service.dart';
import 'quiz_editor_screen.dart';

class TeacherManageTestsScreen extends ConsumerWidget {
  const TeacherManageTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Quizzes & Tests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: testsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tests) {
          if (tests.isEmpty) {
            return const Center(child: Text('No tests created yet. Tap + to create one.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final test = tests[index];
              final isOnline = test['is_online'] == true;
              final duration = test['duration_minutes'];
              final questionCount = int.tryParse(test['question_count']?.toString() ?? '0') ?? 0;
              final dateStr = test['test_date'] != null 
                  ? DateFormat('dd MMM yyyy').format(DateTime.parse(test['test_date']))
                  : 'No Date';

              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => QuizEditorScreen(
                      testId: test['id'],
                      testTitle: test['title'],
                    )
                  ));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              test['title'] ?? 'Untitled', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.blue.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOnline ? 'Online MCQ' : 'Offline',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOnline ? Colors.blue : Colors.orange),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Batch: ${test['batch_name'] ?? 'All'} | Subject: ${test['subject_name'] ?? 'General'}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          const SizedBox(width: 16),
                          Icon(Icons.timer, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(duration != null ? '$duration mins' : 'Untimed', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          const Spacer(),
                          Text('$questionCount Qs', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTestModal(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Quiz', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showCreateTestModal(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    bool isOnline = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create New Quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 24),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Quiz Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (Minutes)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is Online MCQ Quiz?'),
                  subtitle: const Text('If off, it acts as an offline test record.'),
                  value: isOnline,
                  onChanged: (val) => setModalState(() => isOnline = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    onPressed: () async {
                      if (titleCtrl.text.isEmpty) return;
                      try {
                        final api = ref.read(apiServiceProvider);
                        await api.post('/teacher/tests', {
                          'title': titleCtrl.text,
                          'durationMinutes': int.tryParse(durationCtrl.text),
                          'isOnline': isOnline,
                        });
                        ref.invalidate(testsProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text('Create Quiz'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
      },
    );
  }
}
