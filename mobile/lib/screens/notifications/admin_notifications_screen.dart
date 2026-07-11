import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/notifications_list_view.dart';

/// Coaching Admin's own notification inbox — `GET /admin/notifications`.
class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: NotificationsListView(
        notificationsAsync: notificationsAsync,
        onRefresh: () async => ref.invalidate(notificationsProvider),
        onMarkRead: (id) async {
          await markNotificationRead(ref.read(apiServiceProvider), id);
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationCountProvider);
        },
      ),
    );
  }
}
