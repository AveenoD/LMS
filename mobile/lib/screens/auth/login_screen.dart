import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSuperAdminMode = false;
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final body = <String, dynamic>{
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
      };
      
      if (!_isSuperAdminMode) {
        body['slug'] = _slugController.text.trim();
      }

      final url = Uri.parse('${Constants.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final role = user['role'];

        if (!mounted) return;

        // Route based on actual role from backend
        switch (role) {
          case 'super_admin':
            context.go('/superadmin/dashboard');
            break;
          case 'coaching_admin':
            context.go('/admin/dashboard');
            break;
          case 'teacher':
            context.go('/teacher/schedule');
            break;
          case 'student':
            context.go('/student/home');
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown role')),
            );
        }
      } else {
        if (!mounted) return;
        final errorData = jsonDecode(response.body);
        final msg = errorData['error']?['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 40),
              decoration: const BoxDecoration(
                color: AppColors.inkGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 48),
                  const SizedBox(height: AppSpacing.sm),
                  Text("EdTech OS", style: AppText.displayMd.copyWith(color: Colors.white)),
                  Text(
                    "Run your institute. Delight every student.",
                    style: AppText.bodySm.copyWith(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [AppShadows.elevatedShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome Back", style: AppText.displaySm.copyWith(color: AppColors.inkGreen)),
                  const SizedBox(height: AppSpacing.xs),
                  Text("Sign in to continue", style: AppText.bodySm.copyWith(color: AppColors.textSecond, fontSize: 13)),
                  const SizedBox(height: 24),
                  if (!_isSuperAdminMode)
                    InputField(
                      label: "Institute Slug",
                      prefixIcon: Icons.business_outlined,
                      controller: _slugController,
                    ),
                  InputField(
                    label: "Phone",
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                  ),
                  InputField(
                    label: "Password",
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      TextLink(
                        label: _isSuperAdminMode ? "Institute Login →" : "Super Admin? →",
                        onTap: () {
                          setState(() {
                            _isSuperAdminMode = !_isSuperAdminMode;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.inkGreen))
                      : PrimaryButton(
                          label: "Sign In",
                          fullWidth: true,
                          onTap: _handleLogin,
                        ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text(
                      "Powered by EdTech OS",
                      style: AppText.caption.copyWith(color: AppColors.textSecond),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
