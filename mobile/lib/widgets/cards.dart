import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color backgroundColor;
  final bool isSelected;
  final bool useElevatedShadow;
  final BoxBorder? customBorder;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.borderRadius = AppSpacing.radiusLg,
    this.backgroundColor = Colors.white,
    this.isSelected = false,
    this.useElevatedShadow = false,
    this.customBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          useElevatedShadow ? AppShadows.elevatedShadow : AppShadows.cardShadow
        ],
        border: customBorder ?? (isSelected
            ? Border.all(color: AppColors.chalkTeal, width: 1.5)
            : null),
      ),
      child: child,
    );
  }
}
