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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Reports'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Batch Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            batchesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (batches) {
                if (batches.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<int?>(
                  initialValue: selectedBatch,
                  decoration: const InputDecoration(
                    labelText: 'Filter by batch',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('All batches')),
                    ...batches.cast<Map<String, dynamic>>().map(
                          (b) => DropdownMenuItem<int?>(value: b['id'] as int, child: Text(b['name']?.toString() ?? '')),
                        ),
                  ],
                  onChanged: (v) => ref.read(_selectedBatchProvider.notifier).set(v),
                );
              },
            ),
            const SizedBox(height: 20),
            reportAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
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
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        'Avg Marks',
                        avgMarks == null ? 'No data' : '$avgMarks%',
                        Icons.grade,
                        Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Based on attendance records and test results entered for this institute. '
              'Per-student rankings aren’t available yet.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.invalidate(performanceReportProvider(selectedBatch)),
        backgroundColor: primary,
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text('Refresh', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
