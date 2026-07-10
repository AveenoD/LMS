import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GoldFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const GoldFAB({
    Key? key,
    required this.onPressed,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.brassGold,
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }
}
