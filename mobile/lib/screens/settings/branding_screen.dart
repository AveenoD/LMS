import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class BrandingScreen extends ConsumerStatefulWidget {
  const BrandingScreen({super.key});

  @override
  ConsumerState<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends ConsumerState<BrandingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  bool _emailNotifications = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    setState(() => _isSaving = true);
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandingAsync = ref.watch(brandingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branding & Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: brandingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (branding) {
          // Initialize controllers with API data if they are empty
          if (_nameController.text.isEmpty && branding['schoolName'] != null) {
            _nameController.text = branding['schoolName'];
          }
          if (_colorController.text.isEmpty && branding['primaryColor'] != null) {
            _colorController.text = branding['primaryColor'];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Platform Identity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple.shade50,
                        child: const Icon(Icons.school, size: 50, color: Colors.deepPurple),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'School/Platform Name',
                  hint: 'e.g. Acme Academy',
                  controller: _nameController,
                  prefixIcon: Icons.business,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Primary Brand Color (Hex)',
                  hint: '#673AB7',
                  controller: _colorController,
                  prefixIcon: Icons.color_lens,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Preferences',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive alerts for new payments and leads'),
                  value: _emailNotifications,
                  activeColor: Colors.deepPurple,
                  onChanged: (val) {
                    setState(() => _emailNotifications = val);
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Save Changes',
                          onPressed: _saveSettings,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
