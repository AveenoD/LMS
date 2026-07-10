import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class TeacherLayout extends StatelessWidget {
  final Widget child;

  const TeacherLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _TeacherBottomNav(),
    );
  }
}

class _TeacherBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.inkGreen,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.brassGold,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      selectedLabelStyle: AppText.caption.copyWith(fontSize: 10),
      unselectedLabelStyle: AppText.caption.copyWith(fontSize: 10),
      currentIndex: _calculateSelectedIndex(context),
      onTap: (int idx) => _onItemTapped(idx, context),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Content',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videocam_outlined),
          label: 'Live',
        ),
      ],
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/teacher/schedule')) return 0;
    if (location.startsWith('/teacher/attendance')) return 1;
    if (location.startsWith('/teacher/content')) return 2;
    if (location.startsWith('/teacher/live')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/teacher/schedule');
        break;
      case 1:
        context.go('/teacher/attendance');
        break;
      case 2:
        context.go('/teacher/content');
        break;
      case 3:
        context.go('/teacher/live');
        break;
    }
  }
}
