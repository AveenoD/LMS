import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_providers.dart';
import '../../theme/app_colors.dart';
import 'student_chapter_content_screen.dart';
import 'student_notifications_screen.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final studentName = authState.fullName ?? 'Student';
    final instituteName = authState.instituteName ?? 'Academy';

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    final dashAsync = ref.watch(studentDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentDashboardProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // ── Gradient Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F2E27), Color(0xFF2E6656)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            instituteName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StudentNotificationsScreen()),
                              );
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$greeting, 👋',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        studentName,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Quick Stats ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: dashAsync.when(
              loading: () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => const _StatsErrorRow(),
              data: (dash) {
                final attendancePct = dash['attendancePct'] as int? ?? 0;
                final pendingFees = dash['pendingFees'] as int? ?? 0;
                final nextTest = dash['nextTest'] as Map<String, dynamic>?;
                final nextTestLabel = _formatTestLabel(nextTest);
                return SizedBox(
                  height: 96,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StatCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Attendance',
                        value: '$attendancePct%',
                        color: attendancePct >= 75 ? AppColors.success : AppColors.error,
                        bg: attendancePct >= 75 ? AppColors.successLight : AppColors.errorLight,
                      ),
                      _StatCard(
                        icon: Icons.quiz_rounded,
                        label: 'Upcoming Test',
                        value: nextTestLabel,
                        color: Colors.orange,
                        bg: AppColors.warningLight,
                      ),
                      _StatCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Fees Due',
                        value: pendingFees > 0 ? '₹${_formatAmount(pendingFees)}' : 'Paid ✓',
                        color: pendingFees > 0 ? AppColors.error : AppColors.success,
                        bg: pendingFees > 0 ? AppColors.errorLight : AppColors.successLight,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Continue Learning (recent video from backend) ─────────────────
          SliverToBoxAdapter(
            child: dashAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, e) => const SizedBox.shrink(),
              data: (dash) {
                final continueItem = dash['continuePlaying'] as Map<String, dynamic>?;
                final videos = dash['recentVideos'] as List<dynamic>? ?? [];
                
                if (continueItem == null && videos.isEmpty) return const SizedBox.shrink();
                
                final isContinue = continueItem != null;
                final item = isContinue ? continueItem : videos.first as Map<String, dynamic>;
                
                final title = item['title'] as String? ?? '';
                final subject = item['subject'] as String? ?? '';
                final progressSecs = item['progressSeconds'] as int? ?? 0;
                final durationMins = item['durationMinutes'] as int? ?? 1;
                final totalSecs = durationMins * 60;
                final progressPct = isContinue && totalSecs > 0 ? (progressSecs / totalSecs).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isContinue ? 'Continue Playing' : 'Recently Uploaded',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentChapterContentScreen(
                                chapter: {'id': item['chapterId'], 'name': item['chapter'] ?? 'Chapter'},
                                subjectName: subject,
                                autoSelectContentId: item['id'],
                                startAtSeconds: progressSecs,
                              ),
                            ),
                          );
                          ref.invalidate(studentDashboardProvider);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E6656), Color(0xFF1F2E27)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 30),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (subject.isNotEmpty)
                                          Text(
                                            subject,
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                                          ),
                                        const SizedBox(height: 2),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                                ],
                              ),
                              if (isContinue) ...[
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progressPct,
                                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    minHeight: 4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(progressPct * 100).toInt()}% completed',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Today's Schedule (real timetable) ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Classes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          dashAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
            ),
            error: (e, _) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Failed to load schedule', style: TextStyle(color: Colors.grey)),
              ),
            ),
            data: (dash) {
              final schedule = dash['todaySchedule'] as List<dynamic>? ?? [];
              if (schedule.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Text(
                      'No classes scheduled for today.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cls = schedule[index] as Map<String, dynamic>;
                    final isLast = index == schedule.length - 1;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, isLast ? 24 : 10),
                      child: _ScheduleCard(
                        subject: cls['subject'] as String? ?? '',
                        teacher: cls['teacherName'] as String? ?? '',
                        time: cls['startTime'] as String? ?? '',
                      ),
                    );
                  },
                  childCount: schedule.length,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  /// Format test label — show date if available, else "Upcoming"
  static String _formatTestLabel(Map<String, dynamic>? test) {
    if (test == null) return 'None';
    final title = test['title'] as String? ?? 'Test';
    final date = test['testDate'] as String?;
    if (date == null) return title.length > 12 ? '${title.substring(0, 12)}…' : title;
    // date is YYYY-MM-DD from backend
    try {
      final d = DateTime.parse(date);
      final today = DateTime.now();
      if (d.year == today.year && d.month == today.month && d.day == today.day) {
        return 'Today';
      }
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return 'Upcoming';
    }
  }

  static String _formatAmount(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return amount.toString();
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _StatsErrorRow extends StatelessWidget {
  const _StatsErrorRow();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: const [
          _StatCard(icon: Icons.bar_chart_rounded, label: 'Attendance', value: '—', color: Colors.grey, bg: Color(0xFFF5F5F5)),
          _StatCard(icon: Icons.quiz_rounded, label: 'Upcoming Test', value: '—', color: Colors.grey, bg: Color(0xFFF5F5F5)),
          _StatCard(icon: Icons.account_balance_wallet_outlined, label: 'Fees Due', value: '—', color: Colors.grey, bg: Color(0xFFF5F5F5)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String time;
  const _ScheduleCard({required this.subject, required this.teacher, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.book_outlined, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primaryDark)),
                const SizedBox(height: 2),
                Text(teacher, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
            child: Text(
              time,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
