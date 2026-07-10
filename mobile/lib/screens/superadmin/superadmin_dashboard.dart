import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/chips.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';
import '../../providers/superadmin_providers.dart';
import '../../utils/constants.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(superAdminAnalyticsProvider);
    final leadsAsync = ref.watch(leadsProvider);
    final subsAsync = ref.watch(subscriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: GreenAppBar(
        title: "EdTech OS",
        actions: [
          IconButton(
            icon: const Badge(child: Icon(Icons.notifications_outlined, color: Colors.white)),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.brassGold,
              child: Text("A", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.inkGreen,
        onRefresh: () async {
          ref.invalidate(superAdminAnalyticsProvider);
          ref.invalidate(leadsProvider);
          ref.invalidate(subscriptionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good morning, Admin!", style: AppText.displaySm.copyWith(color: AppColors.inkGreen)),
              const SizedBox(height: AppSpacing.xs),
              Text("Here's your platform overview", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
              const SizedBox(height: AppSpacing.lg),

              analyticsAsync.when(
                data: (data) => GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    KpiCard(label: "Total Tenants", value: "${data['totalTenants'] ?? 0}", icon: Icons.business_outlined, iconColor: AppColors.chalkTeal),
                    KpiCard(label: "Active Tenants", value: "${data['activeTenants'] ?? 0}", icon: Icons.check_circle_outline, iconColor: AppColors.chalkTeal),
                    KpiCard(label: "Total Students", value: "${data['totalStudents'] ?? 0}", icon: Icons.groups_outlined, iconColor: AppColors.chalkTeal),
                    KpiCard(
                      label: "MRR",
                      value: "${Constants.currencySymbol}${data['mrr'] ?? 0}",
                      icon: Icons.trending_up,
                      iconColor: AppColors.brassGold,
                      valueColor: AppColors.brassGold,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.inkGreen)),
                error: (e, st) => Center(child: Text("Error loading analytics: $e", style: TextStyle(color: AppColors.redInk))),
              ),

              const SizedBox(height: AppSpacing.lg),
              SectionRow(
                title: "Trials Expiring",
                onAction: () => context.go('/superadmin/subscriptions'),
              ),
              const SizedBox(height: AppSpacing.sm),
              subsAsync.when(
                data: (subs) {
                  final trials = subs.where((s) => s['status'] == 'trial').toList();
                  if (trials.isEmpty) {
                    return const Padding(padding: EdgeInsets.all(8.0), child: Text("No expiring trials."));
                  }
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trials.length,
                      itemBuilder: (context, index) {
                        final trial = trials[index];
                        final tenant = trial['tenant'] ?? {};
                        final endDateStr = trial['endDate'];
                        
                        String daysLeft = "?";
                        if (endDateStr != null) {
                          final endDate = DateTime.tryParse(endDateStr);
                          if (endDate != null) {
                            final diff = endDate.difference(DateTime.now()).inDays;
                            daysLeft = diff >= 0 ? diff.toString() : "0";
                          }
                        }

                        return AppCard(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tenant['name'] ?? 'Unknown', style: AppText.labelMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text("Trial ends in $daysLeft days", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                                const Spacer(),
                                const StatusChip(label: "Pending", status: ChipStatus.pending),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.inkGreen)),
                error: (e, st) => const Text("Error loading subscriptions."),
              ),

              const SizedBox(height: AppSpacing.lg),
              SectionRow(
                title: "New Demo Requests",
                onAction: () => context.go('/superadmin/leads'),
              ),
              const SizedBox(height: AppSpacing.sm),
              leadsAsync.when(
                data: (leads) {
                  final newLeads = leads.where((l) => l['status'] == 'new').take(3).toList();
                  if (newLeads.isEmpty) {
                    return const Padding(padding: EdgeInsets.all(8.0), child: Text("No new requests."));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: newLeads.length,
                    itemBuilder: (context, index) {
                      final lead = newLeads[index];
                      final name = lead['name'] ?? 'Unknown';
                      return ListItemRow(
                        initials: name.substring(0, 1).toUpperCase(),
                        title: name,
                        subtitle: "${lead['instituteName'] ?? 'No Inst'} · ${lead['studentCount'] ?? 0} students",
                        trailing: const StatusChip(label: "New", status: ChipStatus.pending),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.inkGreen)),
                error: (e, st) => const Text("Error loading leads."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

