import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/teacher_providers.dart';
import '../../services/api_service.dart';

class QuizEditorScreen extends ConsumerStatefulWidget {
  final int testId;
  final String testTitle;

  const QuizEditorScreen({super.key, required this.testId, required this.testTitle});

  @override
  ConsumerState<QuizEditorScreen> createState() => _QuizEditorScreenState();
}

class _QuizEditorScreenState extends ConsumerState<QuizEditorScreen> {
  void _showAddQuestionModal() {
    // Basic Add Question Form
    final textCtrl = TextEditingController();
    final marksCtrl = TextEditingController(text: '1');
    List<Map<String, dynamic>> options = [
      {'text': '', 'isCorrect': true},
      {'text': '', 'isCorrect': false},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Question', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 16),
                  TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Question Text', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: marksCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Marks', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  const Text('Options', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(options.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: options.indexWhere((o) => o['isCorrect'] == true),
                            onChanged: (val) {
                              setModalState(() {
                                for (var o in options) { o['isCorrect'] = false; }
                                options[val!]['isCorrect'] = true;
                              });
                            },
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: options[i]['text'],
                              onChanged: (val) => options[i]['text'] = val,
                              decoration: InputDecoration(
                                hintText: 'Option ${i + 1}',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          if (options.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setModalState(() => options.removeAt(i));
                              },
                            )
                        ],
                      ),
                    );
                  }),
                  if (options.length < 5)
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() => options.add({'text': '', 'isCorrect': false}));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Option'),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      onPressed: () async {
                        if (textCtrl.text.isEmpty) return;
                        if (options.any((o) => o['text'].toString().trim().isEmpty)) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('All options must have text')));
                          return;
                        }

                        try {
                          final api = ref.read(apiServiceProvider);
                          await api.post('/teacher/tests/${widget.testId}/questions', {
                            'questionText': textCtrl.text,
                            'marks': int.tryParse(marksCtrl.text) ?? 1,
                            'options': options.map((o) => {'optionText': o['text'], 'isCorrect': o['isCorrect']}).toList(),
                          });
                          ref.invalidate(testQuestionsProvider(widget.testId));
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Save Question'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(testQuestionsProvider(widget.testId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.testTitle, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No questions added yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final q = questions[index];
              final options = (q['options'] as List<dynamic>?) ?? [];
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(q['questionText'] ?? '', style: const TextStyle(fontSize: 16))),
                        Text('[${q['marks']} M]', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...options.map((opt) {
                      final isCorrect = opt['isCorrect'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isCorrect ? Colors.green : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(isCorrect ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: isCorrect ? Colors.green : Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(opt['optionText'] ?? '', style: TextStyle(color: isCorrect ? Colors.green.shade700 : Colors.black87))),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddQuestionModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Question', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
