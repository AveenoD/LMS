import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class StudentLayout extends StatelessWidget {
  final Widget child;

  const StudentLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _StudentBottomNav(),
    );
  }
}

class _StudentBottomNav extends StatelessWidget {
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
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Videos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videocam_outlined),
          label: 'Live',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Fees',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/student/home')) return 0;
    if (location.startsWith('/student/videos')) return 1;
    if (location.startsWith('/student/live')) return 2;
    if (location.startsWith('/student/fees')) return 3;
    if (location.startsWith('/student/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/student/home');
        break;
      case 1:
        context.go('/student/videos');
        break;
      case 2:
        context.go('/student/live');
        break;
      case 3:
        context.go('/student/fees');
        break;
      case 4:
        context.go('/student/profile');
        break;
    }
  }
}
