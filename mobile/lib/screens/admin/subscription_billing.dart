import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';

class SubscriptionBillingScreen extends StatelessWidget {
  const SubscriptionBillingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bool isActive = true;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Subscription"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            AppCard(
              backgroundColor: AppColors.inkGreen,
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Current Plan", style: AppText.bodySm.copyWith(color: Colors.white.withOpacity(0.7))),
                      const Spacer(),
                      const StatusChip(label: "Active", status: ChipStatus.active),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Pro Plan", style: AppText.displayMd.copyWith(color: Colors.white)),
                  Text("Yearly", style: AppText.bodySm.copyWith(color: AppColors.brassGold)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBlock("Students", "1,250"),
                      _buildInfoBlock("₹/student", "₹20"),
                      _buildInfoBlock("Next Bill", "12 Oct 2024"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Next Invoice Estimate", style: AppText.headingSm),
                  const SizedBox(height: 16),
                  const CalcRow(label: "Students", value: "1,250"),
                  const CalcRow(label: "Rate", value: "₹20"),
                  const CalcRow(label: "Cycle", value: "12 months"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),
                  const CalcRow(
                    label: "Total",
                    value: "₹3,00,000",
                    isBold: true,
                    color: AppColors.brassGold,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!isActive)
              PrimaryButton(label: "Pay Now — ₹3,00,000", fullWidth: true, onTap: () {})
            else
              SecondaryButton(label: "Manage Plan", fullWidth: true, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption.copyWith(color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 4),
        Text(value, style: AppText.labelMd.copyWith(color: Colors.white)),
      ],
    );
  }
}
