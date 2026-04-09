import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
            top: BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group_rounded),
              label: 'Leads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign_rounded),
              label: 'Campaigns',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded),
              activeIcon: Icon(Icons.more_horiz_rounded),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/history')) return 0;
    if (location.startsWith('/leads')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/campaigns')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/history');
        break;
      case 1:
        context.go('/leads');
        break;
      case 2:
        // context.go('/reports');
        break;
      case 3:
        // context.go('/campaigns');
        break;
      case 4:
        // context.go('/more');
        break;
    }
  }
}
