import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/local_data_store.dart';
import '../../features/shell/presentation/app_drawer.dart';
import 'avatar_initials.dart';
import 'theme_toggle_row.dart';

/// Shared page chrome for every main (non-auth) screen: drawer, title,
/// theme toggle, notification bell, and avatar shortcut — the Flutter
/// equivalent of the web app's shared topbar rendered by shell.js.
class AppScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? extraActions;
  final bool showThemeToggle;

  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.floatingActionButton,
    this.extraActions,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    final unread = LocalDataStore.instance.notifications.where((n) => n.unread).length;
    final user = LocalDataStore.instance.user;

    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, overflow: TextOverflow.ellipsis),
            if (subtitle != null)
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
        actions: [
          if (showThemeToggle) const Padding(padding: EdgeInsets.only(right: 8), child: ThemeToggleRow()),
          ...?extraActions,
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => context.go('/inbox'),
              ),
              if (unread > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go('/profile'),
              child: AvatarInitials(initials: user.avatarInitials, size: 34),
            ),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}
