import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../providers/auth_provider.dart';
import '../../utils/role_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone and password.')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(phone, password);

    if (success && mounted) {
      final role = ref.read(authProvider).userRole;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homeScreenForRole(role)),
      );
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Login Failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      body: Stack(
        children: [
          // Header Background
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              color: Color(0xFF1F2E27),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'EdTech OS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Run your institute. Delight every student.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 48),
                  // Login Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2E27),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to continue',
                          style: TextStyle(fontSize: 14, color: Color(0xFF2E6656)),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: 'Phone',
                          hint: 'Enter your phone number',
                          prefixIcon: Icons.phone_outlined,
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 24),
                        authState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                height: 56,
                                child: CustomButton(
                                  text: 'Sign In →',
                                  onPressed: _handleLogin,
                                ),
                              ),
                        const SizedBox(height: 24),
                        const Text(
                          'Powered by EdTech OS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
