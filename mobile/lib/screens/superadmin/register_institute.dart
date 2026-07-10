import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';
import '../../providers/superadmin_providers.dart';
import '../../services/api_service.dart';

class RegisterInstituteScreen extends ConsumerStatefulWidget {
  const RegisterInstituteScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterInstituteScreen> createState() => _RegisterInstituteScreenState();
}

class _RegisterInstituteScreenState extends ConsumerState<RegisterInstituteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  
  final _adminNameCtrl = TextEditingController();
  final _adminPhoneCtrl = TextEditingController();
  final _adminPasswordCtrl = TextEditingController();

  String? _selectedBillingCycle;
  int? _selectedPlanId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _colorCtrl.dispose();
    _adminNameCtrl.dispose();
    _adminPhoneCtrl.dispose();
    _adminPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedBillingCycle == null || _selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a billing cycle and a plan')));
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      await registerTenant(
        api,
        name: _nameCtrl.text,
        slug: _slugCtrl.text,
        city: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
        phone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
        primaryColor: _colorCtrl.text.isEmpty ? null : _colorCtrl.text,
        adminName: _adminNameCtrl.text,
        adminPhone: _adminPhoneCtrl.text,
        adminPassword: _adminPasswordCtrl.text,
        billingCycle: _selectedBillingCycle!.toLowerCase(),
        planCatalogId: _selectedPlanId!,
      );
      
      ref.invalidate(tenantsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Institute Registered!')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansCatalogProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Register Institute"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Institute Details", style: AppText.displaySm.copyWith(color: AppColors.inkGreen)),
              Text("Fill in the coaching centre information", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
              const SizedBox(height: AppSpacing.lg),

              const SectionHeader(title: "Institute Information"),
              InputField(label: "Institute Name", prefixIcon: Icons.school_outlined, controller: _nameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
              InputField(label: "Slug", prefixIcon: Icons.link_outlined, helperText: "Lowercase hyphens only", controller: _slugCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
              InputField(label: "City (Optional)", controller: _cityCtrl),
              InputField(label: "Contact Phone (Optional)", keyboardType: TextInputType.phone, controller: _phoneCtrl),
              InputField(
                label: "Brand Color #hex (Optional)",
                controller: _colorCtrl,
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.inkGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              const SectionHeader(title: "Admin Account"),
              InputField(label: "Admin Name", controller: _adminNameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
              InputField(label: "Admin Phone", keyboardType: TextInputType.phone, controller: _adminPhoneCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
              InputField(label: "Password", obscureText: true, controller: _adminPasswordCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: AppSpacing.lg),

              const SectionHeader(title: "Plan Assignment"),
              DropdownField<String>(
                label: "Billing Cycle",
                items: const ['Monthly', 'Quarterly', 'Yearly'],
                value: _selectedBillingCycle,
                itemLabelBuilder: (v) => v,
                onChanged: (val) => setState(() => _selectedBillingCycle = val),
              ),
              plansAsync.when(
                data: (plans) {
                  return DropdownField<int>(
                    label: "Plan",
                    items: plans.map<int>((p) => p['id'] as int).toList(),
                    value: _selectedPlanId,
                    itemLabelBuilder: (id) {
                      final plan = plans.firstWhere((p) => p['id'] == id);
                      return plan['name'] as String;
                    },
                    onChanged: (val) => setState(() => _selectedPlanId = val),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.inkGreen)),
                error: (e, st) => Text("Failed to load plans: $e", style: const TextStyle(color: AppColors.redInk)),
              ),
              const SizedBox(height: AppSpacing.xl),

              _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.inkGreen))
                  : PrimaryButton(
                      label: "Register Institute",
                      fullWidth: true,
                      onTap: _submit,
                    ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
