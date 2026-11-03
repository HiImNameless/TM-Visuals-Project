import 'package:flutter/material.dart';

/// Add Invoice's simple title and back-button style for secondary pages.
class AdminPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminPageAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleSpacing: 16,
    titleTextStyle: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: Colors.white),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    actions: actions,
  );
}
