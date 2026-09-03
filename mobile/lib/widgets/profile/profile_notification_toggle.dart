import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/push_notification_service.dart';

/// Local key mirroring what `PushNotificationService` and login/logout
/// already toggle server-side registration for — this widget is just the
/// user-facing on/off switch wired to that existing send/remove-token flow.
const String _prefsKey = 'push_notifications_enabled';

/// Shared "Push Notifications" on/off row for every role's profile screen.
/// Turning it off unregisters this device's FCM token from the backend (no
/// more push delivery to this device); turning it on re-registers the
/// current token. The OS-level notification permission itself is a separate
/// system setting this toggle does not touch — if the user denied that
/// permission entirely, turning this on will re-register the token but no
/// pushes will visibly arrive until they also allow it in system settings.
class ProfileNotificationToggle extends StatefulWidget {
  const ProfileNotificationToggle({super.key});

  @override
  State<ProfileNotificationToggle> createState() =>
      _ProfileNotificationToggleState();
}

class _ProfileNotificationToggleState extends State<ProfileNotificationToggle> {
  bool _enabled = true;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool(_prefsKey) ?? true;
      _loading = false;
    });
  }

  Future<void> _onChanged(bool value) async {
    setState(() {
      _enabled = value;
      _busy = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);

    if (value) {
      await PushNotificationService().sendTokenToBackend();
    } else {
      await PushNotificationService().removeTokenFromBackend();
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Push Notifications',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primaryDark,
            ),
          ),
          subtitle: const Text(
            'Fee reminders, attendance, and other alerts',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          trailing: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: _enabled,
                  onChanged: _busy ? null : _onChanged,
                  activeThumbColor: AppColors.primary,
                ),
        ),
      ),
    );
  }
}
