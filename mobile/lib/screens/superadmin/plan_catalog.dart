import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/chips.dart';
import '../../widgets/buttons.dart';
import '../../widgets/app_bar.dart';
import '../../providers/superadmin_providers.dart';
import '../../utils/constants.dart';

class PlanCatalogScreen extends ConsumerWidget {
  const PlanCatalogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansCatalogProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: GreenAppBar(
        title: "Plan Catalog",
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: PrimaryButton(
              label: "Add Plan +",
              onTap: () {},
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.inkGreen,
        onRefresh: () async => ref.invalidate(plansCatalogProvider),
        child: plansAsync.when(
          data: (plans) {
            if (plans.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text("No plans found.")),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final name = plan['name'] ?? 'Unknown';
                final isActive = plan['isActive'] == true;
                final features = plan['features'] as List? ?? [];
                
                final monthly = plan['monthlyPrice'] ?? 0;
                final quarterly = plan['quarterlyPrice'] ?? 0;
                final yearly = plan['yearlyPrice'] ?? 0;

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: AppText.displaySm.copyWith(color: AppColors.inkGreen)),
                          const Spacer(),
                          StatusChip(
                            label: isActive ? "Active" : "Inactive", 
                            status: isActive ? ChipStatus.active : ChipStatus.expired
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildPriceBlock("Monthly", "${Constants.currencySymbol}$monthly"),
                          const SizedBox(width: 16),
                          _buildPriceBlock("Quarterly", "${Constants.currencySymbol}$quarterly"),
                          const SizedBox(width: 16),
                          _buildPriceBlock("Yearly", "${Constants.currencySymbol}$yearly", isBest: true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (features.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: features.map((f) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.inkGreen10,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(f.toString(), style: AppText.caption.copyWith(color: AppColors.inkGreen)),
                          )).toList(),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      Row(
                        children: [
                          TextLink(label: "Edit →", onTap: () {}),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.redInk),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.inkGreen)),
          error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: AppColors.redInk))),
        ),
      ),
    );
  }

  Widget _buildPriceBlock(String period, String price, {bool isBest = false}) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(8),
              border: isBest ? Border.all(color: AppColors.brassGold) : null,
            ),
            child: Column(
              children: [
                Text(period, style: AppText.caption.copyWith(color: AppColors.textSecond)),
                const SizedBox(height: 4),
                Text(price, style: AppText.labelMd.copyWith(color: AppColors.inkGreen)),
              ],
            ),
          ),
          if (isBest)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brassGold,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text("Best", style: AppText.caption.copyWith(color: Colors.white, fontSize: 8)),
              ),
            ),
        ],
      ),
    );
  }
}
