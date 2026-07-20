import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

/// One row in a [MoreMenuScreen]. Either pushes [destination] or runs
/// [onTap] — exactly one of the two must be given.
class MoreMenuItem {
  final IconData icon;
  final String label;
  final Widget? destination;
  final VoidCallback? onTap;

  const MoreMenuItem({required this.icon, required this.label, this.destination, this.onTap})
      : assert(destination != null || onTap != null, 'Provide either destination or onTap');
}

/// The "More" tab shown in every role's bottom nav — holds secondary screens
/// that don't fit as primary tabs, plus a Logout action at the bottom. This
/// is the one place Logout lives, kept consistent across roles.
class MoreMenuScreen extends ConsumerWidget {
  final List<MoreMenuItem> items;

  const MoreMenuScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF1F2E27),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 36,
                  child: Icon(Icons.account_circle, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  authState.fullName ?? 'User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  authState.instituteName ?? authState.userRole ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          for (final item in items)
            ListTile(
              leading: Icon(item.icon, color: Colors.black87),
              title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
              onTap: item.onTap ??
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item.destination!),
                      ),
            ),
          const Divider(),
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
}
