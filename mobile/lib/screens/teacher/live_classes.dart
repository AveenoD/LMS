import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/fab.dart';

class LiveClassesScreen extends StatelessWidget {
  const LiveClassesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Elite plan
    const bool isProOrElite = true;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Live Classes"),
      body: !isProOrElite
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: UpgradeBanner(title: "Live Classes require Pro plan"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: 3,
              itemBuilder: (context, index) {
                final isLive = index == 0;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusChip(
                            label: isLive ? "Live Now" : "Upcoming",
                            status: isLive ? ChipStatus.active : ChipStatus.pending,
                          ),
                          const Spacer(),
                          Text(
                            isLive ? "Started 10m ago" : "Today, 11:00 AM",
                            style: AppText.labelSm.copyWith(color: AppColors.brassGold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Quadratic Equations Revision", style: AppText.headingSm),
                      Text("Class 10th - A", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                      const SizedBox(height: 16),
                      if (isLive || index == 1) // joinable if live or upcoming soon
                        PrimaryButton(
                          label: "Join Now",
                          fullWidth: true,
                          onTap: () {}, // Opens meet url
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: isProOrElite
          ? GoldFAB(
              onPressed: () {
                // Open Schedule Live Class bottom sheet
              },
            )
          : null,
    );
  }
}

