import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.inkGreen,
                    child: Text("RS", style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  const SizedBox(height: 16),
                  Text("Rahul Sharma", style: AppText.displaySm.copyWith(color: AppColors.inkGreen)),
                  Text("Class 10th - A", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: "Account Details"),
            _buildProfileTile(Icons.phone_outlined, "Phone", "+91 9876543210"),
            _buildProfileTile(Icons.badge_outlined, "Roll No", "10045"),
            _buildProfileTile(Icons.location_on_outlined, "Address", "Mumbai, India"),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: "App Settings"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined, color: AppColors.inkGreen),
              title: Text("Notifications", style: AppText.labelMd),
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.brassGold,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language_outlined, color: AppColors.inkGreen),
              title: Text("Language", style: AppText.labelMd),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("English", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                  const Icon(Icons.chevron_right, color: AppColors.textSecond),
                ],
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.xl),
            SecondaryButton(
              label: "Log Out",
              fullWidth: true,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.inkGreen),
      title: Text(title, style: AppText.caption.copyWith(color: AppColors.textSecond)),
      subtitle: Text(subtitle, style: AppText.labelMd),
    );
  }
}
