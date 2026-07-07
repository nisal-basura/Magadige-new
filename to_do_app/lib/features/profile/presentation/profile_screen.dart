import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/theme_toggle_row.dart';
import '../../../data/repositories/dream_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(context.read<UserRepository>(), context.read<TaskRepository>(), context.read<DreamRepository>()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.user == null) return const AppScaffold(title: 'Profile', body: Center(child: CircularProgressIndicator()));
        final user = state.user!;

        return AppScaffold(
          title: 'Profile',
          subtitle: 'Your identity, stats, and achievements.',
          showThemeToggle: false,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(22), border: Border.all(color: p.borderSubtle)),
                child: Column(
                  children: [
                    AvatarInitials(initials: user.avatarInitials, size: 72),
                    const SizedBox(height: 12),
                    Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                    if (user.headline != null)
                      Text(user.headline!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      children: [
                        Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                        Text('Since ${user.memberSince}', style: Theme.of(context).textTheme.bodySmall),
                        Text(user.timezone, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(content: Text('Profile editing is a UI demo only.'))),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _statCard(context, Icons.check_rounded, '${state.completedTasks}', 'Tasks Completed', AppColors.mint600),
                  _statCard(context, Icons.local_fire_department_outlined, '${user.streakCurrent}d', 'Current Streak', AppColors.coral600),
                  _statCard(context, Icons.emoji_events_outlined, '${user.streakLongest}d', 'Longest Streak', p.accent),
                  _statCard(context, Icons.star_border_rounded, '${state.dreamsInMotion}', 'Dreams in Motion', p.brand),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Productivity Score', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(alignment: Alignment.center, children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: user.productivityScore / 100),
                            duration: const Duration(milliseconds: 900),
                            builder: (context, v, _) => CircularProgressIndicator(value: v, strokeWidth: 10, backgroundColor: p.bgSunken, valueColor: AlwaysStoppedAnimation(p.brand)),
                          ),
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('${user.productivityScore}', style: Theme.of(context).textTheme.headlineMedium),
                            Text('SCORE', style: TextStyle(fontSize: 10, color: p.textTertiary, fontWeight: FontWeight.w800)),
                          ]),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
                    Text('Badges earned along the way', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.badges.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                      itemBuilder: (context, i) {
                        final b = state.badges[i];
                        return Opacity(
                          opacity: b.earned ? 1 : 0.35,
                          child: Column(
                            children: [
                              Container(width: 40, height: 40, decoration: BoxDecoration(color: p.brandSoft, shape: BoxShape.circle), child: Icon(b.badge.icon, size: 18, color: p.brandStrong)),
                              const SizedBox(height: 4),
                              Text(b.badge.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700), maxLines: 2),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Theme', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    const ThemeToggleRow(),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => context.go('/settings'),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Manage more appearance options in '),
                            TextSpan(text: 'Settings', style: TextStyle(color: p.brand, fontWeight: FontWeight.w700)),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connected Accounts', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    _connectedRow(context, Icons.g_mobiledata_rounded, 'Google', user.email, connected: true),
                    const Divider(height: 20),
                    _connectedRow(context, Icons.code_rounded, 'GitHub', 'Not connected', connected: false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String value, String label, Color color) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _connectedRow(BuildContext context, IconData icon, String name, String status, {required bool connected}) {
    final p = context.palette;
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: p.bgSunken, shape: BoxShape.circle), child: Icon(icon, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(status, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (connected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(999)),
            child: const Text('Connected', style: TextStyle(color: AppColors.mint600, fontWeight: FontWeight.w700, fontSize: 11)),
          )
        else
          OutlinedButton(onPressed: () {}, child: const Text('Connect')),
      ],
    );
  }
}
