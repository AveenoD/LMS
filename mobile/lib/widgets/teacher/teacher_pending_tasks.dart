import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TeacherPendingTasks extends StatelessWidget {
  const TeacherPendingTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pending Tasks / Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 12),
          _buildTaskCard('15 Copies pending for Kinematics Weekly Test', true),
          const SizedBox(height: 8),
          _buildTaskCard('Upload Assignment for NEET Target 2025', false),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String text, bool isUrgent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUrgent ? Colors.orange.shade200 : Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(isUrgent ? Icons.warning_amber_rounded : Icons.info_outline, color: isUrgent ? Colors.orange.shade700 : Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: isUrgent ? Colors.orange.shade900 : Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
