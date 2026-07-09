import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../fees/fees_management_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/branding_screen.dart';
import '../management/students_screen.dart';
import '../management/teachers_screen.dart';
import '../management/batches_screen.dart';
import '../management/subjects_screen.dart';
import '../academics/timetable_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

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
      drawer: _buildDrawer(context, ref, authState, primary),
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
    // `GET /admin/dashboard` is the only dashboard endpoint this app has a
    // screen for today; other roles get an honest placeholder instead of
    // stat cards showing fabricated zeros.
    if (role != 'coaching_admin') {
      return Center(
        child: Text(
          role == null
              ? 'Loading your dashboard…'
              : 'A dedicated "$role" dashboard isn\'t built yet.',
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
        _buildStatCard('Total Students', students, Icons.people, Colors.blue),
        _buildStatCard('Total Teachers', teachers, Icons.badge, Colors.purple),
        _buildStatCard('Fees Collected', collected, Icons.attach_money, Colors.green),
        _buildStatCard('Fees Pending', pending, Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, AuthState authState, Color primary) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_circle, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text(authState.fullName ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 18)),
                Text(
                  authState.instituteName ?? authState.userRole ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text('MANAGEMENT', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          _buildDrawerItem(context, Icons.people, 'Students', const StudentsScreen()),
          _buildDrawerItem(context, Icons.badge, 'Teachers', const TeachersScreen()),
          _buildDrawerItem(context, Icons.class_, 'Batches', const BatchesScreen()),
          _buildDrawerItem(context, Icons.book, 'Subjects', const SubjectsScreen()),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text('ACADEMICS & FINANCE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          _buildDrawerItem(context, Icons.schedule, 'Timetable', const TimetableScreen()),
          _buildDrawerItem(context, Icons.payment, 'Fees Management', const FeesManagementScreen()),
          _buildDrawerItem(context, Icons.assessment, 'Reports', const ReportsScreen()),
          const Divider(),
          _buildDrawerItem(context, Icons.settings, 'Branding & Settings', const BrandingScreen()),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); // Close Drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
