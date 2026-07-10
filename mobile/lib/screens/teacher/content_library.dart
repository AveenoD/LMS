import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/chips.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/fab.dart';

class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({Key? key}) : super(key: key);

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
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
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md).copyWith(bottom: 12),
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 160,
                            decoration: const BoxDecoration(
                              color: AppColors.inkGreen10,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: const Center(
                              child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.inkGreen.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text("▶ YouTube", style: AppText.caption.copyWith(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Trigonometry Part ${index + 1}", style: AppText.labelMd),
                            Text("Class 10th - A · Mathematics", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecond),
                                const SizedBox(width: 4),
                                Text("12 Oct 2024", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                              ],
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
      floatingActionButton: GoldFAB(
        onPressed: () {
          // Open Upload Content bottom sheet
        },
      ),
    );
  }
}

