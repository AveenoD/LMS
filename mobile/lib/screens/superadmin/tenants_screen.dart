import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/superadmin_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/analytics_top_card.dart';
import '../../theme/app_colors.dart';
import 'tenant_details_screen.dart';

/// Super Admin's "Tenants" tab. List fields match `TenantListItem`:
/// {id, name, slug, city, isActive, status, trialEndsAt, nextBillingDate, studentCount}.
class TenantsScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const TenantsScreen({super.key, this.initialFilter});

  @override
  ConsumerState<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends ConsumerState<TenantsScreen> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants'),
              ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tenants) {
          final filteredTenants = tenants.where((t) {
            if (_selectedFilter == 'All') return true;
            return t['status']?.toString() == _selectedFilter;
          }).toList();

          final int totalTenants = tenants.length;
          final int activeCount = tenants.where((t) => t['status'] == 'active').length;
          final int trialCount = tenants.where((t) => t['status'] == 'trial').length;
          final int suspendedCount = tenants.where((t) => t['status'] == 'suspended' || t['status'] == 'past_due').length;

          final String activePercent = totalTenants == 0 ? '0%' : '${((activeCount / totalTenants) * 100).toStringAsFixed(0)}%';
          final String trialPercent = totalTenants == 0 ? '0%' : '${((trialCount / totalTenants) * 100).toStringAsFixed(0)}%';
          final String suspendedPercent = totalTenants == 0 ? '0%' : '${((suspendedCount / totalTenants) * 100).toStringAsFixed(0)}%';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 155,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    AnalyticsTopCard(
                      title: 'Total Tenants', 
                      value: totalTenants.toString(), 
                      subtitle: 'All Institutes', 
                      icon: Icons.business, 
                      bgColor: const Color(0xFF1F2E27).withValues(alpha: 0.1), 
                      iconColor: const Color(0xFF1F2E27),
                      subtitleColor: Colors.grey.shade600,
                      subtitleIcon: null,
                    ),
                    AnalyticsTopCard(
                      title: 'Active', 
                      value: activeCount.toString(), 
                      subtitle: '$activePercent of total', 
                      icon: Icons.check_circle, 
                      bgColor: Colors.green.withValues(alpha: 0.1), 
                      iconColor: Colors.green,
                      subtitleColor: Colors.green,
                      subtitleIcon: null,
                    ),
                    AnalyticsTopCard(
                      title: 'Trial', 
                      value: trialCount.toString(), 
                      subtitle: '$trialPercent of total', 
                      icon: Icons.hourglass_top, 
                      bgColor: Colors.orange.withValues(alpha: 0.1), 
                      iconColor: Colors.orange,
                      subtitleColor: Colors.orange,
                      subtitleIcon: null,
                    ),
                    AnalyticsTopCard(
                      title: 'Suspended', 
                      value: suspendedCount.toString(), 
                      subtitle: '$suspendedPercent of total', 
                      icon: Icons.pause_circle, 
                      bgColor: Colors.red.withValues(alpha: 0.1), 
                      iconColor: Colors.red,
                      subtitleColor: Colors.red,
                      subtitleIcon: null,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: ['All', 'active', 'trial', 'suspended', 'past_due'].map((status) {
                    final isSelected = _selectedFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          status == 'All' ? 'ALL' : status.toUpperCase(), 
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF1F2E27)
                          )
                        ),
                        showCheckmark: false,
                        selected: isSelected,
                        selectedColor: const Color(0xFF2E6656),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = status);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filteredTenants.isEmpty
                    ? const Center(child: Text('No institutes found.'))
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(tenantsProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTenants.length,
                          itemBuilder: (context, index) {
                            final tenant = filteredTenants[index] as Map<String, dynamic>;
                final isActive = tenant['isActive'] == true;
                final status = tenant['status']?.toString() ?? 'unknown';
                final city = tenant['city']?.toString();
                final studentCount = tenant['studentCount']?.toString() ?? '0';

                return TenantCard(
                  tenant: tenant,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TenantDetailsScreen(tenant: tenant),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ),
          ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showDialog(context: context, builder: (_) => const _AddTenantDialog()),
        backgroundColor: const Color(0xFF1F2E27),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Tenant', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, Map<String, dynamic> tenant, bool value) async {
    try {
      await setTenantActive(ref.read(apiServiceProvider), tenant['id'] as int, value);
      ref.invalidate(tenantsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showAssignPlanDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> tenant) async {
    await showDialog(
      context: context,
      builder: (_) => _AssignPlanDialog(tenantId: tenant['id'] as int, tenantName: tenant['name']?.toString() ?? ''),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'trial':
        color = Colors.orange;
        break;
      case 'past_due':
        color = Colors.red;
        break;
      case 'suspended':
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class TenantCard extends StatelessWidget {
  final Map<String, dynamic> tenant;
  final VoidCallback onTap;
  
  const TenantCard({super.key, required this.tenant, required this.onTap});

  String _monthStr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildStat(IconData icon, String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = tenant['name'] ?? 'Unknown';
    final String? city = tenant['city']?.toString();
    final String studentCount = tenant['studentCount']?.toString() ?? '0';
    final String teacherCount = tenant['teacherCount']?.toString() ?? '0';
    final String batchCount = tenant['batchCount']?.toString() ?? '0';
    final String status = tenant['status']?.toString() ?? 'unknown';

    final String? trialEndsAtStr = tenant['trialEndsAt'];
    final String? nextBillingDateStr = tenant['nextBillingDate'];

    DateTime? trialEndsAt = trialEndsAtStr != null ? DateTime.tryParse(trialEndsAtStr) : null;
    DateTime? nextBillingDate = nextBillingDateStr != null ? DateTime.tryParse(nextBillingDateStr) : null;
    final now = DateTime.now();

    String statusText = status.toUpperCase();
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.withValues(alpha: 0.1);
    
    Widget dateInfoWidget = const SizedBox.shrink();

    if (status == 'trial') {
      statusText = 'TRIAL';
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withValues(alpha: 0.1);
      
      if (trialEndsAt != null) {
        final daysLeft = trialEndsAt.difference(now).inDays;
        final dateStr = '${trialEndsAt.day} ${_monthStr(trialEndsAt.month)} ${trialEndsAt.year}';
        dateInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${daysLeft > 0 ? daysLeft : 0} Days Left', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text('Trial ends on\n$dateStr', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          ],
        );
      }
    } else if (status == 'active') {
      statusText = 'PREMIUM';
      statusColor = Colors.green;
      statusBgColor = Colors.green.withValues(alpha: 0.1);
      
      if (nextBillingDate != null) {
        final dateStr = '${nextBillingDate.day} ${_monthStr(nextBillingDate.month)} ${nextBillingDate.year}';
        dateInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Valid till\n$dateStr', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          ],
        );
      }
    } else {
      statusText = status == 'past_due' ? 'EXPIRED' : status.toUpperCase();
      statusColor = Colors.red;
      statusBgColor = Colors.red.withValues(alpha: 0.1);
      
      DateTime? expiredOn = nextBillingDate ?? trialEndsAt;
      if (expiredOn != null) {
        final dateStr = '${expiredOn.day} ${_monthStr(expiredOn.month)} ${expiredOn.year}';
        dateInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Expired on\n$dateStr', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          ],
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE8F0ED),
                  child: const Icon(Icons.business, color: Color(0xFF1F2E27)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2E27))),
                      const SizedBox(height: 4),
                      Text('${city != null && city.isNotEmpty ? '$city, ' : ''}Maharashtra', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStat(Icons.school, studentCount, 'Students'),
                          _buildVerticalDivider(),
                          _buildStat(Icons.person, teacherCount, 'Teachers'),
                          _buildVerticalDivider(),
                          _buildStat(Icons.menu_book, batchCount, 'Batches'),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              dateInfoWidget,
            ],
          )
        ],
      ),
        ),
      ),
    );
  }
}

class _AddTenantDialog extends ConsumerStatefulWidget {
  const _AddTenantDialog();

  @override
  ConsumerState<_AddTenantDialog> createState() => _AddTenantDialogState();
}

class _AddTenantDialogState extends ConsumerState<_AddTenantDialog> {
  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _city = TextEditingController();
  final _contactPhone = TextEditingController();
  final _adminName = TextEditingController();
  final _adminPhone = TextEditingController();
  final _adminPassword = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _city.dispose();
    _contactPhone.dispose();
    _adminName.dispose();
    _adminPhone.dispose();
    _adminPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _slug.text.trim().isEmpty ||
        _adminName.text.trim().isEmpty ||
        _adminPhone.text.trim().isEmpty ||
        _adminPassword.text.isEmpty) {
      setState(() => _error = 'Name, slug, admin name, phone and password are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await registerTenant(
        ref.read(apiServiceProvider),
        name: _name.text.trim(),
        slug: _slug.text.trim(),
        adminName: _adminName.text.trim(),
        adminPhone: _adminPhone.text.trim(),
        adminPassword: _adminPassword.text,
        city: _city.text.trim(),
        contactPhone: _contactPhone.text.trim(),
      );
      ref.invalidate(tenantsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Institute'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(label: 'Institute Name', hint: 'e.g. Bright Future Coaching', controller: _name),
            const SizedBox(height: 12),
            CustomTextField(label: 'Slug', hint: 'lowercase-hyphenated, e.g. bright-future', controller: _slug),
            const SizedBox(height: 12),
            CustomTextField(label: 'City (optional)', hint: 'City', controller: _city),
            const SizedBox(height: 12),
            CustomTextField(label: 'Contact Phone (optional)', hint: 'Institute contact phone', controller: _contactPhone),
            const SizedBox(height: 12),
            CustomTextField(label: 'Admin Name', hint: 'Coaching admin\'s name', controller: _adminName),
            const SizedBox(height: 12),
            CustomTextField(label: 'Admin Phone', hint: '10-15 digit login phone', controller: _adminPhone),
            const SizedBox(height: 12),
            CustomTextField(label: 'Admin Password', hint: 'Min 6 characters', isPassword: true, controller: _adminPassword),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }
}

class _AssignPlanDialog extends ConsumerStatefulWidget {
  final int tenantId;
  final String tenantName;
  const _AssignPlanDialog({required this.tenantId, required this.tenantName});

  @override
  ConsumerState<_AssignPlanDialog> createState() => _AssignPlanDialogState();
}

class _AssignPlanDialogState extends ConsumerState<_AssignPlanDialog> {
  int? _planId;
  String _billingCycle = 'monthly';
  bool _saving = false;
  String? _error;

  Future<void> _submit() async {
    if (_planId == null) {
      setState(() => _error = 'Choose a plan.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await assignPlanToTenant(
        ref.read(apiServiceProvider),
        widget.tenantId,
        planCatalogId: _planId!,
        billingCycle: _billingCycle,
      );
      ref.invalidate(tenantsProvider);
      ref.invalidate(tenantSubscriptionProvider(widget.tenantId));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subDetailAsync = ref.watch(tenantSubscriptionProvider(widget.tenantId));
    final plansAsync = ref.watch(plansProvider);

    return AlertDialog(
      title: Text(widget.tenantName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            subDetailAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
              error: (err, stack) => Text('$err', style: const TextStyle(color: Colors.red)),
              data: (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Current: ${detail['planName'] ?? 'No plan assigned'} • ${detail['status']} • ₹${detail['amount'] ?? 0}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
            const Text('Assign Plan', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            plansAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('$err', style: const TextStyle(color: Colors.red)),
              data: (plans) {
                final active = plans.cast<Map<String, dynamic>>().where((p) => p['isActive'] == true).toList();
                return DropdownButtonFormField<int>(
                  initialValue: _planId,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  hint: const Text('Choose plan'),
                  items: active
                      .map((p) => DropdownMenuItem<int>(value: p['id'] as int, child: Text(p['name']?.toString() ?? '')))
                      .toList(),
                  onChanged: (v) => setState(() => _planId = v),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text('Billing Cycle', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _billingCycle,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _billingCycle = v ?? 'monthly'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Close')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Assign'),
        ),
      ],
    );
  }
}
