import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/app_bar.dart';

class TodaysScheduleScreen extends StatefulWidget {
  const TodaysScheduleScreen({Key? key}) : super(key: key);

  @override
  State<TodaysScheduleScreen> createState() => _TodaysScheduleScreenState();
}

class _TodaysScheduleScreenState extends State<TodaysScheduleScreen> {
  int _selectedDateIndex = 3; // Mocking "Today" as 4th item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: GreenAppBar(
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Schedule", style: AppText.headingMd.copyWith(color: Colors.white)),
            Text("12 October 2024", style: AppText.caption.copyWith(color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
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
              itemCount: 4,
              itemBuilder: (context, index) {
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("09:00", style: AppText.labelMd.copyWith(color: AppColors.inkGreen)),
                            Text("10:00", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                          ],
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 60,
                        color: AppColors.chalkTeal,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Class 10th - A", style: AppText.headingSm),
                            Text("Mathematics", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                            const SizedBox(height: 8),
                            SecondaryButton(
                              label: "Take Attendance →",
                              compact: true,
                              onTap: () {},
                            ),
                          ],
                        ),
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
