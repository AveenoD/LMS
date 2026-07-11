import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders a `NotificationItem[]` list (`{id, title, body, isRead,
/// createdAt}`) with a mark-read affordance on unread rows. Shared by every
/// role's inbox screen (Coaching Admin now; Student once its shell exists) —
/// the list rendering is identical, only the data source (which endpoint
/// backs it) differs per role.
class NotificationsListView extends StatelessWidget {
  final AsyncValue<List<dynamic>> notificationsAsync;
  final Future<void> Function() onRefresh;
  final Future<void> Function(int id) onMarkRead;

  const NotificationsListView({
    super.key,
    required this.notificationsAsync,
    required this.onRefresh,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return notificationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(child: Text('No notifications yet.'));
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index] as Map<String, dynamic>;
              final isRead = n['isRead'] == true;
              final body = n['body']?.toString();
              final createdAt = n['createdAt']?.toString();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isRead ? null : Colors.blue.withValues(alpha: 0.05),
                child: ListTile(
                  leading: Icon(
                    isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(n['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (body != null && body.isNotEmpty) Text(body),
                      if (createdAt != null)
                        Text(
                          createdAt.split('T').first,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                    ],
                  ),
                  isThreeLine: body != null && body.isNotEmpty,
                  trailing: isRead
                      ? null
                      : TextButton(
                          onPressed: () => onMarkRead(n['id'] as int),
                          child: const Text('Mark read'),
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
