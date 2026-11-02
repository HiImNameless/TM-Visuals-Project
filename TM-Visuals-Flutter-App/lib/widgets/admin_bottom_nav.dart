
import 'package:flutter/material.dart';
import 'admin_widgets.dart';

/// Shared navigation for all TM Visuals admin screens.
class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const routes = [
    '/',
    '/portfolio-content',
    '/calendar',
    '/admin-profile',
    '/more',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: adminGold,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == currentIndex) return;

        Navigator.of(context).pushReplacementNamed(routes[index]);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 26),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined, size: 26),
          label: 'Content',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined, size: 26),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined, size: 26),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu, size: 26),
          label: 'More',
        ),
      ],
    );
  }
}
