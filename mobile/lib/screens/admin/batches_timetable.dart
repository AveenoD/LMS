import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/app_bar.dart';

class BatchesTimetableScreen extends StatelessWidget {
  const BatchesTimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: const GreenAppBar(
          title: "Batches",
          bottom: TabBar(
            indicatorColor: AppColors.brassGold,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: "Batches"),
              Tab(text: "Timetable"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BatchesView(),
            _TimetableView(),
          ],
        ),
      ),
    );
  }
}

class _BatchesView extends StatelessWidget {
  const _BatchesView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Class 10th - Section ${String.fromCharCode(65 + index)}", style: AppText.headingSm),
                  const Spacer(),
                  const StatusChip(label: "Grade 10", status: ChipStatus.inactive),
                ],
              ),
              const SizedBox(height: 4),
              Text("${30 + index * 5} students enrolled", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextLink(label: "View Students →", onTap: () {}),
                  const Spacer(),
                  TextLink(label: "Add to Timetable →", onTap: () {}),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimetableView extends StatefulWidget {
  const _TimetableView();

  @override
  State<_TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<_TimetableView> {
  int _selectedDayIndex = 0;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilterChipRow(
            items: _days,
            selectedIndex: _selectedDayIndex,
            onSelected: (index) => setState(() => _selectedDayIndex = index),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: 4,
            itemBuilder: (context, index) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                borderRadius: 12,
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("09:00", style: AppText.labelMd.copyWith(color: AppColors.inkGreen)),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: SizedBox(
                              height: 8,
                              child: VerticalDivider(color: AppColors.divider, thickness: 1),
                            ),
                          ),
                          Text("10:00", style: AppText.caption.copyWith(color: AppColors.textSecond)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Class 10th - A", style: AppText.labelMd),
                          Text("Mathematics", style: AppText.bodySm.copyWith(color: AppColors.textSecond)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: AppColors.chalkTeal),
                              const SizedBox(width: 4),
                              Text("Mr. Sharma", style: AppText.bodySm.copyWith(color: AppColors.chalkTeal)),
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
    );
  }
}
