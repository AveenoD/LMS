import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';

const _dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsync = ref.watch(timetableProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: timetableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (timetable) {
          if (timetable.isEmpty) return const Center(child: Text('No scheduled classes.'));
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(timetableProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: timetable.length,
              itemBuilder: (context, index) {
                final slot = timetable[index] as Map<String, dynamic>;
                final dayOfWeek = slot['dayOfWeek'];
                final dayLabel = (dayOfWeek is int && dayOfWeek >= 0 && dayOfWeek <= 6) ? _dayNames[dayOfWeek] : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${slot['startTime'] ?? 'N/A'} - ${slot['endTime'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                            Text(dayLabel, style: const TextStyle(color: Colors.grey)),
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
                            Expanded(
                              child: Text(
                                '${slot['teacher'] ?? 'Unknown'} (${slot['subject'] ?? 'No subject'})',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(slot['batch'] ?? 'No Batch', style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScheduleDialog(context, ref),
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Schedule Class', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _openScheduleDialog(BuildContext context, WidgetRef ref) async {
    final results = await Future.wait([
      ref.read(batchesProvider.future),
      ref.read(teachersProvider.future),
      ref.read(subjectsProvider.future),
    ]);
    final batches = results[0].cast<Map<String, dynamic>>();
    final teachers = results[1].cast<Map<String, dynamic>>();
    final subjects = results[2].cast<Map<String, dynamic>>();
    if (!context.mounted) return;
    if (batches.isEmpty || teachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need at least one batch and one teacher before scheduling a class.')),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (_) => _ScheduleClassDialog(batches: batches, teachers: teachers, subjects: subjects),
    );
  }
}

class _ScheduleClassDialog extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> batches;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> subjects;

  const _ScheduleClassDialog({required this.batches, required this.teachers, required this.subjects});

  @override
  ConsumerState<_ScheduleClassDialog> createState() => _ScheduleClassDialogState();
}

class _ScheduleClassDialogState extends ConsumerState<_ScheduleClassDialog> {
  int? _batchId;
  int? _teacherId;
  int? _subjectId;
  int _dayOfWeek = DateTime.now().weekday % 7; // DateTime: Mon=1..Sun=7 -> convert to 0=Sun..6=Sat
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _batchId = widget.batches.first['id'] as int?;
    _teacherId = widget.teachers.first['id'] as int?;
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: isStart ? _startTime : _endTime);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_batchId == null || _teacherId == null) {
      setState(() => _error = 'Batch and teacher are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await createTimetableEntry(
        ref.read(apiServiceProvider),
        batchId: _batchId!,
        teacherId: _teacherId!,
        dayOfWeek: _dayOfWeek,
        startTime: _fmt(_startTime),
        endTime: _fmt(_endTime),
        subjectId: _subjectId,
      );
      ref.invalidate(timetableProvider);
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
    return AlertDialog(
      title: const Text('Schedule Class'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Batch', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _batchId,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: widget.batches
                  .map((b) => DropdownMenuItem<int>(value: b['id'] as int, child: Text(b['name']?.toString() ?? '')))
                  .toList(),
              onChanged: (v) => setState(() => _batchId = v),
            ),
            const SizedBox(height: 14),
            const Text('Teacher', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _teacherId,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: widget.teachers
                  .map((t) => DropdownMenuItem<int>(value: t['id'] as int, child: Text(t['fullName']?.toString() ?? '')))
                  .toList(),
              onChanged: (v) => setState(() => _teacherId = v),
            ),
            const SizedBox(height: 14),
            const Text('Subject (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int?>(
              initialValue: _subjectId,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('None')),
                ...widget.subjects.map((s) => DropdownMenuItem<int?>(value: s['id'] as int, child: Text(s['name']?.toString() ?? ''))),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
            ),
            const SizedBox(height: 14),
            const Text('Day of Week', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _dayOfWeek,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: List.generate(7, (i) => DropdownMenuItem<int>(value: i, child: Text(_dayNames[i]))),
              onChanged: (v) => setState(() => _dayOfWeek = v ?? _dayOfWeek),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text('Start: ${_fmt(_startTime)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text('End: ${_fmt(_endTime)}'),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Schedule'),
        ),
      ],
    );
  }
}
