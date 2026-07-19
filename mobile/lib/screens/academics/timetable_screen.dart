import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

const _dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsync = ref.watch(timetableProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2E27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Timetable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF1F2E27).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                '${slot['startTime'] ?? 'N/A'} - ${slot['endTime'] ?? 'N/A'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
                              child: Text(dayLabel, style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.orange.shade50,
                              child: const Icon(Icons.person, size: 20, color: Colors.orange),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${slot['teacher'] ?? 'Unknown'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${slot['subject'] ?? 'No subject'}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                              child: Text(slot['batch'] ?? 'No Batch', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
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
        heroTag: null,
        onPressed: () => _openScheduleBottomSheet(context, ref),
        backgroundColor: const Color(0xFF1F2E27),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Schedule Class', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _openScheduleBottomSheet(BuildContext context, WidgetRef ref) async {
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleClassBottomSheet(batches: batches, teachers: teachers, subjects: subjects),
    );
  }
}

class _ScheduleClassBottomSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> batches;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> subjects;

  const _ScheduleClassBottomSheet({required this.batches, required this.teachers, required this.subjects});

  @override
  ConsumerState<_ScheduleClassBottomSheet> createState() => _ScheduleClassBottomSheetState();
}

class _ScheduleClassBottomSheetState extends ConsumerState<_ScheduleClassBottomSheet> {
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

  InputDecoration _dropdownDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1F2E27), width: 1.5),
      ),
    );
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
                  'Schedule Class',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Batch', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _batchId,
                      decoration: _dropdownDecoration(Icons.group_outlined),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: widget.batches
                          .map((b) => DropdownMenuItem<int>(value: b['id'] as int, child: Text(b['name']?.toString() ?? '')))
                          .toList(),
                      onChanged: (v) => setState(() => _batchId = v),
                    ),
                    const SizedBox(height: 16),
                    const Text('Teacher', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _teacherId,
                      decoration: _dropdownDecoration(Icons.person_outline),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: widget.teachers
                          .map((t) => DropdownMenuItem<int>(value: t['id'] as int, child: Text(t['fullName']?.toString() ?? '')))
                          .toList(),
                      onChanged: (v) => setState(() => _teacherId = v),
                    ),
                    const SizedBox(height: 16),
                    const Text('Subject (optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      initialValue: _subjectId,
                      decoration: _dropdownDecoration(Icons.menu_book),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('None')),
                        ...widget.subjects.map((s) => DropdownMenuItem<int?>(value: s['id'] as int, child: Text(s['name']?.toString() ?? ''))),
                      ],
                      onChanged: (v) => setState(() => _subjectId = v),
                    ),
                    const SizedBox(height: 16),
                    const Text('Day of Week', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _dayOfWeek,
                      decoration: _dropdownDecoration(Icons.calendar_today_outlined),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: List.generate(7, (i) => DropdownMenuItem<int>(value: i, child: Text(_dayNames[i]))),
                      onChanged: (v) => setState(() => _dayOfWeek = v ?? _dayOfWeek),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Start: ${_fmt(_startTime)}', style: const TextStyle(fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled, color: Colors.grey.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('End: ${_fmt(_endTime)}', style: const TextStyle(fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 52,
                    child: CustomButton(
                      text: 'Schedule Class',
                      onPressed: _submit,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
