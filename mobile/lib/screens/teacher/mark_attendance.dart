import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/inputs.dart';
import '../../widgets/buttons.dart';

import '../../widgets/app_bar.dart';

class MarkAttendanceScreen extends StatelessWidget {
  const MarkAttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Mark Attendance"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            child: Column(
              children: [
                DropdownField<String>(
                  label: "Select Batch",
                  items: const ['Class 10th - A', 'Class 10th - B'],
                  value: 'Class 10th - A',
                  itemLabelBuilder: (v) => v,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 8),
                const InputField(
                  label: "Date",
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                ), // Should technically use date picker here
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.inkGreen,
                        child: Text("S${index + 1}", style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Student Name ${index + 1}", style: AppText.labelMd),
                            Text("Roll No: ${100 + index}", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                          ],
                        ),
                      ),
                      _buildToggleButtons(index),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, -4)),
              ],
            ),
            child: Row(
              children: [
                Text("15 students · 12 present", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                const Spacer(),
                PrimaryButton(label: "Submit →", onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons(int index) {
    // Mocking state
    int selectedIndex = index % 3; // 0=P, 1=A, 2=L

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton("P", selectedIndex == 0, AppColors.chalkTeal),
        const SizedBox(width: 4),
        _buildToggleButton("A", selectedIndex == 1, AppColors.redInk),
        const SizedBox(width: 4),
        _buildToggleButton("L", selectedIndex == 2, AppColors.brassGold),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, Color activeColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? activeColor : AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? null : Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecond,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
