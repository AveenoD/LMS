import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/management_providers.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

Future<void> showAddFeeStructureBottomSheet(BuildContext context, WidgetRef ref) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _AddFeeStructureBottomSheet(),
  );
}

class _AddFeeStructureBottomSheet extends ConsumerStatefulWidget {
  const _AddFeeStructureBottomSheet();

  @override
  ConsumerState<_AddFeeStructureBottomSheet> createState() => _AddFeeStructureBottomSheetState();
}

class _AddFeeStructureBottomSheetState extends ConsumerState<_AddFeeStructureBottomSheet> {
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

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1F2E27), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2E27))),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: prefixIcon == Icons.currency_rupee ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRequired) const Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(width: 16),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 40),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFF4F6F3),
                        radius: 24,
                        child: Icon(Icons.receipt_outlined, color: Color(0xFF1F2E27), size: 28),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Color(0xFFA87D26), shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 12),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Fee Structure',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                        ),
                        const SizedBox(height: 4),
                        Text('Create a new fee plan for students', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close, size: 18, color: Colors.black87),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _buildSectionHeader(Icons.edit_note, 'Fee Details', 'Provide basic information'),
                          _buildInputField(
                            controller: _titleCtrl,
                            hint: 'e.g. Term 1 Fee',
                            prefixIcon: Icons.title,
                            isRequired: true,
                          ),
                          _buildInputField(
                            controller: _amountCtrl,
                            hint: 'Amount (e.g. 5000)',
                            prefixIcon: Icons.currency_rupee,
                            isRequired: true,
                          ),
                          const SizedBox(height: 12),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Applies to Batch (optional)',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2E27), fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_batches == null)
                            const Center(child: CircularProgressIndicator())
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  isExpanded: true,
                                  value: _batchId,
                                  hint: const Text('All batches'),
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
                              ),
                            ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickDueDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _dueDate != null
                                      ? const Color(0xFFA87D26)
                                      : Colors.grey.shade300,
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
                                    color: _dueDate != null ? const Color(0xFFA87D26) : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _dueDate == null ? 'Set Due Date (optional)' : 'Due: ${_fmtDate(_dueDate!)}',
                                    style: TextStyle(
                                      color: _dueDate != null ? const Color(0xFFA87D26) : Colors.grey.shade600,
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
                        ],
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA93327).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA93327).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFA93327), size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFA93327), fontSize: 13))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF1F2E27), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2E27),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Create Structure', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
