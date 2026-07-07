import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';

class FeesManagementScreen extends ConsumerWidget {
  const FeesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(feesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fees Management'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Recent Payments'),
              Tab(text: 'Fee Structures'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {},
            ),
          ],
        ),
        body: feesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (fees) {
            return TabBarView(
              children: [
                _buildPaymentsList(fees),
                _buildFeeStructuresList(),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.deepPurple,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Record Payment', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildPaymentsList(List<dynamic> fees) {
    if (fees.isEmpty) return const Center(child: Text('No recent payments.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fees.length,
      itemBuilder: (context, index) {
        final fee = fees[index];
        final isPaid = fee['status'] == 'Paid' || fee['status'] == 'Completed';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
              child: Icon(
                isPaid ? Icons.check_circle : Icons.timelapse,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(fee['studentName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Date: ${fee['date'] ?? 'N/A'}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${fee['amount'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  fee['status'] ?? 'Unknown',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeeStructuresList() {
    return const Center(
      child: Text('Fee Structures will be listed here.', style: TextStyle(color: Colors.grey)),
    );
  }
}
