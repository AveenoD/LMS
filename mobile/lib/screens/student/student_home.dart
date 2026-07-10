import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc_components.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double pendingFees = 1200; // Mock pending fee

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 24),
              decoration: const BoxDecoration(
                color: AppColors.inkGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello, Rahul! 👋", style: AppText.bodySm.copyWith(color: Colors.white.withOpacity(0.7))),
                          Text("Excel Academy", style: AppText.displaySm.copyWith(color: Colors.white)),
                        ],
                      ),
                      const CircleAvatar(
                        backgroundColor: AppColors.brassGold,
                        radius: 22,
                        child: Text("R", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    borderRadius: 12,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.videocam, color: Colors.white.withOpacity(0.8), size: 20),
                            const SizedBox(width: 8),
                            Text("Live Soon", style: AppText.bodySm.copyWith(color: AppColors.brassGold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Quadratic Equations Revision", style: AppText.labelMd.copyWith(color: Colors.white)),
                        Text("Today, 11:00 AM", style: AppText.caption.copyWith(color: Colors.white.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md).copyWith(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pendingFees > 0) ...[
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      borderRadius: 12,
                      customBorder: Border.all(color: AppColors.brassGold, width: 1.5),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.brassGold, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Fee Due", style: AppText.labelMd),
                                Text("₹$pendingFees pending", style: AppText.bodySm),
                              ],
                            ),
                          ),
                          TextLink(label: "Pay →", onTap: () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  SectionRow(
                    title: "Recent Lectures",
                    actionLabel: "See all →",
                    onAction: () {},
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          child: VideoCard(
                            title: "Trigonometry Part ${index + 1}",
                            subject: "Mathematics",
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text("Today's Schedule", style: AppText.headingSm),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 56,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("09:00", style: AppText.labelMd.copyWith(color: AppColors.inkGreen)),
                                  Text("10:00", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                                ],
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 40,
                              color: AppColors.chalkTeal,
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mathematics", style: AppText.headingSm),
                                  Text("Mr. Sharma", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
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
          ],
        ),
      ),
    );
  }
}
