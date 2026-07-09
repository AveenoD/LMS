import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_textfield.dart';

class FeesManagementScreen extends ConsumerWidget {
  const FeesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(feesProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fees Management'),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Student Balances'),
              Tab(text: 'Fee Structures'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            feesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (fees) => _buildBalancesList(context, ref, fees),
            ),
            _buildFeeStructuresTab(context, ref),
          ],
        ),
        floatingActionButton: Builder(
          builder: (ctx) {
            final tabIndex = DefaultTabController.of(ctx).index;
            return FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => tabIndex == 0 ? const _RecordPaymentDialog() : const _CreateFeeStructureDialog(),
              ),
              backgroundColor: primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(tabIndex == 0 ? 'Record Payment' : 'Add Fee Structure', style: const TextStyle(color: Colors.white)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalancesList(BuildContext context, WidgetRef ref, List<dynamic> fees) {
    if (fees.isEmpty) return const Center(child: Text('No student fee records yet.'));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(feesProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fees.length,
        itemBuilder: (context, index) {
          final fee = fees[index] as Map<String, dynamic>;
          final pending = (fee['pending'] is num) ? fee['pending'] as num : 0;
          final isPaid = pending <= 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.timelapse,
                      color: isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fee['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Total ${Constants.currencySymbol}${fee['total'] ?? 0} • Paid ${Constants.currencySymbol}${fee['paid'] ?? 0}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${Constants.currencySymbol}$pending',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isPaid ? Colors.green : Colors.orange,
                        ),
                      ),
                      Text(isPaid ? 'Paid' : 'Pending', style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontSize: 12)),
                    ],
                  ),
                  if (!isPaid)
                    IconButton(
                      tooltip: 'Send WhatsApp reminder',
                      icon: const Icon(Icons.notifications_active_outlined, color: Colors.teal),
                      onPressed: () => _sendReminder(context, ref, fee),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendReminder(BuildContext context, WidgetRef ref, Map<String, dynamic> fee) async {
    try {
      final result = await sendFeeReminder(ref.read(apiServiceProvider), fee['studentId'] as int);
      final waUrl = result['waUrl']?.toString() ?? '';
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('WhatsApp reminder link'),
          content: SelectableText(waUrl),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: waUrl));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
              },
              child: const Text('Copy Link'),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildFeeStructuresTab(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'Fee structures you create appear on student balances automatically.\n'
          'Use "Add Fee Structure" below to create one for a batch.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class _RecordPaymentDialog extends ConsumerStatefulWidget {
  const _RecordPaymentDialog();

  @override
  ConsumerState<_RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<_RecordPaymentDialog> {
  final _amount = TextEditingController();
  int? _studentId;
  String _method = 'cash';
  bool _saving = false;
  String? _error;
  List<Map<String, dynamic>>? _students;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final list = await ref.read(studentsProvider.future);
    if (!mounted) return;
    setState(() {
      _students = list.cast<Map<String, dynamic>>();
      if (_students!.isNotEmpty) _studentId = _students!.first['id'] as int?;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amount.text.trim());
    if (_studentId == null || amount == null || amount < 1) {
      setState(() => _error = 'Choose a student and enter a valid amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await recordPayment(
        ref.read(apiServiceProvider),
        studentId: _studentId!,
        amountPaid: amount,
        method: _method,
      );
      ref.invalidate(feesProvider);
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
      title: const Text('Record Payment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_students == null)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            else if (_students!.isEmpty)
              const Text('No students yet — add a student first.')
            else ...[
              const Text('Student', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _studentId,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                items: _students!
                    .map((s) => DropdownMenuItem<int>(value: s['id'] as int, child: Text(s['fullName']?.toString() ?? '')))
                    .toList(),
                onChanged: (v) => setState(() => _studentId = v),
              ),
              const SizedBox(height: 14),
              CustomTextField(label: 'Amount Paid (${Constants.currencySymbol})', hint: 'e.g. 2000', controller: _amount),
              const SizedBox(height: 14),
              const Text('Method', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                ],
                onChanged: (v) => setState(() => _method = v ?? 'cash'),
              ),
            ],
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
          onPressed: (_saving || _students == null || _students!.isEmpty) ? null : _submit,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Record'),
        ),
      ],
    );
  }
}

class _CreateFeeStructureDialog extends ConsumerStatefulWidget {
  const _CreateFeeStructureDialog();

  @override
  ConsumerState<_CreateFeeStructureDialog> createState() => _CreateFeeStructureDialogState();
}

class _CreateFeeStructureDialogState extends ConsumerState<_CreateFeeStructureDialog> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  int? _batchId;
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;
  List<Map<String, dynamic>>? _batches;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final list = await ref.read(batchesProvider.future);
    if (!mounted) return;
    setState(() => _batches = list.cast<Map<String, dynamic>>());
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    final amount = int.tryParse(_amount.text.trim());
    if (_title.text.trim().isEmpty || amount == null || amount < 0) {
      setState(() => _error = 'Title and a valid amount are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await createFeeStructure(
        ref.read(apiServiceProvider),
        title: _title.text.trim(),
        amount: amount,
        batchId: _batchId,
        dueDate: _dueDate != null ? _fmtDate(_dueDate!) : null,
      );
      ref.invalidate(feesProvider);
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
      title: const Text('Add Fee Structure'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(label: 'Title', hint: 'e.g. Term 1 Fee', controller: _title),
            const SizedBox(height: 12),
            CustomTextField(label: 'Amount (${Constants.currencySymbol})', hint: 'e.g. 5000', controller: _amount),
            const SizedBox(height: 14),
            const Text('Applies to batch (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            if (_batches == null)
              const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator())
            else
              DropdownButtonFormField<int?>(
                initialValue: _batchId,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All batches')),
                  ..._batches!.map((b) => DropdownMenuItem<int?>(value: b['id'] as int, child: Text(b['name']?.toString() ?? ''))),
                ],
                onChanged: (v) => setState(() => _batchId = v),
              ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _pickDueDate,
              child: Text(_dueDate == null ? 'Set Due Date (optional)' : 'Due: ${_fmtDate(_dueDate!)}'),
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
              : const Text('Create'),
        ),
      ],
    );
  }
}
