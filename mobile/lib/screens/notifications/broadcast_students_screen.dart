import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

/// Coaching Admin composes a notification for students in their own
/// institute — everyone, or filtered to one batch.
class BroadcastStudentsScreen extends ConsumerStatefulWidget {
  const BroadcastStudentsScreen({super.key});

  @override
  ConsumerState<BroadcastStudentsScreen> createState() => _BroadcastStudentsScreenState();
}

class _BroadcastStudentsScreenState extends ConsumerState<BroadcastStudentsScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  int? _batchId;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final result = await broadcastToStudents(
        ref.read(apiServiceProvider),
        title: _title.text.trim(),
        body: _body.text.trim(),
        batchId: _batchId,
      );
      if (mounted) {
        final count = result['recipientCount'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent to $count student(s).')),
        );
        _title.clear();
        _body.clear();
        setState(() {
          _batchId = null;
          _sending = false;
        });
      }
    } catch (e) {
      setState(() {
        _sending = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final batchesAsync = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Announcement'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This goes to your students — everyone, or just one batch.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              CustomTextField(label: 'Title', hint: 'e.g. Holiday tomorrow', controller: _title),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Message (optional)',
                hint: 'Details for the students',
                controller: _body,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Batch (optional)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
              ),
              const SizedBox(height: 8),
              batchesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => Text('$err', style: const TextStyle(color: Colors.red)),
                data: (batches) => DropdownButtonFormField<int?>(
                  initialValue: _batchId,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  hint: const Text('Every batch'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Every batch')),
                    ...batches.cast<Map<String, dynamic>>().map(
                          (b) => DropdownMenuItem<int?>(value: b['id'] as int, child: Text(b['name']?.toString() ?? '')),
                        ),
                  ],
                  onChanged: (v) => setState(() => _batchId = v),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              _sending
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: CustomButton(text: 'Send', onPressed: _send),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
