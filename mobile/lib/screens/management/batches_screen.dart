import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: batchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (batches) {
          if (batches.isEmpty) return const Center(child: Text('No batches found.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];
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
                          Chip(
                            label: Text(batch['status'] ?? 'Active', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: Colors.green.shade400,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${batch['timing'] ?? 'No Timing'} • ${batch['studentCount'] ?? 0} Students', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Batch', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
