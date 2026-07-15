import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'students_screen.dart';

class StudentDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  ConsumerState<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends ConsumerState<StudentDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final fullName = s['fullName']?.toString() ?? 'Unknown';
    final rollNo = s['rollNo']?.toString() ?? 'N/A';
    final grade = s['grade']?.toString() ?? 'N/A';
    final batchName = s['batchName']?.toString() ?? 'N/A';
    final attendance = num.tryParse(s['attendance']?.toString() ?? '0') ?? 0;
    final pendingFees = num.tryParse(s['pendingFees']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: const Text('Student Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showAddStudentDialog(context, ref, student: widget.student);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Top section with Dark Green Background extended
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 60,
                color: AppColors.primaryDark,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 40, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    fullName,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Roll No: $rollNo  •  Class $grade', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text('Batch: $batchName', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Metrics Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildMetricCard(Icons.school, '${attendance.toInt()}%', 'Attendance', Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(Icons.warning_amber_rounded, '₹$pendingFees', 'Fees Pending', Colors.red)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildActionIcon(Icons.edit, 'Edit Student'),
                const SizedBox(width: 16),
                _buildActionIcon(Icons.fact_check_outlined, 'Mark Attendance'),
                const SizedBox(width: 16),
                _buildActionIcon(Icons.account_balance_wallet_outlined, 'Add Fees'),
                const SizedBox(width: 16),
                _buildActionIcon(Icons.bar_chart, 'View Reports'),
                const SizedBox(width: 16),
                _buildActionIcon(Icons.more_horiz, 'More'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Academics'),
                Tab(text: 'Attendance'),
                Tab(text: 'Fees'),
                Tab(text: 'Documents'),
                Tab(text: 'Activity'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                const Center(child: Text('Academics (Coming Soon)')),
                const Center(child: Text('Attendance (Coming Soon)')),
                const Center(child: Text('Fees (Coming Soon)')),
                const Center(child: Text('Documents (Coming Soon)')),
                const Center(child: Text('Activity (Coming Soon)')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final s = widget.student;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Personal Information',
                  icon: Icons.person,
                  fields: {
                    'Full Name': s['fullName']?.toString() ?? 'N/A',
                    'Phone Number': s['phone']?.toString() ?? 'N/A',
                  },
                  showViewMore: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  title: 'Parent / Guardian Info',
                  icon: Icons.people,
                  fields: {
                    'Parent Name': s['parentName']?.toString() ?? 'N/A',
                    'Parent Phone': s['parentPhone']?.toString() ?? 'N/A',
                  },
                  showViewMore: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Academic Information',
                  icon: Icons.school,
                  fields: {
                    'Class': s['grade']?.toString() ?? 'N/A',
                    'Batch': s['batchName']?.toString() ?? 'N/A',
                    'Roll No': s['rollNo']?.toString() ?? 'N/A',
                  },
                  showViewMore: false,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()), // Empty space to match the two-column layout roughly
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String value, String title, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 80,
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 4),
            Icon(icon, color: Colors.grey.shade700, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade800), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Map<String, String> fields, bool showViewMore = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 16),
          ...fields.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text(e.key, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))),
                    Expanded(flex: 3, child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
                  ],
                ),
              )),
          if (showViewMore) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('View More', style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_right, size: 14, color: AppColors.primaryDark),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
