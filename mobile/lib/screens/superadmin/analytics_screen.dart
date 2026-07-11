import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/stat_card.dart';

/// Super Admin's "Analytics" tab — `GET /superadmin/analytics` ->
/// `{totalTenants, activeTenants, totalStudents, mrr, onTrial}`. Reuses
/// [dashboardProvider], which already routes to this endpoint for the
/// super_admin role.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
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

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(dashboardProvider),
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2E27),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome back, Super Admin',
                    style: TextStyle(fontSize: 16, color: Color(0xFF2E6656)),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(title: 'Monthly Revenue', value: mrr, icon: Icons.currency_rupee, color: const Color(0xFFA87D26)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(title: 'Total Institutes', value: totalTenants, icon: Icons.business, color: const Color(0xFF2E6656)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Platform Metrics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2E27),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(title: 'Active Institutes', value: activeTenants, icon: Icons.check_circle, color: const Color(0xFF2E6656)),
                      StatCard(title: 'Total Students', value: totalStudents, icon: Icons.people, color: const Color(0xFF1F2E27)),
                      StatCard(title: 'On Trial', value: onTrial, icon: Icons.hourglass_top, color: const Color(0xFFA87D26)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
