import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_textfield.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('No students found.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(studentsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index] as Map<String, dynamic>;
                final rollNo = student['rollNo'];
                final grade = student['grade'];
                final subtitleParts = <String>[
                  if (rollNo != null && rollNo.toString().isNotEmpty) 'Roll No: $rollNo',
                  if (grade != null && grade.toString().isNotEmpty) grade.toString(),
                ];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E6656).withValues(alpha: 0.12),
                      child: Icon(Icons.person, color: const Color(0xFF1F2E27)),
                    ),
                    title: Text(student['fullName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subtitleParts.isEmpty ? student['phone']?.toString() ?? '' : subtitleParts.join(' • ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ref, student),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Map<String, dynamic> student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove student?'),
        content: Text('${student['fullName'] ?? 'This student'} will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await deleteStudent(ref.read(apiServiceProvider), student['id'] as int);
      ref.invalidate(studentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student removed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showAddStudentDialog(BuildContext context, WidgetRef ref) async {
    final batches = await ref.read(batchesProvider.future);
    if (!context.mounted) return;
    if (batches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a batch first — a student must be enrolled in one.')),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (_) => _AddStudentDialog(batches: batches.cast<Map<String, dynamic>>()),
    );
  }
}

class _AddStudentDialog extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> batches;
  const _AddStudentDialog({required this.batches});

  @override
  ConsumerState<_AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends ConsumerState<_AddStudentDialog> {
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _parentName = TextEditingController();
  final _parentPhone = TextEditingController();
  final _grade = TextEditingController();
  final _rollNo = TextEditingController();
  int? _batchId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _batchId = widget.batches.first['id'] as int?;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _password.dispose();
    _parentName.dispose();
    _parentPhone.dispose();
    _grade.dispose();
    _rollNo.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_fullName.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _password.text.isEmpty ||
        _parentPhone.text.trim().isEmpty ||
        _batchId == null) {
      setState(() => _error = 'Full name, phone, password, parent phone and batch are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await createStudent(
        ref.read(apiServiceProvider),
        fullName: _fullName.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        parentPhone: _parentPhone.text.trim(),
        batchId: _batchId!,
        parentName: _parentName.text.trim(),
        grade: _grade.text.trim(),
        rollNo: _rollNo.text.trim(),
      );
      ref.invalidate(studentsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Student'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(label: 'Full Name', hint: 'Student name', controller: _fullName),
            const SizedBox(height: 12),
            CustomTextField(label: 'Phone', hint: '10-15 digit login phone', controller: _phone),
            const SizedBox(height: 12),
            CustomTextField(label: 'Password', hint: 'Min 6 characters', isPassword: true, controller: _password),
            const SizedBox(height: 12),
            CustomTextField(label: 'Parent Phone', hint: 'For WhatsApp reminders', controller: _parentPhone),
            const SizedBox(height: 12),
            CustomTextField(label: 'Parent Name (optional)', hint: 'Parent/guardian name', controller: _parentName),
            const SizedBox(height: 12),
            CustomTextField(label: 'Grade (optional)', hint: 'e.g. Class 11', controller: _grade),
            const SizedBox(height: 12),
            CustomTextField(label: 'Roll No (optional)', hint: 'Roll number', controller: _rollNo),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Batch', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _batchId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: widget.batches
                  .map((b) => DropdownMenuItem<int>(value: b['id'] as int, child: Text(b['name']?.toString() ?? '')))
                  .toList(),
              onChanged: (v) => setState(() => _batchId = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }
}
