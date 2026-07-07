import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsync = ref.watch(timetableProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: timetableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (timetable) {
          if (timetable.isEmpty) return const Center(child: Text('No scheduled classes.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: timetable.length,
            itemBuilder: (context, index) {
              final slot = timetable[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.deepPurple.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${slot['startTime'] ?? 'N/A'} - ${slot['endTime'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                          Text(slot['room'] ?? 'Room TBD', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.person, size: 16, color: Colors.orange),
                          ),
                          const SizedBox(width: 8),
                          Text('${slot['teacherName'] ?? 'Unknown'} (${slot['subjectName'] ?? 'Subject'})', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(slot['batchName'] ?? 'No Batch', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
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
        label: const Text('Schedule Class', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
