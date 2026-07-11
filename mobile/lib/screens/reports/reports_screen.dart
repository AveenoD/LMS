import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';

class _SelectedBatchNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? value) => state = value;
}

final _selectedBatchProvider = NotifierProvider<_SelectedBatchNotifier, int?>(_SelectedBatchNotifier.new);

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBatch = ref.watch(_selectedBatchProvider);
    final reportAsync = ref.watch(performanceReportProvider(selectedBatch));
    final batchesAsync = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Analytics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
            ),
            const SizedBox(height: 12),
            batchesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (batches) {
                if (batches.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<int?>(
                  initialValue: selectedBatch,
                  decoration: const InputDecoration(labelText: 'Filter by batch', isDense: true),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('All batches')),
                    ...batches.cast<Map<String, dynamic>>().map(
                          (b) => DropdownMenuItem<int?>(
                            value: b['id'] as int,
                            child: Text(b['name']?.toString() ?? ''),
                          ),
                        ),
                  ],
                  onChanged: (v) => ref.read(_selectedBatchProvider.notifier).set(v),
                );
              },
            ),
            const SizedBox(height: 24),
            reportAsync.when(
              loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Color(0xFFA93327))),
              ),
              data: (report) {
                final avgAttendance = report['avgAttendance'];
                final avgMarks = report['avgMarksPct'];
                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Avg Attendance',
                        avgAttendance == null ? 'No data' : '$avgAttendance%',
                        Icons.event_available,
                        const Color(0xFF2E6656),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        'Avg Marks',
                        avgMarks == null ? 'No data' : '$avgMarks%',
                        Icons.grade,
                        const Color(0xFFA87D26),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              "Based on attendance records and test results entered for this institute. "
              "Per-student rankings aren't available yet.",
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2E6656).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.invalidate(performanceReportProvider(selectedBatch)),
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2E6656), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
