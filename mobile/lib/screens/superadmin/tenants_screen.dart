import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/superadmin_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_textfield.dart';

/// Super Admin's "Tenants" tab. List fields match `TenantListItem`:
/// {id, name, slug, city, isActive, status, trialEndsAt, nextBillingDate, studentCount}.
class TenantsScreen extends ConsumerWidget {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantsProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tenants) {
          if (tenants.isEmpty) {
            return const Center(child: Text('No institutes yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tenantsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenants[index] as Map<String, dynamic>;
                final isActive = tenant['isActive'] == true;
                final status = tenant['status']?.toString() ?? 'unknown';
                final city = tenant['city']?.toString();
                final studentCount = tenant['studentCount']?.toString() ?? '0';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showAssignPlanDialog(context, ref, tenant),
                    leading: CircleAvatar(
                      backgroundColor: primary.withOpacity(0.12),
                      child: Icon(Icons.business, color: primary),
                    ),
                    title: Text(tenant['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      [
                        if (city != null && city.isNotEmpty) city,
                        '$studentCount students',
                      ].join(' • '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusChip(status: status),
                        Switch(
                          value: isActive,
                          onChanged: (v) => _toggleActive(context, ref, tenant, v),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const _AddTenantDialog()),
        backgroundColor: primary,
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
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
