import 'package:flutter/material.dart';
import 'admin_widgets.dart';

/// Used by Brandon's screens. Teammates' screen implementations are untouched.
class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({super.key, required this.currentIndex, this.onReturn});
  final int currentIndex;
  final Future<void> Function()? onReturn;
  static const routes = ['/bookings', '/calendar', '/admin-profile', '/more'];
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    backgroundColor: adminGold,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.black54,
    showUnselectedLabels: true,
    onTap: (index) async {
      if (index == currentIndex) return;
      if (index == 1) {
        Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      await Navigator.of(context).pushNamed(routes[index]);
      if (context.mounted) await onReturn?.call();
    },
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.book_outlined),
        label: 'Bookings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month),
        label: 'Calendar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
    ],
  );
}
