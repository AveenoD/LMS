import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/app_bar.dart';

class FeeSummaryScreen extends StatelessWidget {
  const FeeSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "My Fees"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              backgroundColor: AppColors.inkGreen,
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Fee", style: AppText.bodySm.copyWith(color: Colors.white.withOpacity(0.7))),
                  Text("₹15,000", style: AppText.displayMd.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFeeBlock("Paid", "₹10,000", AppColors.chalkTeal),
                      const SizedBox(width: 24),
                      _buildFeeBlock("Pending", "₹5,000", AppColors.brassGold),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text("Payment History", style: AppText.headingSm),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.chalkTeal10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_outlined, color: AppColors.chalkTeal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("₹5,000", style: AppText.labelMd),
                            Text("12 Aug 2024 · UPI", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                          ],
                        ),
                      ),
                      TextLink(
                        label: "Receipt →",
                        onTap: () {
                          context.push('/student/fees/receipt/123');
                        },
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

  Widget _buildFeeBlock(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption.copyWith(color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(value, style: AppText.labelMd.copyWith(color: color)),
        ],
      ),
    );
  }
}
