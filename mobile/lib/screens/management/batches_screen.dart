import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

import 'batch_students_screen.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2E27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Batches', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            Text(
              'Manage your classroom batches and grades',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: batchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (batches) {
          int totalStudents = 0;
          for (var b in batches) {
            totalStudents += (b['studentCount'] as int? ?? 0);
          }
          final avgSize = batches.isEmpty ? 0 : (totalStudents / batches.length).round();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(batchesProvider),
            child: CustomScrollView(
              slivers: [
                if (batches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatCard('Total Batches', '${batches.length}', Icons.class_outlined, const Color(0xFF2E6656))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatCard('Enrolled Students', '$totalStudents', Icons.people_outline, Colors.blue.shade700)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatCard('Avg. Batch Size', '$avgSize', Icons.pie_chart_outline, Colors.orange.shade700)),
                        ],
                      ),
                    ),
                  ),
                ],
                if (batches.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.class_outlined, size: 64, color: Color(0xFF2E6656)),
                          const SizedBox(height: 16),
                          const Text('No batches yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27))),
                          const SizedBox(height: 8),
                          const Text('Tap "Create Batch" to add your first batch.', style: TextStyle(color: Color(0xFF2E6656))),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final batch = batches[index] as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BatchStudentsScreen(
                                      batchId: batch['id'] as int,
                                      batchName: batch['name']?.toString() ?? 'Batch',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E6656).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.class_outlined, color: Color(0xFF2E6656)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              batch['name'] ?? 'Unknown Batch',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('${batch['studentCount'] ?? 0} students enrolled',
                                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      if (batch['grade'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFA87D26).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(batch['grade'].toString(),
                                              style: const TextStyle(color: Color(0xFFA87D26), fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: batches.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const _AddBatchBottomSheet(),
        ),
        backgroundColor: const Color(0xFF1F2E27),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Batch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF1F2E27), fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddBatchBottomSheet extends ConsumerStatefulWidget {
  const _AddBatchBottomSheet();

  @override
  ConsumerState<_AddBatchBottomSheet> createState() => _AddBatchBottomSheetState();
}

class _AddBatchBottomSheetState extends ConsumerState<_AddBatchBottomSheet> {
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
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create New Batch',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Batch Name',
              hint: 'e.g. Class 11 Morning',
              controller: _name,
              prefixIcon: Icons.class_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Grade/Class (Optional)',
              hint: 'e.g. Class 11',
              controller: _grade,
              prefixIcon: Icons.grade_outlined,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 52,
                    child: CustomButton(
                      text: 'Create Batch',
                      onPressed: _submit,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
