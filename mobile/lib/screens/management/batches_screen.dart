import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_textfield.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: batchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (batches) {
          if (batches.isEmpty) return const Center(child: Text('No batches found.'));
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(batchesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              batch['name'] ?? 'Unknown Batch',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (batch['grade'] != null)
                              Chip(
                                label: Text(batch['grade'].toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                backgroundColor: Colors.green.shade400,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${batch['studentCount'] ?? 0} students enrolled', style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const _AddBatchDialog()),
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Batch', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _AddBatchDialog extends ConsumerStatefulWidget {
  const _AddBatchDialog();

  @override
  ConsumerState<_AddBatchDialog> createState() => _AddBatchDialogState();
}

class _AddBatchDialogState extends ConsumerState<_AddBatchDialog> {
  final _name = TextEditingController();
  final _grade = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _grade.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Batch name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await createBatch(ref.read(apiServiceProvider), name: _name.text.trim(), grade: _grade.text.trim());
      ref.invalidate(batchesProvider);
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
      title: const Text('Create Batch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(label: 'Batch Name', hint: 'e.g. JEE 2026 Morning', controller: _name),
          const SizedBox(height: 12),
          CustomTextField(label: 'Grade (optional)', hint: 'e.g. Class 11', controller: _grade),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }
}
