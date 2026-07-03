import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/motivation.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/repositories/dream_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../cubit/dashboard_cubit.dart';
import 'widgets/badges_dream_activity.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/focus_list.dart';
import 'widgets/greeting_header.dart';
import 'widgets/mini_calendar.dart';
import 'widgets/motivation_cards.dart';
import 'widgets/stat_tiles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        context.read<TaskRepository>(),
        context.read<DreamRepository>(),
        context.read<UserRepository>(),
      ),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final period = context.watch<ThemeCubit>().state.period;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        if (state.user == null) {
          return const AppScaffold(title: 'Dashboard', body: Center(child: CircularProgressIndicator()));
        }

        final motivation = Motivation.messageFor(
          completed: state.completed,
          pending: state.pending,
          overdue: state.overdue,
          total: state.tasks.length,
        );
        final quote = Motivation.inspirationFor(period, overdue: state.overdue);
        final firstName = state.user!.name.split(' ').first;

        return AppScaffold(
          title: 'Dashboard',
          subtitle: "Here's what's on your plate today.",
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GreetingHeader(firstName: firstName),
                const SizedBox(height: 20),
                StatTilesRow(
                  completed: state.completed,
                  pending: state.pending,
                  overdue: state.overdue,
                  highPriority: state.highPriority,
                ),
                const SizedBox(height: 14),
                MotivationCard(message: motivation),
                const SizedBox(height: 14),
                InspirationCard(quote: quote),
                const SizedBox(height: 14),
                FocusList(
                  tasks: state.todayFocus,
                  onToggle: cubit.toggleComplete,
                  onQuickAdd: cubit.quickAddTask,
                  onOpen: (t) => context.push('/tasks/${t.id}'),
                ),
                const SizedBox(height: 14),
                MiniCalendar(tasks: state.tasks),
                const SizedBox(height: 14),
                const WeeklyBarChart(),
                const SizedBox(height: 14),
                const MonthlyLineChart(),
                const SizedBox(height: 14),
                ProductivityScoreCard(
                  score: state.user!.productivityScore,
                  streakCurrent: state.user!.streakCurrent,
                  streakLongest: state.user!.streakLongest,
                  completionRate: state.completionRate,
                ),
                const SizedBox(height: 14),
                BadgesPreview(badges: state.badges),
                const SizedBox(height: 14),
                DreamNudgeCard(dream: state.topDream, onView: () => context.go('/dreams')),
                const SizedBox(height: 14),
                UpcomingTasksList(tasks: state.upcoming),
                const SizedBox(height: 14),
                RecentActivityList(activity: state.activity),
              ],
            ),
          ),
        );
      },
    );
  }
}
