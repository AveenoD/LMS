import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';

/// The "Dashboard" tab body for the Coaching Admin bottom-nav shell
/// ([CoachingAdminShell]). Navigation to other sections now lives in the
/// bottom nav / More tab, not a Drawer.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(authState.instituteName ?? 'EdTech Dashboard'),
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: dashboardAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                  ),
                  data: (data) => _buildBody(context, authState.userRole, data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String? role, Map<String, dynamic> data) {
    // `GET /admin/dashboard` is the only dashboard endpoint this screen has
    // stat cards for; other roles never reach this tab (see role_router.dart).
    if (role != 'coaching_admin') {
      return Center(
        child: Text(
          role == null ? 'Loading your dashboard…' : 'A dedicated "$role" dashboard isn\'t built yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final students = data['studentCount']?.toString() ?? '0';
    final teachers = data['teacherCount']?.toString() ?? '0';
    final collected = '${Constants.currencySymbol}${data['feesCollected'] ?? 0}';
    final pending = '${Constants.currencySymbol}${data['feesPending'] ?? 0}';

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatCard(title: 'Total Students', value: students, icon: Icons.people, color: Colors.blue),
        StatCard(title: 'Total Teachers', value: teachers, icon: Icons.badge, color: Colors.purple),
        StatCard(title: 'Fees Collected', value: collected, icon: Icons.attach_money, color: Colors.green),
        StatCard(title: 'Fees Pending', value: pending, icon: Icons.warning, color: Colors.red),
      ],
    );
  }
}
