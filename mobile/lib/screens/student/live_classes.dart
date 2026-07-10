import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/app_bar.dart';

class StudentLiveClassesScreen extends StatefulWidget {
  const StudentLiveClassesScreen({Key? key}) : super(key: key);

  @override
  State<StudentLiveClassesScreen> createState() => _StudentLiveClassesScreenState();
}

class _StudentLiveClassesScreenState extends State<StudentLiveClassesScreen> {
  int _selectedDateIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Live Classes"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: List.generate(7, (index) {
                  final isSelected = _selectedDateIndex == index;
                  final isToday = index == 3;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 36,
                      child: Column(
                        children: [
                          Text(
                            ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
                            style: AppText.caption.copyWith(color: AppColors.textSecond),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brassGold : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${9 + index}",
                                style: AppText.labelMd.copyWith(
                                  color: isSelected ? Colors.white : (isToday ? AppColors.brassGold : AppColors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: 2,
              itemBuilder: (context, index) {
                final isLive = index == 0;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusChip(
                            label: isLive ? "Live Now" : "Upcoming",
                            status: isLive ? ChipStatus.active : ChipStatus.pending,
                          ),
                          const Spacer(),
                          Text(
                            isLive ? "Started 10m ago" : "Today, 11:00 AM",
                            style: AppText.labelSm.copyWith(color: AppColors.brassGold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Quadratic Equations Revision", style: AppText.headingSm),
                      Text("Mathematics · Mr. Sharma", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: isLive ? "Join Now →" : "Remind Me",
                        fullWidth: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
