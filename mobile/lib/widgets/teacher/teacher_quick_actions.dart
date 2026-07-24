import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TeacherQuickActions extends StatelessWidget {
  const TeacherQuickActions({super.key});

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _buildActionCard(
                'Mark\nAttendance', 
                Icons.fact_check_outlined, 
                Colors.blue, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Mark Attendance')), body: const Center(child: Text('Coming Soon')))))
              ),
              _buildActionCard(
                'Upload\nMaterial', 
                Icons.cloud_upload_outlined, 
                Colors.purple, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Upload Material')), body: const Center(child: Text('Coming Soon')))))
              ),
              _buildActionCard(
                'Manage\nTests', 
                Icons.assignment_outlined, 
                Colors.orange, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Manage Tests')), body: const Center(child: Text('Coming Soon')))))
              ),
              _buildActionCard(
                'Student\nReports', 
                Icons.bar_chart_outlined, 
                AppColors.success, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Student Reports')), body: const Center(child: Text('Coming Soon')))))
              ),
            ],
          ),
        ],
      ),
    );
  }
}
