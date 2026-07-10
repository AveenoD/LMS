import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/theme/app_spacing.dart';

enum ChipStatus { active, pending, expired, late, inactive }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipStatus status;

  const StatusChip({
    Key? key,
    required this.label,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (status) {
      case ChipStatus.active:
        bg = AppColors.chalkTeal10;
        text = AppColors.chalkTeal;
        break;
      case ChipStatus.pending:
        bg = AppColors.brassGold10;
        text = AppColors.brassGold;
        break;
      case ChipStatus.expired:
        bg = AppColors.redInk10;
        text = AppColors.redInk;
        break;
      case ChipStatus.late:
        bg = AppColors.orange10;
        text = AppColors.orange;
        break;
      case ChipStatus.inactive:
        bg = Colors.grey.withOpacity(0.1);
        text = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(fontWeight: FontWeight.w600, color: text),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const InfoChip({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inkGreen10,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.inkGreen, size: 12),
          const SizedBox(width: 4),
          Text(label, style: AppText.caption.copyWith(color: AppColors.inkGreen)),
        ],
      ),
    );
  }
}

class FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipItem({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.inkGreen : AppColors.paper,
            border: isSelected ? null : Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
            style: AppText.labelSm.copyWith(color: isSelected ? Colors.white : AppColors.textSecond),
          ),
        ),
      ),
    );
  }
}

class FilterChipRow extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterChipRow({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          return FilterChipItem(
            label: items[index],
            isSelected: index == selectedIndex,
            onTap: () => onSelected(index),
          );
        }),
      ),
    );
  }
}
