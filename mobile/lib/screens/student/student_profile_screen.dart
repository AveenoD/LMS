import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/student_providers.dart';
import '../auth/login_screen.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load profile: $e', style: const TextStyle(color: Colors.grey))),
        data: (profile) {
          final studentName = profile['fullName'] as String? ?? 'Student';
          final phone = profile['phone'] as String? ?? 'Not provided';
          final batch = profile['batchName'] as String? ?? 'No batch';
          final rollNoStr = profile['rollNo'] != null ? 'Roll No: ${profile['rollNo']}' : 'No Roll No';
          final parentPhone = profile['parentPhone'] as String? ?? 'Not provided';
          
          final attendancePct = profile['attendancePct'] as int? ?? 0;
          final testsGiven = profile['testsGiven'] as int? ?? 0;
          final avgScore = profile['avgScore'] as int?;

          return CustomScrollView(
            slivers: [
              // ── Profile Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1F2E27), Color(0xFF2E6656)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(color: const Color(0xFFA87D26), width: 3),
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
                          ),
                          const SizedBox(height: 14),
                          Text(studentName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(batch, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(rollNoStr, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11)),
                          const SizedBox(height: 20),
                          // Quick stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _QuickStat(label: 'Attendance', value: '$attendancePct%'),
                              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
                              _QuickStat(label: 'Tests Given', value: '$testsGiven'),
                              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
                              _QuickStat(label: 'Avg Score', value: avgScore != null ? '$avgScore%' : '--'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Info Card ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark)),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: phone),
                        const Divider(height: 20),
                        _InfoRow(icon: Icons.family_restroom_rounded, label: 'Parent Contact', value: parentPhone),
                      ],
                    ),
                  ),
                ),
              ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Menu Items ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.calendar_month_rounded,
                      iconBg: AppColors.successLight,
                      iconColor: AppColors.success,
                      label: 'My Attendance',
                      subtitle: 'View monthly calendar report',
                      onTap: () => _showAttendanceSheet(context),
                    ),
                    const Divider(height: 1, indent: 60),
                    _MenuItem(
                      icon: Icons.analytics_rounded,
                      iconBg: AppColors.infoLight,
                      iconColor: AppColors.info,
                      label: 'Performance Analytics',
                      subtitle: 'Subject-wise score breakdown',
                      onTap: () => _showPerformanceSheet(context),
                    ),
                    const Divider(height: 1, indent: 60),
                    _MenuItem(
                      icon: Icons.account_balance_wallet_rounded,
                      iconBg: AppColors.warningLight,
                      iconColor: Colors.orange,
                      label: 'Fee Details',
                      subtitle: 'Paid ₹8,000 • Pending ₹2,000',
                      onTap: () => _showFeesSheet(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Logout ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: GestureDetector(
                onTap: () => _confirmLogout(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      SizedBox(width: 10),
                      Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }),
  );
}

  // ── Attendance bottom sheet ─────────────────────────────────────────────
  void _showAttendanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttendanceSheet(),
    );
  }

  // ── Performance bottom sheet ────────────────────────────────────────────
  void _showPerformanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PerformanceSheet(),
    );
  }

  // ── Fees bottom sheet ───────────────────────────────────────────────────
  void _showFeesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeesSheet(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Profile Widgets ─────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String label, value;
  const _QuickStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.iconBg, required this.iconColor, required this.label, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primaryDark)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
      ),
    );
  }
}

// ─── Bottom Sheets ────────────────────────────────────────────────────────────

class _AttendanceSheet extends ConsumerWidget {
  // ignore: prefer_const_constructors_in_immutables
  _AttendanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(studentAttendanceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('My Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ),
            const Divider(height: 1),
            Expanded(
              child: attendanceAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (monthly) {
                  if (monthly.isEmpty) {
                    return const Center(child: Text('No attendance data available.'));
                  }
                  return ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    children: monthly.map((m) {
                      final monthName = m['month'] as String;
                      final total = m['total'] as int;
                      final present = m['present'] as int;
                      final pct = total > 0 ? (present / total * 100).toInt() : 0;
                      final color = pct >= 75 ? AppColors.success : pct >= 50 ? Colors.orange : AppColors.error;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(monthName.trim(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                  const SizedBox(height: 4),
                                  Text('Present: $present / $total days', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('$pct%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceSheet extends ConsumerWidget {
  // ignore: prefer_const_constructors_in_immutables
  _PerformanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(studentPerformanceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Performance Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ),
            const Divider(height: 1),
            Expanded(
              child: performanceAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return const Center(child: Text('No performance data available.'));
                  }
                  return ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    children: subjects.map((s) {
                      final subjectName = s['subject'] as String;
                      final score = s['obtainedMarks'] as int;
                      final max = s['totalMarks'] as int;
                      final pct = max > 0 ? score / max : 0.0;
                      final color = pct >= 0.75 ? AppColors.success : pct >= 0.5 ? Colors.orange : AppColors.error;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                      minHeight: 7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text('$score/$max', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeesSheet extends ConsumerWidget {
  // ignore: prefer_const_constructors_in_immutables
  _FeesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(studentFeesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Fee Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ),
            const Divider(height: 1),
            Expanded(
              child: feesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (feesData) {
                  final total = feesData['total'] as int? ?? 0;
                  final paid = feesData['paid'] as int? ?? 0;
                  final pending = feesData['pending'] as int? ?? 0;
                  final payments = (feesData['payments'] as List<dynamic>?) ?? [];

                  return ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1F2E27), Color(0xFF2E6656)]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Total Fees', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                                Text('₹$total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                              ]),
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('Paid', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                              Text('₹$paid', style: const TextStyle(color: Color(0xFFA87D26), fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Pending: ₹$pending', style: TextStyle(color: AppColors.error.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w600)),
                            ]),
                          ],
                        ),
                      ),
                      if (pending > 0) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA87D26),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Pay Pending Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 14)),
                      const SizedBox(height: 10),
                      if (payments.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('No payment history found', style: TextStyle(color: Colors.grey))),
                        )
                      ] else ...[
                        ...payments.map((p) {
                          final pDateStr = p['paidOn']?.toString() ?? '';
                          final pDate = DateTime.tryParse(pDateStr) ?? DateTime.now();
                          final formattedDate = '${pDate.day} ${_getMonth(pDate.month)} ${pDate.year}';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['receiptNo']?.toString() ?? 'Receipt', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                      const SizedBox(height: 4),
                                      Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Text('₹${p['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 15)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m >= 1 && m <= 12) return months[m - 1];
    return '';
  }
}
