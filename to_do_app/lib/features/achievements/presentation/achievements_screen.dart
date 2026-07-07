import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/repositories/user_repository.dart';
import '../cubit/achievements_cubit.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AchievementsCubit(context.read<UserRepository>()),
      child: const _AchievementsView(),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  const _AchievementsView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<AchievementsCubit, AchievementsState>(
      builder: (context, state) {
        final cubit = context.read<AchievementsCubit>();
        if (state.user == null) return const AppScaffold(title: 'Achievements', body: Center(child: CircularProgressIndicator()));
        final user = state.user!;

        return AppScaffold(
          title: 'Achievements',
          subtitle: "Every streak and milestone you've earned.",
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Row(
                    children: [
                      _heroStat('${state.earnedCount}/${state.badges.length}', 'BADGES EARNED'),
                      _heroDivider(),
                      _heroStat('${user.productivityScore}', 'SCORE'),
                      _heroDivider(),
                      _heroStat('${user.streakCurrent}d', 'STREAK'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('All Badges', style: Theme.of(context).textTheme.titleLarge),
                Text('Keep working the system to unlock the rest', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.05),
                  itemBuilder: (context, i) {
                    final b = state.badges[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.borderSubtle)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: b.earned ? 1 : 0.4,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(color: p.brandSoft, shape: BoxShape.circle),
                              child: Icon(b.badge.icon, color: p.brandStrong, size: 24),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(b.badge.label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                          const SizedBox(height: 4),
                          Text(b.badge.description, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 6),
                          if (b.earned)
                            Text('Earned ${DateFormat('MMM d').format(b.earnedDate!)}', style: const TextStyle(color: AppColors.mint600, fontWeight: FontWeight.w700, fontSize: 10.5))
                          else ...[
                            AppProgressBar(progress: b.progress, height: 4, gradient: [p.accent, p.accent]),
                            const SizedBox(height: 3),
                            Text('${b.progress}% to unlock', style: TextStyle(fontSize: 10, color: p.textTertiary)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Milestones', style: Theme.of(context).textTheme.titleLarge),
                      Text('When you earned each badge', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 14),
                      ...state.earnedSortedByDate.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 3), decoration: const BoxDecoration(color: AppColors.mint500, shape: BoxShape.circle)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(b.badge.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      Text(DateFormat('MMMM d, y').format(b.earnedDate!), style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _heroStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'SpaceGrotesk')),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _heroDivider() => Container(width: 1, height: 36, color: Colors.white24);
}
