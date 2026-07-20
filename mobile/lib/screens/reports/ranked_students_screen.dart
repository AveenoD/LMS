import 'package:flutter/material.dart';

class RankedStudentsScreen extends StatelessWidget {
  final String title;
  final List<dynamic> students;
  final bool isAttention; // True if 'Students Needing Attention', false for 'Top Performers'

  const RankedStudentsScreen({
    super.key,
    required this.title,
    required this.students,
    this.isAttention = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2E27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: students.isEmpty
          ? Center(
              child: Text(
                isAttention ? 'No students need immediate attention.' : 'No test data available for top performers.',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = students[index] as Map<String, dynamic>;
                return _buildStudentCard(student, index + 1);
              },
            ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int rank) {
    final name = student['fullName'] ?? 'Unknown';
    final marks = student['avgMarksPct'];
    final att = student['avgAttendance'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAttention ? Colors.red.shade100 : Colors.orange.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAttention ? Colors.red.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAttention ? Colors.red.shade700 : Colors.orange.shade700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2E27))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.orange.shade600),
                    const SizedBox(width: 4),
                    Text(marks != null ? '${marks.toStringAsFixed(1)}% Marks' : 'No Marks', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    const SizedBox(width: 12),
                    Icon(Icons.event_available, size: 14, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(att != null ? '${att.toStringAsFixed(1)}% Att.' : 'No Att.', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
