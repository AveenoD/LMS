import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import 'tenants_screen.dart';
import 'plans_screen.dart';
import 'subscriptions_screen.dart';
import 'leads_screen.dart';
import 'broadcast_admins_screen.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F3),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2E6656).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.school, color: Color(0xFF2E6656), size: 24),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Super Admin', style: TextStyle(color: Color(0xFF1F2E27), fontSize: 16, fontWeight: FontWeight.bold)),
                Text('EdTech OS', style: TextStyle(color: Color(0xFF2E6656), fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1F2E27)),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1F2E27)),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('8', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: analyticsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
          ),
          data: (data) {
            final totalTenants = data['totalTenants']?.toString() ?? '0';
            final activeTenants = data['activeTenants']?.toString() ?? '0';
            final totalStudents = data['totalStudents']?.toString() ?? '0';
            final mrr = '₹${data['mrr'] ?? 0}';
            final onTrial = data['onTrial']?.toString() ?? '0';

            final graphDataRaw = data['graphData'] as List<dynamic>? ?? [];
            final barGroups = <BarChartGroupData>[];

            final List<dynamic> weeklyData = [];
            for (int i = 0; i < graphDataRaw.length; i++) {
              final day = (graphDataRaw[i]['day'] as num).toInt();
              // Pick 4 data points for thick bars: Day 7, 14, 21, and the last day
              if (day == 7 || day == 14 || day == 21 || day == graphDataRaw.length) {
                weeklyData.add(graphDataRaw[i]);
              }
            }

            int groupIndex = 0;
            for (var pt in weeklyData) {
              final students = (pt['students'] as num).toDouble();
              final institutes = (pt['institutes'] as num).toDouble();
              final revenue = (pt['revenue'] as num).toDouble();

              barGroups.add(BarChartGroupData(
                x: groupIndex,
                barRods: [
                  BarChartRodData(toY: students, color: Colors.green, width: 14, borderRadius: BorderRadius.circular(2)),
                  BarChartRodData(toY: institutes, color: Colors.purple, width: 14, borderRadius: BorderRadius.circular(2)),
                  BarChartRodData(toY: revenue, color: Colors.orange, width: 14, borderRadius: BorderRadius.circular(2)),
                ],
              ));
              groupIndex++;
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(dashboardProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, Super Admin 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2E27),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Here\'s what\'s happening with your platform today.',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF2E6656)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                                SizedBox(width: 6),
                                Text('11 May 2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Top Stat Cards (Horizontal Scroll)
                    SizedBox(
                      height: 145, // Reduced height to fix excessive spacing above numbers
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildTopCard('Total Institutes', totalTenants, '+8 this month', Icons.business, const Color(0xFFE8F5E9), Colors.green),
                          _buildTopCard('Total Students', totalStudents, '+12% this month', Icons.school, const Color(0xFFF3E5F5), Colors.purple),
                          _buildTopCard('Active Institutes', activeTenants, '+9% this month', Icons.bar_chart, const Color(0xFFFFF8E1), Colors.orange),
                          _buildTopCard('Total Revenue', mrr, '+15% this month', Icons.account_balance_wallet, const Color(0xFFE3F2FD), Colors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Platform Overview Graph
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Platform Overview',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                                ),
                                InkWell(
                                  onTap: () async {
                                    final current = ref.read(selectedAnalyticsMonthProvider);
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Select Month'),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: 12,
                                              itemBuilder: (context, index) {
                                                final date = DateTime(current.year, index + 1, 1);
                                                final isSelected = current.month == date.month;
                                                const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                                return ListTile(
                                                  title: Text(monthNames[index]),
                                                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                                                  onTap: () {
                                                    ref.read(selectedAnalyticsMonthProvider.notifier).state = date;
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final month = ref.watch(selectedAnalyticsMonthProvider);
                                        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                        return Row(
                                          children: [
                                            Text('${monthNames[month.month - 1]} ${month.year}', style: const TextStyle(fontSize: 12)),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.keyboard_arrow_down, size: 16),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildLegendItem('Students', Colors.green),
                                const SizedBox(width: 16),
                                _buildLegendItem('Institutes', Colors.purple),
                                const SizedBox(width: 16),
                                _buildLegendItem('Revenue (₹)', Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 180,
                              child: BarChart(
                                BarChartData(
                                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) {
                                      if (val >= 1000) {
                                        return Text('${(val / 1000).toStringAsFixed(1)}K', style: TextStyle(color: Colors.grey.shade600, fontSize: 10));
                                      }
                                      return Text('${val.toInt()}', style: TextStyle(color: Colors.grey.shade600, fontSize: 10));
                                    })),
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                                      String weekLabel = '';
                                      if (val.toInt() == 0) weekLabel = 'Week 1';
                                      else if (val.toInt() == 1) weekLabel = 'Week 2';
                                      else if (val.toInt() == 2) weekLabel = 'Week 3';
                                      else if (val.toInt() == 3) weekLabel = 'Week 4';

                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(weekLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      );
                                    })) ,
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: barGroups,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildQuickAction(context, 'Institutes', Icons.business, Colors.green, const TenantsScreen()),
                          _buildQuickAction(context, 'Plans', Icons.card_membership, Colors.purple, const PlansScreen()),
                          _buildQuickAction(context, 'Subscriptions', Icons.receipt_long, Colors.orange, const SubscriptionsScreen()),
                          _buildQuickAction(context, 'Leads', Icons.inbox, Colors.blue, const LeadsScreen()),
                          _buildQuickAction(context, 'Send Notice', Icons.campaign, Colors.pink, const BroadcastAdminsScreen()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Management Overview
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Management Overview',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.2,
                        children: [
                          _buildManagementTile('Institutes', 'Manage all institutes', totalTenants, Icons.business, const Color(0xFFE8F5E9), Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TenantsScreen()))),
                          _buildManagementTile('Active', 'Active institutes', activeTenants, Icons.check_circle, const Color(0xFFFFF8E1), Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TenantsScreen(initialFilter: 'active')))),
                          _buildManagementTile('Students', 'Manage all students', totalStudents, Icons.people, const Color(0xFFF3E5F5), Colors.purple, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dedicated tab not available yet')))),
                          _buildManagementTile('On Trial', 'Institutes on trial', onTrial, Icons.hourglass_top, const Color(0xFFE1F5FE), Colors.lightBlue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TenantsScreen(initialFilter: 'trial')))),
                          _buildManagementTile('Payments', 'Track all payments', mrr, Icons.account_balance_wallet, const Color(0xFFE8F5E9), Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen()))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopCard(String title, String value, String subtitle, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: iconColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27))),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.trending_up, color: Colors.green, size: 12),
              ),
              const SizedBox(width: 6),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2E27))),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color iconColor, Widget destination) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1F2E27)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagementTile(String title, String subtitle, String value, IconData icon, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27))),
                      Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27))),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
