import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';

class PerformanceReportsScreen extends StatelessWidget {
  const PerformanceReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mocking Elite plan for UI purposes
    const bool isElite = true;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Performance Reports"),
      body: !isElite
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: UpgradeBanner(title: "Performance Reports require Elite plan"),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownField<String>(
                    label: "Select Batch",
                    items: const ['Class 10th - A', 'Class 10th - B'],
                    value: 'Class 10th - A',
                    itemLabelBuilder: (v) => v,
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard("Avg Attendance", "87.4%", AppColors.chalkTeal),
                      const SizedBox(width: 12),
                      _buildStatCard("Avg Marks", "72.1%", AppColors.brassGold),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Top Performers", style: AppText.headingSm),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(
                                "#${index + 1}",
                                style: AppText.displaySm.copyWith(color: AppColors.brassGold, fontSize: 18),
                              ),
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.inkGreen,
                              child: Text("S${index + 1}", style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Student Name ${index + 1}", style: AppText.labelMd),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildMiniStat("Marks", "9${8 - index}%"),
                                      const SizedBox(width: 16),
                                      _buildMiniStat("Attendance", "9${9 - index}%"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: AppText.displayMd.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppText.caption.copyWith(color: AppColors.textSecond)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Row(
      children: [
        Text("$label: ", style: AppText.caption.copyWith(color: AppColors.textSecond)),
        Text(value, style: AppText.labelSm),
      ],
    );
  }
}
