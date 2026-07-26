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
  void _showAddQuestionModal({Map<String, dynamic>? existingQuestion}) {
    final isEditing = existingQuestion != null;
    final textCtrl = TextEditingController(text: existingQuestion?['questionText'] ?? '');
    final marksCtrl = TextEditingController(text: existingQuestion?['marks']?.toString() ?? '1');
    final imageUrlCtrl = TextEditingController(text: existingQuestion?['imageUrl'] ?? '');

    List<Map<String, dynamic>> options = isEditing
        ? ((existingQuestion['options'] as List<dynamic>?) ?? [])
            .map((o) => {
                  'id': o['id'],
                  'text': o['optionText'] ?? '',
                  'imageUrl': o['imageUrl'] ?? '',
                  'isCorrect': o['isCorrect'] ?? false,
                })
            .toList()
        : [
            {'text': '', 'imageUrl': '', 'isCorrect': true},
            {'text': '', 'imageUrl': '', 'isCorrect': false},
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Question' : 'Add Question',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Question text
                  TextField(
                    controller: textCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Question Text *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  // Question image URL (optional)
                  TextField(
                    controller: imageUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Question Image URL (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.image_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: marksCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Marks', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Select the radio button next to the correct answer', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  ...List.generate(options.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                activeColor: AppColors.success,
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
                          // Option image URL
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: TextFormField(
                              initialValue: options[i]['imageUrl'] ?? '',
                              onChanged: (val) => options[i]['imageUrl'] = val,
                              decoration: const InputDecoration(
                                hintText: 'Option image URL (optional)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                prefixIcon: Icon(Icons.image_outlined, size: 16),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (options.length < 5)
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() => options.add({'text': '', 'imageUrl': '', 'isCorrect': false}));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Option'),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      onPressed: () async {
                        if (textCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Question text is required')));
                          return;
                        }
                        // Validate: each option must have text OR imageUrl
                        final invalidOptions = options.where((o) {
                          final text = o['text']?.toString().trim() ?? '';
                          final img = o['imageUrl']?.toString().trim() ?? '';
                          return text.isEmpty && img.isEmpty;
                        }).toList();
                        if (invalidOptions.isNotEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Each option must have text or an image URL')));
                          return;
                        }

                        try {
                          final api = ref.read(apiServiceProvider);
                          final payload = {
                            'questionText': textCtrl.text.trim(),
                            if (imageUrlCtrl.text.trim().isNotEmpty) 'imageUrl': imageUrlCtrl.text.trim(),
                            'marks': int.tryParse(marksCtrl.text) ?? 1,
                            'options': options.map((o) {
                              final text = o['text']?.toString().trim() ?? '';
                              final img = o['imageUrl']?.toString().trim() ?? '';
                              return {
                                if (o['id'] != null) 'id': o['id'],
                                if (text.isNotEmpty) 'optionText': text,
                                if (img.isNotEmpty) 'imageUrl': img,
                                'isCorrect': o['isCorrect'] ?? false,
                              };
                            }).toList(),
                          };

                          if (isEditing) {
                            await api.put('/teacher/questions/${existingQuestion['id']}', payload);
                          } else {
                            await api.post('/teacher/tests/${widget.testId}/questions', payload);
                          }
                          ref.invalidate(testQuestionsProvider(widget.testId));
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                          }
                        }
                      },
                      child: Text(isEditing ? 'Update Question' : 'Save Question', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _deleteQuestion(int questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final api = ref.read(apiServiceProvider);
      await api.delete('/teacher/questions/$questionId');
      ref.invalidate(testQuestionsProvider(widget.testId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No questions added yet.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first question.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final q = questions[index];
              final options = (q['options'] as List<dynamic>?) ?? [];
              final qImage = q['imageUrl']?.toString();

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
                        Container(
                          width: 28, height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(q['questionText'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                        Text('[${q['marks']} M]', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    // Question image preview
                    if (qImage != null && qImage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 38),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            qImage,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 40,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ...options.map((opt) {
                      final isCorrect = opt['isCorrect'] == true;
                      final optImg = opt['imageUrl']?.toString();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isCorrect ? Colors.green : Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(isCorrect ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: isCorrect ? Colors.green : Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    opt['optionText'] ?? (optImg != null && optImg.isNotEmpty ? '[Image option]' : ''),
                                    style: TextStyle(color: isCorrect ? Colors.green.shade700 : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            if (optImg != null && optImg.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 24),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    optImg,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddQuestionModal(existingQuestion: q),
                          icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                          label: const Text('Edit', style: TextStyle(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 4),
                        TextButton.icon(
                          onPressed: () => _deleteQuestion(q['id'] as int),
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQuestionModal(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Question', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
