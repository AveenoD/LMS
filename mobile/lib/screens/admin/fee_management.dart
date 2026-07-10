import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/chips.dart';

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: const GreenAppBar(
          title: "Fee Management",
          bottom: TabBar(
            indicatorColor: AppColors.brassGold,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Structures"),
              Tab(text: "Payments"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FeeOverviewTab(),
            Center(child: Text("Structures (Coming Soon)")),
            Center(child: Text("Payments (Coming Soon)")),
          ],
        ),
      ),
    );
  }
}



class _FeeOverviewTab extends StatefulWidget {
  const _FeeOverviewTab();

  @override
  State<_FeeOverviewTab> createState() => _FeeOverviewTabState();
}

class _FeeOverviewTabState extends State<_FeeOverviewTab> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.inkGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Collected", style: AppText.bodySm.copyWith(color: Colors.white.withOpacity(0.7))),
                Text("₹4,50,000", style: AppText.displayMd.copyWith(color: Colors.white)),
                Text("Pending: ₹75,000", style: AppText.bodySm.copyWith(color: AppColors.brassGold)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilterChipRow(
            items: const ["All", "Pending", "Overdue", "Paid"],
            selectedIndex: _selectedFilterIndex,
            onSelected: (index) => setState(() => _selectedFilterIndex = index),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Student Name ${index + 1}", style: AppText.labelMd),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("₹${1000 + index * 500} paid", style: AppText.bodySm.copyWith(color: AppColors.chalkTeal)),
                          Text("₹${index == 0 ? 500 : 0} pending", style: AppText.bodySm.copyWith(color: index == 0 ? AppColors.redInk : Colors.transparent)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.message_outlined, color: AppColors.brassGold),
                        onPressed: () {},
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

