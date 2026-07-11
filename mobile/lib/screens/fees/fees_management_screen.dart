import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_textfield.dart';

// ─── Main Screen ─────────────────────────────────────────────────────────────

class FeesManagementScreen extends ConsumerStatefulWidget {
  const FeesManagementScreen({super.key});

  @override
  ConsumerState<FeesManagementScreen> createState() => _FeesManagementScreenState();
}

class _FeesManagementScreenState extends ConsumerState<FeesManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Rebuild FAB whenever the tab index changes
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDialog() {
    showDialog(
      context: context,
      builder: (_) => _tabController.index == 0
          ? const _RecordPaymentDialog()
          : const _CreateFeeStructureDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feesAsync = ref.watch(feesProvider);
    final isPaymentTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFFA87D26),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Student Balances'),
            Tab(text: 'Fee Structures'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          feesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (fees) => _buildBalancesList(fees),
          ),
          _buildFeeStructuresTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDialog,
        icon: const Icon(Icons.add),
        label: Text(isPaymentTab ? 'Record Payment' : 'Add Fee Structure'),
      ),
    );
  }

  Widget _buildBalancesList(List<dynamic> fees) {
    if (fees.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF2E6656)),
            SizedBox(height: 16),
            Text(
              'No fee records yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
            ),
            SizedBox(height: 8),
            Text(
              'Record a payment or create a fee structure to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF2E6656)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(feesProvider),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: fees.length,
        itemBuilder: (context, index) {
          final fee = fees[index] as Map<String, dynamic>;
          final pending = (fee['pending'] is num) ? fee['pending'] as num : 0;
          final isPaid = pending <= 0;
          final statusColor =
              isPaid ? const Color(0xFF2E6656) : const Color(0xFFA93327);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPaid ? Icons.check_circle_outline : Icons.timelapse,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fee['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2E27),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total ${Constants.currencySymbol}${fee['total'] ?? 0}'
                          ' • Paid ${Constants.currencySymbol}${fee['paid'] ?? 0}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF2E6656)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${Constants.currencySymbol}$pending',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        isPaid ? 'Paid' : 'Pending',
                        style: TextStyle(color: statusColor, fontSize: 12),
                      ),
                    ],
                  ),
                  if (!isPaid)
                    IconButton(
                      tooltip: 'Send WhatsApp reminder',
                      icon: const Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFF2E6656),
                      ),
                      onPressed: () => _sendReminder(fee),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendReminder(Map<String, dynamic> fee) async {
    try {
      final result =
          await sendFeeReminder(ref.read(apiServiceProvider), fee['studentId'] as int);
      final waUrl = result['waUrl']?.toString() ?? '';
      if (!mounted) return;
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
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Link copied')));
              },
              child: const Text('Copy Link'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Widget _buildFeeStructuresTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2E6656).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_outlined, size: 48, color: Color(0xFF2E6656)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Fee Structures Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2E27),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fee structures automatically apply to students in a batch. '
              'Tap the button below to create one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF2E6656), height: 1.5),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _openDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Fee Structure'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Record Payment Dialog ────────────────────────────────────────────────────

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
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 16 : 32,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA87D26).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payments_outlined, color: Color(0xFFA87D26)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Record Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(foregroundColor: const Color(0xFF2E6656)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // Body
            if (_students == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_students!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'No students found. Add a student first.',
                  style: TextStyle(color: Color(0xFF2E6656)),
                ),
              )
            else ...[
              const Text(
                'Student',
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2E27), fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _studentId,
                items: _students!
                    .map((s) => DropdownMenuItem<int>(
                          value: s['id'] as int,
                          child: Text(s['fullName']?.toString() ?? ''),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _studentId = v),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Amount Paid (${Constants.currencySymbol})',
                hint: 'e.g. 2000',
                controller: _amount,
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2E27), fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _method,
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFA93327).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFA93327), fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF2E6656)),
                      foregroundColor: const Color(0xFF2E6656),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: (_saving || _students == null || _students!.isEmpty)
                        ? null
                        : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Record'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Fee Structure Dialog ──────────────────────────────────────────────

class _CreateFeeStructureDialog extends ConsumerStatefulWidget {
  const _CreateFeeStructureDialog();

  @override
  ConsumerState<_CreateFeeStructureDialog> createState() =>
      _CreateFeeStructureDialogState();
}

class _CreateFeeStructureDialogState
    extends ConsumerState<_CreateFeeStructureDialog> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
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
    _titleCtrl.dispose();
    _amountCtrl.dispose();
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
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    final amount = int.tryParse(_amountCtrl.text.trim());
    if (_titleCtrl.text.trim().isEmpty || amount == null || amount < 0) {
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
        title: _titleCtrl.text.trim(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 16 : 32,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6656).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_outlined, color: Color(0xFF2E6656)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Fee Structure',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(foregroundColor: const Color(0xFF2E6656)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // Fields
            CustomTextField(
              label: 'Title',
              hint: 'e.g. Term 1 Fee',
              controller: _titleCtrl,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Amount (${Constants.currencySymbol})',
              hint: 'e.g. 5000',
              controller: _amountCtrl,
            ),
            const SizedBox(height: 16),
            const Text(
              'Applies to Batch (optional)',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2E27), fontSize: 13),
            ),
            const SizedBox(height: 6),
            if (_batches == null)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<int?>(
                initialValue: _batchId,
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All batches')),
                  ..._batches!.map(
                    (b) => DropdownMenuItem<int?>(
                      value: b['id'] as int,
                      child: Text(b['name']?.toString() ?? ''),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _batchId = v),
              ),
            const SizedBox(height: 16),
            // Due Date Picker
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _dueDate != null
                        ? const Color(0xFFA87D26)
                        : const Color(0xFFDDE2E0),
                    width: _dueDate != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _dueDate != null ? const Color(0xFFA87D26) : const Color(0xFF2E6656),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate == null ? 'Set Due Date (optional)' : 'Due: ${_fmtDate(_dueDate!)}',
                      style: TextStyle(
                        color: _dueDate != null ? const Color(0xFFA87D26) : const Color(0xFF1F2E27).withValues(alpha: 0.5),
                        fontWeight: _dueDate != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.close, size: 16, color: Color(0xFF2E6656)),
                      ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFA93327).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFA93327), fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF2E6656)),
                      foregroundColor: const Color(0xFF2E6656),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create Structure'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
