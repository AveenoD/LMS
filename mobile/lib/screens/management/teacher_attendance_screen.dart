import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/teacher_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  final int batchId;
  final String batchName;
  final int? timetableId;

  const TeacherAttendanceScreen({
    super.key,
    required this.batchId,
    required this.batchName,
    this.timetableId,
  });

  @override
  ConsumerState<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends ConsumerState<TeacherAttendanceScreen> {
  // Map of studentId -> 'present' | 'absent' | 'late'
  final Map<int, String> _attendanceState = {};
  bool _isSubmitting = false;

  void _markAll(String status, List<dynamic> students) {
    setState(() {
      for (final s in students) {
        final sidRaw = s['studentId'];
        final int sid = sidRaw is int ? sidRaw : int.tryParse(sidRaw?.toString() ?? '0') ?? 0;
        _attendanceState[sid] = status;
      }
    });
  }

  Future<void> _submitAttendance(List<dynamic> students) async {
    final records = students.map((s) {
      final sidRaw = s['studentId'];
      final int sid = sidRaw is int ? sidRaw : int.tryParse(sidRaw?.toString() ?? '0') ?? 0;
      final status = _attendanceState.containsKey(sid) ? _attendanceState[sid] : s['status'];
      return {
        'studentId': sid,
        'status': status,
      };
    }).toList();

    // Check if all students have been marked
    if (records.any((r) => r['status'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark attendance for all students before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = <String, dynamic>{
        'batchId': widget.batchId,
        if (widget.timetableId != null) 'timetableId': widget.timetableId,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'records': records,
      };

      final api = ref.read(apiServiceProvider);
      await api.post('/teacher/attendance', payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance submitted successfully!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayStrAPI = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final studentsAsync = ref.watch(attendanceBatchStudentsProvider((
      batchId: widget.batchId,
      date: todayStrAPI,
    )));
    final todayStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Attendance: ${widget.batchName}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('No students found in this batch.'));
          }

          return Column(
            children: [
              // Header Controls
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(todayStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _markAll('present', students),
                          child: const Text('Mark All Present', style: TextStyle(color: AppColors.success)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Students List
              Expanded(
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final sidRaw = student['studentId'];
                    final int sid = sidRaw is int ? sidRaw : int.tryParse(sidRaw?.toString() ?? '0') ?? 0;
                    final name = student['name'];
                    final status = _attendanceState.containsKey(sid) ? _attendanceState[sid] : student['status'];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('ID: $sid'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusBtn(sid, 'P', 'present', AppColors.success, status),
                          const SizedBox(width: 8),
                          _buildStatusBtn(sid, 'A', 'absent', AppColors.error, status),
                          const SizedBox(width: 8),
                          _buildStatusBtn(sid, 'L', 'late', AppColors.warning, status),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Submit Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _isSubmitting 
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit Attendance',
                            onPressed: () => _submitAttendance(students),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBtn(int studentId, String label, String value, Color color, String? currentStatus) {
    final isSelected = currentStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _attendanceState[studentId] = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
