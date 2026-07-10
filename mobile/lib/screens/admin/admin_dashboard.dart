import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc_components.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeroHeader(
              greeting: "Good morning 👋",
              name: "Excel Academy",
              initials: "EA",
              stats: [
                HeroStatTile(label: "Students", value: "1,250", icon: Icons.groups),
                HeroStatTile(label: "Teachers", value: "45", icon: Icons.person),
                HeroStatTile(label: "Batches", value: "24", icon: Icons.class_),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fee Collection", style: AppText.headingSm),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: CircularProgressIndicator(
                                      value: 0.75,
                                      color: AppColors.chalkTeal,
                                      backgroundColor: AppColors.divider,
                                      strokeWidth: 8,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "75%\nCollected",
                                      style: AppText.labelMd,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildFeeRow("Collected", "₹3,75,000", AppColors.chalkTeal),
                                  const SizedBox(height: 8),
                                  _buildFeeRow("Pending", "₹1,25,000", AppColors.redInk),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: "Collect Fee",
                          fullWidth: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Attendance Today", style: AppText.headingSm),
                            Text("1,120/1,250 Present", style: AppText.labelMd.copyWith(color: AppColors.chalkTeal)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: List.generate(40, (index) {
                            Color color = AppColors.chalkTeal;
                            if (index % 7 == 0) color = AppColors.divider; // absent
                            if (index % 13 == 0) color = AppColors.brassGold; // late
                            return CircleAvatar(
                              radius: 12,
                              backgroundColor: color,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text("Quick Actions", style: AppText.headingSm),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      QuickActionCard(label: "Add Student", icon: Icons.person_add_outlined, color: AppColors.brassGold, onTap: () {}),
                      QuickActionCard(label: "Mark Attendance", icon: Icons.check_circle_outline, color: AppColors.chalkTeal, onTap: () {}),
                      QuickActionCard(label: "Record Fee", icon: Icons.receipt_long_outlined, color: AppColors.inkGreen, onTap: () {}),
                      QuickActionCard(label: "Reports", icon: Icons.bar_chart_outlined, color: AppColors.chalkTeal, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
        Text(amount, style: AppText.labelMd.copyWith(color: color)),
      ],
    );
  }
}

