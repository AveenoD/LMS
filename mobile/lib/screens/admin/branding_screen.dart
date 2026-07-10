import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';

class BrandingScreen extends StatelessWidget {
  const BrandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bool isElite = true;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Branding"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Preview", style: AppText.headingSm),
                  const SizedBox(height: 16),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.inkGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.school, color: Colors.white),
                        const SizedBox(width: 12),
                        Text("Excel Academy", style: AppText.labelMd.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text("Institute Logo", style: AppText.labelMd),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Center(child: Icon(Icons.image_outlined, color: AppColors.textSecond, size: 32)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SecondaryButton(label: "Upload Logo", compact: true, onTap: () {}),
                    const SizedBox(height: 8),
                    Text("PNG, JPG. Max 2MB", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text("Primary Brand Color", style: AppText.labelMd),
            const SizedBox(height: 8),
            InputField(
              label: "Color Hex",
              prefixIcon: Icons.color_lens_outlined,
              controller: TextEditingController(text: "#1F2E27"),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (isElite)
              PrimaryButton(label: "Save Branding", fullWidth: true, onTap: () {})
            else
              const UpgradeBanner(title: "Custom branding requires Elite plan"),
          ],
        ),
      ),
    );
  }
}
