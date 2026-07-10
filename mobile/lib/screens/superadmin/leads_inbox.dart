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
import '../../services/api_service.dart';

class LeadsInboxScreen extends ConsumerStatefulWidget {
  const LeadsInboxScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeadsInboxScreen> createState() => _LeadsInboxScreenState();
}

class _LeadsInboxScreenState extends ConsumerState<LeadsInboxScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All", "New", "Contacted", "Converted", "Lost"];

  Future<void> _changeStatus(int id, String newStatus) async {
    try {
      final api = ref.read(apiServiceProvider);
      await updateLeadStatus(api, id, newStatus.toLowerCase());
      ref.invalidate(leadsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Demo Requests"),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                onRefresh: () async => ref.invalidate(leadsProvider),
                child: leadsAsync.when(
                  data: (leads) {
                    final currentFilter = _filters[_selectedFilterIndex].toLowerCase();
                    final filteredLeads = currentFilter == 'all'
                        ? leads
                        : leads.where((l) => (l['status'] ?? '').toString().toLowerCase() == currentFilter).toList();

                    if (filteredLeads.isEmpty) {
                      return ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text("No leads found.")),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredLeads.length,
                      itemBuilder: (context, index) {
                        final lead = filteredLeads[index];
                        final id = lead['id'];
                        final status = (lead['status'] ?? 'new').toString();
                        final name = (lead['name'] ?? 'Unknown').toString();
                        final isUnread = !(lead['isRead'] ?? true);
                        
                        // Capitalize status for dropdown
                        final currentStatus = status[0].toUpperCase() + status.substring(1);
                        
                        // Parse date
                        String dateStr = 'Unknown';
                        if (lead['createdAt'] != null) {
                          final date = DateTime.tryParse(lead['createdAt']);
                          if (date != null) {
                            dateStr = "${date.day}/${date.month}/${date.year}";
                          }
                        }

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          customBorder: isUnread ? const Border(left: BorderSide(color: AppColors.brassGold, width: 3)) : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.inkGreen,
                                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(name, style: AppText.labelMd),
                                            const Spacer(),
                                            Text(dateStr, style: AppText.caption.copyWith(color: AppColors.textSecond)),
                                          ],
                                        ),
                                        Text(lead['instituteName'] ?? 'No Institute', style: AppText.bodySm),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (lead['city'] != null) ...[
                                    InfoChip(label: lead['city'], icon: Icons.location_on_outlined),
                                    const SizedBox(width: 8),
                                  ],
                                  InfoChip(label: "${lead['studentCount'] ?? 0}", icon: Icons.groups_outlined),
                                  const SizedBox(width: 8),
                                  InfoChip(label: lead['phone'] ?? 'No Phone', icon: Icons.phone_outlined),
                                ],
                              ),
                              if (lead['message'] != null && lead['message'].toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  lead['message'],
                                  style: AppText.bodySm.copyWith(color: AppColors.textSecond),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(color: AppColors.divider, height: 1),
                              ),
                              Row(
                                children: [
                                  DropdownButton<String>(
                                    value: ['New', 'Contacted', 'Converted', 'Lost'].contains(currentStatus) ? currentStatus : 'New',
                                    underline: const SizedBox(),
                                    style: AppText.labelSm.copyWith(color: AppColors.inkGreen),
                                    items: ['New', 'Contacted', 'Converted', 'Lost'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null && val != currentStatus) {
                                        _changeStatus(id, val);
                                      }
                                    },
                                  ),
                                  const Spacer(),
                                  SecondaryButton(
                                    label: "WhatsApp →",
                                    compact: true,
                                    onTap: () {},
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

