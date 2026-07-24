import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TeacherNotificationsScreen extends StatelessWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            title: 'New Batch Assigned',
            body: 'You have been assigned to NEET Target 2025 batch.',
            time: '2 hours ago',
            isUnread: true,
            icon: Icons.group_add,
            iconColor: Colors.blue,
          ),
          _buildNotificationCard(
            title: 'Pending Evaluations',
            body: '15 copies are pending for Kinematics Weekly Test.',
            time: '5 hours ago',
            isUnread: true,
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange,
          ),
          _buildNotificationCard(
            title: 'System Update',
            body: 'App maintenance scheduled for tomorrow at 2:00 AM.',
            time: '1 day ago',
            isUnread: false,
            icon: Icons.system_update,
            iconColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String body,
    required String time,
    required bool isUnread,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnread ? Colors.blue.shade100 : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                const SizedBox(height: 8),
                Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
