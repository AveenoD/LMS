import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (subjects) {
          if (subjects.isEmpty) return const Center(child: Text('No subjects found.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.deepPurple),
                  title: Text(subject['name'] ?? 'Unknown Subject', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
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
        label: const Text('Add Subject', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
