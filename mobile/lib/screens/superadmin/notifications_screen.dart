import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';


import 'leads_screen.dart';
import 'subscriptions_screen.dart';
import 'tenants_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Dummy data for notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'lead',
      'title': 'New Demo Request',
      'description': 'Rahul Sharma from Apex Institute requested a demo.',
      'time': DateTime.now().subtract(const Duration(minutes: 15)),
      'isRead': false,
    },
    {
      'id': '2',
      'type': 'payment',
      'title': 'Payment Received',
      'description': 'Success Academy paid ₹2500 for the Pro Plan.',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'expiring',
      'title': 'Subscription Expiring Soon',
      'description': 'Pioneer Classes trial ends in 3 days.',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
    },
    {
      'id': '4',
      'type': 'system',
      'title': 'System Maintenance',
      'description': 'Scheduled downtime on Sunday at 2:00 AM.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    setState(() {
      notification['isRead'] = true;
    });

    // Navigate based on type
    switch (notification['type']) {
      case 'lead':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadsScreen()));
        break;
      case 'payment':
      case 'expiring':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen()));
        break;
      case 'system':
      default:
        // No specific screen or just show a dialog
        break;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No new notifications', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notification['type']) {
      case 'lead':
        iconData = Icons.person_add;
        iconColor = AppColors.info;
        bgColor = AppColors.infoLight;
        break;
      case 'payment':
        iconData = Icons.payments;
        iconColor = AppColors.success;
        bgColor = AppColors.successLight;
        break;
      case 'expiring':
        iconData = Icons.warning_rounded;
        iconColor = AppColors.warning;
        bgColor = AppColors.warningLight;
        break;
      case 'system':
      default:
        iconData = Icons.info;
        iconColor = Colors.grey.shade700;
        bgColor = AppColors.borderLight;
        break;
    }

    final isRead = notification['isRead'] as bool;

    return Container(
      color: isRead ? Colors.transparent : AppColors.info.withValues(alpha: 0.03),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            if (!isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['description'],
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              _timeAgo(notification['time']),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }
}
