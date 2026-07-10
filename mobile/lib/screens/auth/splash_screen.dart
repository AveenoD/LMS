import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate token check and routing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkGreen,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 80), // Placeholder for Logo SVG
                const SizedBox(height: AppSpacing.md),
                Text(
                  "EdTech OS",
                  style: AppText.displayLg.copyWith(color: Colors.white),
                ),
                Text(
                  "Run your institute. Delight every student.",
                  style: AppText.bodyMd.copyWith(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: const CircularProgressIndicator(
                color: AppColors.brassGold,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
