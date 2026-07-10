import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import 'buttons.dart';
import 'cards.dart';
import 'chips.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.inkGreen.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(title, style: AppText.headingSm, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle, style: AppText.bodySm, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            PrimaryButton(label: actionLabel!, onTap: onAction!),
          ],
        ],
      ),
    );
  }
}

class UpgradeBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onUpgrade;

  const UpgradeBanner({
    Key? key,
    required this.title,
    this.subtitle,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brassGold10,
        border: Border.all(color: AppColors.brassGold, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.brassGold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.labelMd),
                if (subtitle != null)
                  Text(subtitle!, style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
              ],
            ),
          ),
          if (onUpgrade != null)
            TextButton(
              onPressed: onUpgrade,
              child: const Text("Upgrade →", style: TextStyle(color: AppColors.brassGold)),
            ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppText.labelSm.copyWith(color: AppColors.textSecond, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  final double? fontSize;

  const CalcRow({
    Key? key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodyMd.copyWith(color: AppColors.textSecond)),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppText.bodyMd.fontFamily,
              fontSize: fontSize ?? AppText.bodyMd.fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  final double? fontSize;

  const ReceiptRow({
    Key? key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppText.labelMd.fontFamily,
              fontSize: fontSize ?? AppText.labelMd.fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.inkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionRow extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionRow({
    Key? key,
    required this.title,
    this.actionLabel = "View all →",
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.headingSm),
        if (onAction != null)
          TextLink(label: actionLabel!, onTap: onAction!),
      ],
    );
  }
}

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  const KpiCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppText.bodySm.copyWith(color: AppColors.textSecond),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppText.displayMd.copyWith(color: valueColor ?? AppColors.inkGreen),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const QuickActionCard({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: AppText.labelMd),
          ],
        ),
      ),
    );
  }
}

class HeroStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const HeroStatTile({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
            const SizedBox(height: 8),
            Text(value, style: AppText.displaySm.copyWith(color: Colors.white, fontSize: 18)),
            Text(label, style: AppText.caption.copyWith(color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class HeroHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String initials;
  final List<HeroStatTile>? stats;
  final double paddingBottom;

  const HeroHeader({
    Key? key,
    required this.greeting,
    required this.name,
    required this.initials,
    this.stats,
    this.paddingBottom = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: paddingBottom),
      decoration: const BoxDecoration(
        color: AppColors.inkGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: AppText.bodySm.copyWith(color: Colors.white.withOpacity(0.7))),
                  Text(name, style: AppText.displayMd.copyWith(color: Colors.white)),
                ],
              ),
              CircleAvatar(
                backgroundColor: AppColors.brassGold,
                radius: 22,
                child: Text(initials, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          if (stats != null && stats!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                stats![0],
                if (stats!.length > 1) ...[
                  const SizedBox(width: 12),
                  stats![1],
                ],
                if (stats!.length > 2) ...[
                  const SizedBox(width: 12),
                  stats![2],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final String title;
  final String subject;
  final String? duration;

  const VideoCard({
    Key? key,
    required this.title,
    required this.subject,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.inkGreen10,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.brassGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                  ),
                ),
              ),
              if (duration != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(duration!, style: AppText.caption.copyWith(color: Colors.white)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.labelSm, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subject, style: AppText.caption.copyWith(color: AppColors.textSecond)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? initials;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ListItemRow({
    Key? key,
    required this.title,
    required this.subtitle,
    this.initials,
    this.icon,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            if (initials != null)
              CircleAvatar(
                backgroundColor: AppColors.inkGreen10,
                child: Text(initials!, style: const TextStyle(color: AppColors.inkGreen)),
              )
            else if (icon != null)
              CircleAvatar(
                backgroundColor: AppColors.inkGreen10,
                child: Icon(icon, color: AppColors.inkGreen, size: 20),
              ),
            if (initials != null || icon != null) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.labelMd),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
