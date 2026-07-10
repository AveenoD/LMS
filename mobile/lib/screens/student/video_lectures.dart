import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/chips.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';

class StudentVideoLecturesScreen extends StatefulWidget {
  const StudentVideoLecturesScreen({Key? key}) : super(key: key);

  @override
  State<StudentVideoLecturesScreen> createState() => _StudentVideoLecturesScreenState();
}

class _StudentVideoLecturesScreenState extends State<StudentVideoLecturesScreen> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Video Library"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            child: Column(
              children: [
                const InputField(
                  label: "Search Videos",
                  prefixIcon: Icons.search,
                ),
                FilterChipRow(
                  items: const ["All", "Mathematics", "Science", "English"],
                  selectedIndex: _selectedFilterIndex,
                  onSelected: (index) => setState(() => _selectedFilterIndex = index),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return VideoCard(
                  title: "Trigonometry Part ${index + 1}",
                  subject: "Mathematics",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

