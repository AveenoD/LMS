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

class SubscriptionsListScreen extends ConsumerStatefulWidget {
  const SubscriptionsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionsListScreen> createState() => _SubscriptionsListScreenState();
}

class _SubscriptionsListScreenState extends ConsumerState<SubscriptionsListScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All", "Active", "Trial", "Past Due", "Expired"];

  @override
  Widget build(BuildContext context) {
    final subsAsync = ref.watch(subscriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Subscriptions"),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            FilterChipRow(
              items: _filters,
              selectedIndex: _selectedFilterIndex,
              onSelected: (index) => setState(() => _selectedFilterIndex = index),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.inkGreen,
                onRefresh: () async => ref.invalidate(subscriptionsProvider),
                child: subsAsync.when(
                  data: (subs) {
                    final currentFilter = _filters[_selectedFilterIndex].toLowerCase();
                    final filteredSubs = currentFilter == 'all'
                        ? subs
                        : subs.where((s) {
                            String status = (s['status'] ?? '').toString().toLowerCase();
                            if (currentFilter == 'past due') return status == 'past_due';
                            return status == currentFilter;
                          }).toList();

                    if (filteredSubs.isEmpty) {
                      return ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text("No subscriptions found.")),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredSubs.length,
                      itemBuilder: (context, index) {
                        final sub = filteredSubs[index];
                        final tenantName = sub['tenant']?['name'] ?? 'Unknown';
                        final planName = sub['plan_catalog']?['name'] ?? 'No Plan';
                        final billingCycle = (sub['billingCycle'] ?? 'monthly').toString();
                        final statusStr = (sub['status'] ?? 'unknown').toString();
                        
                        ChipStatus chipStatus = ChipStatus.pending;
                        if (statusStr == 'active') chipStatus = ChipStatus.active;
                        else if (statusStr == 'trial') chipStatus = ChipStatus.pending;
                        else if (statusStr == 'expired' || statusStr == 'past_due') chipStatus = ChipStatus.expired;

                        final displayStatus = statusStr[0].toUpperCase() + statusStr.substring(1).replaceAll('_', ' ');

                        String nextDateStr = 'Unknown';
                        if (sub['endDate'] != null) {
                          final date = DateTime.tryParse(sub['endDate']);
                          if (date != null) {
                            nextDateStr = "${date.day}/${date.month}/${date.year}";
                          }
                        }

                        // Just a placeholder calculation for display
                        int amount = 0;
                        if (sub['plan_catalog'] != null) {
                           amount = sub['plan_catalog']['${billingCycle}Price'] ?? 0;
                        }

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          borderRadius: 12,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(tenantName, style: AppText.headingSm, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusChip(label: displayStatus, status: chipStatus),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(planName, style: AppText.bodySm.copyWith(color: AppColors.chalkTeal)),
                                  Text(" · ", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                                  Text(billingCycle[0].toUpperCase() + billingCycle.substring(1), style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text("${Constants.currencySymbol}$amount", style: AppText.labelMd),
                                  const Spacer(),
                                  Text("Next: $nextDateStr", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextLink(label: "Manage →", onTap: () {}),
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
            ),
          ],
        ),
      ),
    );
  }
}

