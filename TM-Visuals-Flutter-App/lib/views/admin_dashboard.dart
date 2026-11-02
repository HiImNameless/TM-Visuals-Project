import 'package:flutter/material.dart';
import '../widgets/admin_bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:photography_flutter_application/views/admin_sign_in.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const Color backgroundColor = Colors.black;
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
  backgroundColor: backgroundColor,
  iconTheme: const IconThemeData(color: Colors.white),
  title: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'TM ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'Visuals',
        style: TextStyle(
          color: accentColor,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  centerTitle: true,
  bottom: const PreferredSize(
    preferredSize: Size.fromHeight(1),
    child: Divider(height: 1, color: accentColor),
  ),
),
      // Admin options menu
      drawer: Drawer(
  backgroundColor: cardColor,
  child: SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'DASHBOARD',
            style: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(color: accentColor),

        const Spacer(),

        const Divider(color: Colors.white24),

        _menuItem(
          context,
          Icons.logout,
          'Log Out',
        ),

        const SizedBox(height: 12),
      ],
    ),
  ),
),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'DASHBOARD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Here's an overview of TM Visuals.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 22),

          // Dashboard statistics
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions,
                  label: 'Pending Bookings',
                  value: '2',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_month,
                  label: 'Confirmed Bookings',
                  value: '3',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline,
                  label: 'Pending Deliveries',
                  value: '1',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.photo_library_outlined,
                  label: 'Completed Orders',
                  value: '4',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          
const Text(
  'Upcoming Bookings',
  style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 12),

Expanded(
  child: Container(
  width: double.infinity,
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AdminDashboard.cardColor,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: AdminDashboard.accentColor,
      width: 1,
    ),
  ),
  child: const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.event_available_outlined,
        color: AdminDashboard.accentColor,
        size: 28,
      ),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          'Upcoming confirmed bookings will appear here:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ),
    ],
  ),
),
),
],
),

      // Bottom navigation styled to match the existing screens
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  
static Widget _menuItem(
  BuildContext context,
  IconData icon,
  String title) {
  return ListTile(
    leading: Icon(icon, color: Colors.redAccent),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    onTap: () async {
      if (title != 'Log Out') return;

      try {
        await Supabase.instance.client.auth.signOut();

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminSignInScreen(),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error logging out: $e')),
          );
        }
      }
    },
  );
}


}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminDashboard.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminDashboard.accentColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AdminDashboard.accentColor, size: 27),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}