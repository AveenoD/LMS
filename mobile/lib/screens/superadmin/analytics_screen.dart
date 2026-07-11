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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Analytics'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    StatCard(title: 'Total Institutes', value: totalTenants, icon: Icons.business, color: Colors.blue),
                    StatCard(title: 'Active Institutes', value: activeTenants, icon: Icons.check_circle, color: Colors.green),
                    StatCard(title: 'Total Students', value: totalStudents, icon: Icons.people, color: Colors.purple),
                    StatCard(title: 'Monthly Revenue', value: mrr, icon: Icons.currency_rupee, color: Colors.teal),
                    StatCard(title: 'On Trial', value: onTrial, icon: Icons.hourglass_top, color: Colors.orange),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
