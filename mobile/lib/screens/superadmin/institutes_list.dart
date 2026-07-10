import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/chips.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';
import '../../widgets/app_bar.dart';
import '../../providers/superadmin_providers.dart';
import '../../services/api_service.dart';

class InstitutesListScreen extends ConsumerStatefulWidget {
  const InstitutesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InstitutesListScreen> createState() => _InstitutesListScreenState();
}

class _InstitutesListScreenState extends ConsumerState<InstitutesListScreen> {
  String _searchQuery = '';

  Future<void> _toggleSuspend(int id, bool currentStatus) async {
    try {
      final api = ref.read(apiServiceProvider);
      await suspendTenant(api, id, !currentStatus);
      ref.invalidate(tenantsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: GreenAppBar(
        title: "Institutes",
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: PrimaryButton(
              label: "Add New +",
              onTap: () => context.go('/superadmin/tenants/new'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            InputField(
              label: "Search Institutes",
              prefixIcon: Icons.search,
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase());
              },
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.inkGreen,
                onRefresh: () async => ref.invalidate(tenantsProvider),
                child: tenantsAsync.when(
                  data: (tenants) {
                    final filtered = tenants.where((t) {
                      final name = (t['name'] ?? '').toString().toLowerCase();
                      final slug = (t['slug'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery) || slug.contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text("No institutes found.")),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final t = filtered[index];
                        final id = t['id'];
                        final name = t['name'] ?? 'Unknown';
                        final slug = t['slug'] ?? 'Unknown';
                        final isActive = t['isActive'] == true;
                        
                        // Handle potential list for subscriptions
                        final subs = t['subscriptions'];
                        Map<String, dynamic> activeSub = {};
                        if (subs is List && subs.isNotEmpty) {
                          activeSub = subs.firstWhere(
                            (s) => s['status'] == 'active' || s['status'] == 'trial',
                            orElse: () => subs.first,
                          );
                        } else if (subs is Map<String, dynamic>) {
                          activeSub = subs;
                        }

                        final planName = activeSub['plan_catalog']?['name'] ?? 'No Plan';
                        
                        // Parse next billing date if available
                        String nextDateStr = 'Unknown';
                        if (activeSub['endDate'] != null) {
                          final date = DateTime.tryParse(activeSub['endDate']);
                          if (date != null) {
                            nextDateStr = "${date.day}/${date.month}/${date.year}";
                          }
                        }

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: AppText.headingSm),
                                        Text("slug: $slug", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            StatusChip(
                                              label: isActive ? "Active" : "Suspended",
                                              status: isActive ? ChipStatus.active : ChipStatus.expired,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(planName, style: AppText.labelSm.copyWith(color: AppColors.chalkTeal)),
                                      const SizedBox(height: 4),
                                      Text("Next: $nextDateStr", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(color: AppColors.divider, height: 1),
                              ),
                              Row(
                                children: [
                                  TextLink(label: "View Details →", onTap: () {}),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(isActive ? Icons.block : Icons.play_circle_outline, color: isActive ? AppColors.redInk : AppColors.chalkTeal),
                                    onPressed: () => _toggleSuspend(id, isActive),
                                    tooltip: isActive ? "Suspend" : "Activate",
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
            ),
          ],
        ),
      ),
    );
  }
}
