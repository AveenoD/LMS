import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class BrandingScreen extends ConsumerStatefulWidget {
  const BrandingScreen({super.key});

  @override
  ConsumerState<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends ConsumerState<BrandingScreen> {
  final TextEditingController _logoUrlController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  bool _isSaving = false;
  String? _error;
  bool _initialized = false;

  @override
  void dispose() {
    _logoUrlController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  bool _isValidHexColor(String v) => RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(v);
  bool _isValidUrl(String v) => v.isEmpty || Uri.tryParse(v)?.hasScheme == true;

  Future<void> _saveSettings() async {
    final color = _colorController.text.trim();
    final logoUrl = _logoUrlController.text.trim();

    if (color.isNotEmpty && !_isValidHexColor(color)) {
      setState(() => _error = 'Primary color must look like #2563EB.');
      return;
    }
    if (logoUrl.isNotEmpty && !_isValidUrl(logoUrl)) {
      setState(() => _error = 'Logo URL must be a full link starting with http:// or https://');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final result = await updateBranding(
        ref.read(apiServiceProvider),
        logoUrl: logoUrl.isEmpty ? null : logoUrl,
        primaryColor: color.isEmpty ? null : color,
      );
      await ref.read(authProvider.notifier).updateLocalBranding(
            instituteName: result['name']?.toString(),
            primaryColor: result['primaryColor']?.toString(),
            logoUrl: result['logoUrl']?.toString(),
          );
      ref.invalidate(brandingProvider);
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branding updated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandingAsync = ref.watch(brandingProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branding & Settings'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: brandingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (branding) {
          // Seed the color field once from the server; never overwrite what
          // the admin is actively typing on subsequent rebuilds.
          if (!_initialized) {
            _initialized = true;
            if (branding['primaryColor'] != null) _colorController.text = branding['primaryColor'].toString();
            if (branding['logoUrl'] != null) _logoUrlController.text = branding['logoUrl'].toString();
          }
          final instituteName = branding['name']?.toString() ?? '—';
          final logoUrl = branding['logoUrl']?.toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Platform Identity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: primary.withOpacity(0.1),
                    backgroundImage: (logoUrl != null && logoUrl.isNotEmpty) ? NetworkImage(logoUrl) : null,
                    child: (logoUrl == null || logoUrl.isEmpty) ? Icon(Icons.school, size: 50, color: primary) : null,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    instituteName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const Center(
                  child: Text(
                    'Institute name is set by the platform owner and can\'t be changed here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Logo URL',
                  hint: 'https://your-cdn.com/logo.png',
                  controller: _logoUrlController,
                  prefixIcon: Icons.image_outlined,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Primary Brand Color (Hex)',
                  hint: '#2563EB',
                  controller: _colorController,
                  prefixIcon: Icons.color_lens,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(text: 'Save Changes', onPressed: _saveSettings),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
