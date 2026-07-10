import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/chips.dart';
import '../../widgets/inputs.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/fab.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({Key? key}) : super(key: key);

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: GreenAppBar(
        title: "Students",
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            child: Column(
              children: [
                const InputField(
                  label: "Search Students",
                  prefixIcon: Icons.search,
                ),
                FilterChipRow(
                  items: const ["All Batches", "Class 10th - A", "Class 10th - B", "Class 12th - Sci"],
                  selectedIndex: _selectedFilterIndex,
                  onSelected: (index) => setState(() => _selectedFilterIndex = index),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md).copyWith(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.inkGreen10,
                        child: Text("S${index + 1}", style: const TextStyle(color: AppColors.inkGreen)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Student Name ${index + 1}", style: AppText.labelMd),
                            Text("100${index} · Class 10", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                            Text("Class 10th - A", style: AppText.caption.copyWith(color: AppColors.chalkTeal)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip(
                            label: index % 3 == 0 ? "Pending" : "Paid",
                            status: index % 3 == 0 ? ChipStatus.pending : ChipStatus.active,
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textSecond),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: GoldFAB(
        onPressed: () {
          // Open Add Student Bottom Sheet
        },
      ),
    );
  }
}

