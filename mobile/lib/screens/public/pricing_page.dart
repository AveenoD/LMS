import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/app_bar.dart';

class PricingPageScreen extends StatelessWidget {
  const PricingPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: GreenAppBar(
        title: "EdTech OS",
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: PrimaryButton(
              label: "Register →",
              onTap: () => context.go('/superadmin/tenants/new'), // Usually public registration routes to a public register form
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(
              "Simple, Transparent Pricing",
              style: AppText.displayLg.copyWith(color: AppColors.inkGreen),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Pay Only For Your Active Students.",
              style: AppText.bodyMd.copyWith(color: AppColors.textSecond),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildPlanCard(
              title: "Basic",
              price: "₹30",
              features: ["Attendance", "Fee Tracking"],
              isBest: false,
            ),
            _buildPlanCard(
              title: "Pro",
              price: "₹45",
              features: ["Attendance", "Fee Tracking", "Video Library", "Live Classes"],
              isBest: true,
            ),
            _buildPlanCard(
              title: "Elite",
              price: "₹60",
              features: ["Everything in Pro", "White-label Branding", "Advanced Reports", "Priority Support"],
              isBest: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isBest,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      customBorder: isBest ? Border.all(color: AppColors.brassGold, width: 2) : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.displaySm.copyWith(color: AppColors.inkGreen)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: AppText.displayLg.copyWith(color: AppColors.inkGreen)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                    child: Text("/student/month", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(color: AppColors.divider, height: 1),
              ),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.chalkTeal, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(f, style: AppText.labelMd)),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              PrimaryButton(
                label: "Get Started",
                fullWidth: true,
                onTap: () {},
              ),
            ],
          ),
          if (isBest)
            Positioned(
              top: -36,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brassGold,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text("MOST POPULAR", style: AppText.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
