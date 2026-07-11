import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/superadmin_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_textfield.dart';

/// The 12 feature keys gated by `featureGuard` — must match backend's
/// `FeatureKey` union exactly (src/middleware/featureGuard.ts).
const List<String> kFeatureKeys = [
  'student_management',
  'batch_management',
  'digital_attendance',
  'fee_management',
  'video_library',
  'whatsapp_reminders',
  'live_classes',
  'performance_reports',
  'online_tests',
  'doubt_solving',
  'custom_branding',
  'teacher_accounts',
];

String _featureLabel(String key) =>
    key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

/// Super Admin's "Plans" tab — pricing catalog CRUD.
/// `PlanCatalogItem`: {id, name, tagline, priceMonthly, priceQuarterly,
/// priceYearly, features[], isActive, displayOrder}.
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Catalog'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(child: Text('No plans yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(plansProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index] as Map<String, dynamic>;
                final isActive = plan['isActive'] == true;
                final features = (plan['features'] as List?)?.cast<String>() ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(plan['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isActive ? Colors.green : Colors.grey).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (plan['tagline'] != null) ...[
                          const SizedBox(height: 4),
                          Text(plan['tagline'], style: TextStyle(color: Colors.grey.shade700)),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '₹${plan['priceMonthly']}/mo  •  ₹${plan['priceQuarterly']}/qtr  •  ₹${plan['priceYearly']}/yr',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: features
                              .map((f) => Chip(
                                    label: Text(_featureLabel(f), style: const TextStyle(fontSize: 11)),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => _PlanFormDialog(existing: plan),
                              ),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                            ),
                            if (isActive)
                              TextButton.icon(
                                onPressed: () => _confirmDeactivate(context, ref, plan),
                                icon: const Icon(Icons.block, size: 18, color: Colors.red),
                                label: const Text('Deactivate', style: TextStyle(color: Colors.red)),
                              ),
                          ],
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
        onPressed: () => showDialog(context: context, builder: (_) => const _PlanFormDialog()),
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Plan', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, WidgetRef ref, Map<String, dynamic> plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate plan?'),
        content: Text('${plan['name']} will no longer be offered to new tenants.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await deactivatePlan(ref.read(apiServiceProvider), plan['id'] as int);
      ref.invalidate(plansProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _PlanFormDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  const _PlanFormDialog({this.existing});

  @override
  ConsumerState<_PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends ConsumerState<_PlanFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _tagline;
  late final TextEditingController _priceMonthly;
  late final TextEditingController _priceQuarterly;
  late final TextEditingController _priceYearly;
  late final TextEditingController _displayOrder;
  late final Set<String> _selectedFeatures;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?['name']?.toString() ?? '');
    _tagline = TextEditingController(text: e?['tagline']?.toString() ?? '');
    _priceMonthly = TextEditingController(text: e?['priceMonthly']?.toString() ?? '');
    _priceQuarterly = TextEditingController(text: e?['priceQuarterly']?.toString() ?? '');
    _priceYearly = TextEditingController(text: e?['priceYearly']?.toString() ?? '');
    _displayOrder = TextEditingController(text: e?['displayOrder']?.toString() ?? '');
    _selectedFeatures = ((e?['features'] as List?)?.cast<String>() ?? <String>[]).toSet();
  }

  @override
  void dispose() {
    _name.dispose();
    _tagline.dispose();
    _priceMonthly.dispose();
    _priceQuarterly.dispose();
    _priceYearly.dispose();
    _displayOrder.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final monthly = int.tryParse(_priceMonthly.text.trim());
    final quarterly = int.tryParse(_priceQuarterly.text.trim());
    final yearly = int.tryParse(_priceYearly.text.trim());

    if (_name.text.trim().isEmpty || monthly == null || quarterly == null || yearly == null || _selectedFeatures.isEmpty) {
      setState(() => _error = 'Name, all 3 prices, and at least one feature are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final displayOrder = int.tryParse(_displayOrder.text.trim());
      if (_isEdit) {
        await updatePlan(
          api,
          widget.existing!['id'] as int,
          tagline: _tagline.text.trim(),
          priceMonthly: monthly,
          priceQuarterly: quarterly,
          priceYearly: yearly,
          features: _selectedFeatures.toList(),
          displayOrder: displayOrder,
        );
      } else {
        await createPlan(
          api,
          name: _name.text.trim(),
          priceMonthly: monthly,
          priceQuarterly: quarterly,
          priceYearly: yearly,
          features: _selectedFeatures.toList(),
          tagline: _tagline.text.trim(),
          displayOrder: displayOrder,
        );
      }
      ref.invalidate(plansProvider);
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
      title: Text(_isEdit ? 'Edit Plan' : 'Add Plan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEdit) ...[
              CustomTextField(label: 'Plan Name', hint: 'e.g. Pro', controller: _name),
              const SizedBox(height: 12),
            ],
            CustomTextField(label: 'Tagline (optional)', hint: 'Short one-liner', controller: _tagline),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'Monthly ₹', hint: '999', controller: _priceMonthly)),
                const SizedBox(width: 8),
                Expanded(child: CustomTextField(label: 'Quarterly ₹', hint: '2699', controller: _priceQuarterly)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'Yearly ₹', hint: '9999', controller: _priceYearly)),
                const SizedBox(width: 8),
                Expanded(child: CustomTextField(label: 'Display Order (optional)', hint: '0', controller: _displayOrder)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Features', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: kFeatureKeys.map((key) {
                final selected = _selectedFeatures.contains(key);
                return FilterChip(
                  label: Text(_featureLabel(key), style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedFeatures.add(key);
                    } else {
                      _selectedFeatures.remove(key);
                    }
                  }),
                );
              }).toList(),
            ),
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
              : Text(_isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
