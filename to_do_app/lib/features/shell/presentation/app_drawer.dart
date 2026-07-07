import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../data/repositories/auth_repository.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

const _mainItems = [
  _NavItem('Dashboard', Icons.grid_view_rounded, '/dashboard'),
  _NavItem('Tasks', Icons.checklist_rounded, '/tasks'),
  _NavItem('Calendar', Icons.calendar_month_outlined, '/calendar'),
  _NavItem('Dream Board', Icons.star_border_rounded, '/dreams'),
];

const _workspaceItems = [
  _NavItem('Analytics', Icons.bar_chart_rounded, '/analytics'),
  _NavItem('Achievements', Icons.emoji_events_outlined, '/achievements'),
  _NavItem('Inbox', Icons.inbox_outlined, '/inbox'),
  _NavItem('Profile', Icons.person_outline_rounded, '/profile'),
  _NavItem('Settings', Icons.settings_outlined, '/settings'),
];

/// Primary navigation surface — the Flutter equivalent of the web app's
/// grouped sidebar (MAIN / WORKSPACE), including the daily-reminder nudge
/// and the user pod with sign-out.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final user = context.watch<SessionCubit>().state.user;
    if (user == null) return const SizedBox.shrink();

    Widget navTile(_NavItem item) {
      final active = currentRoute == item.route;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Material(
          color: active ? p.brandSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.of(context).pop();
              if (!active) context.go(item.route);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: active ? p.brandStrong : p.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active ? p.brandStrong : p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget groupLabel(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 12, 6),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: p.textTertiary),
          ),
        );

    return Drawer(
      backgroundColor: p.bgSurface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: LinearGradient(colors: p.heroGradient),
                    ),
                    alignment: Alignment.center,
                    child: const Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 10),
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w800),
                      children: [
                        const TextSpan(text: 'Magadige '),
                        TextSpan(text: 'Task', style: TextStyle(color: p.brand)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  groupLabel('Main'),
                  ..._mainItems.map(navTile),
                  groupLabel('Workspace'),
                  ..._workspaceItems.map(navTile),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✦ Daily reminder',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 6),
                    const Text(
                      '"Today\'s work builds tomorrow\'s dream."',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          side: BorderSide.none,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/dreams');
                        },
                        child: const Text('View dreams', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  AvatarInitials(initials: user.avatarInitials, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                        Row(
                          children: [
                            Icon(Icons.workspace_premium, size: 11, color: p.accent),
                            const SizedBox(width: 3),
                            Text(user.plan, style: TextStyle(fontSize: 11, color: p.accent, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    icon: Icon(Icons.logout_rounded, size: 20, color: p.textTertiary),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await context.read<AuthRepository>().logout();
                      if (context.mounted) context.read<SessionCubit>().setUnauthenticated();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
