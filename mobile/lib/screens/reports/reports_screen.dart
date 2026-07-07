import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(performanceReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Reports'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (report) {
          final topPerformers = report['topPerformers'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Batch Analytics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Average Score', '${report['averageScore'] ?? 0}%', Icons.analytics, Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMetricCard('Pass Rate', '${report['passRate'] ?? 0}%', Icons.check_circle, Colors.green)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Top Performing Students',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                topPerformers.isEmpty
                    ? const Text('No top performers recorded.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topPerformers.length,
                        itemBuilder: (context, index) {
                          final student = topPerformers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.amber.shade100,
                                child: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                              ),
                              title: Text(student['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${student['batchName'] ?? 'No Batch'} • Score: ${student['score'] ?? 0}'),
                              trailing: const Icon(Icons.emoji_events, color: Colors.amber),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text('Export Report', style: TextStyle(color: Colors.white)),
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
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
