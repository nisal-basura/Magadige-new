import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../dashboard/presentation/widgets/dashboard_charts.dart';
import '../cubit/analytics_cubit.dart';
import 'widgets/donut_chart_card.dart';
import 'widgets/heatmap_grid.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsCubit(context.read<TaskRepository>(), context.read<UserRepository>()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        final cubit = context.read<AnalyticsCubit>();
        final best = state.bestDay;
        final worst = state.worstDay;
        final priorities = state.priorityBreakdown;
        final categories = state.categoryBreakdown;

        final insights = [
          (Icons.local_fire_department_outlined, '${best.day} is your strongest day — you finish ${(best.rate * 100).round()}% of what you plan.'),
          (Icons.access_time_rounded, '${state.overdue} task${state.overdue == 1 ? " is" : "s are"} overdue right now. Clearing these first tends to unlock the rest of the week.'),
          (Icons.track_changes_outlined, '${state.highPriorityOpen} high-priority tasks are still open — consider tackling those before anything else.'),
          (Icons.emoji_events_outlined, 'Your current streak is ${state.streakCurrent} days, ${(state.streakLongest - state.streakCurrent).clamp(0, 999)} short of your all-time best.'),
          (Icons.wb_twilight_outlined, '${worst.day} sees the lowest completion rate — try scheduling lighter tasks that day.'),
        ];

        return AppScaffold(
          title: 'Analytics',
          subtitle: 'The story behind your last few weeks.',
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(label: const Text('This Week'), selected: state.range == AnalyticsRange.week, onSelected: (_) => cubit.setRange(AnalyticsRange.week)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('This Month'), selected: state.range == AnalyticsRange.month, onSelected: (_) => cubit.setRange(AnalyticsRange.month)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('This Year'), selected: state.range == AnalyticsRange.year, onSelected: (_) => cubit.setRange(AnalyticsRange.year)),
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
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(icon: Icons.check_rounded, label: 'Completion Rate', value: '${state.completionRate}%', color: const Color(0xFF16A374)),
                    _StatCard(icon: Icons.track_changes_outlined, label: 'Avg Tasks / Day', value: state.avgTasksPerDay.toStringAsFixed(1), color: p.brand),
                    _StatCard(icon: Icons.local_fire_department_outlined, label: 'Most Productive Day', value: best.day, color: p.accent),
                    _StatCard(icon: Icons.access_time_rounded, label: 'Total Focus Time', value: '${state.totalFocusHours.toStringAsFixed(1)}h', color: p.secondary),
                  ],
                ),
                const SizedBox(height: 14),
                const WeeklyBarChart(),
                const SizedBox(height: 14),
                DonutChartCard(
                  title: 'By Priority',
                  subtitle: 'Active task breakdown',
                  slices: [
                    DonutSlice('High', priorities[TaskPriority.high] ?? 0, const Color(0xFFEE4F4F)),
                    DonutSlice('Medium', priorities[TaskPriority.medium] ?? 0, const Color(0xFFFA8F0F)),
                    DonutSlice('Low', priorities[TaskPriority.low] ?? 0, const Color(0xFF22C58B)),
                  ],
                ),
                const SizedBox(height: 14),
                DonutChartCard(
                  title: 'By Category',
                  subtitle: 'Where your effort goes',
                  slices: TaskCategory.values.map((c) => DonutSlice(c.label, categories[c] ?? 0, c.color)).toList(),
                ),
                const SizedBox(height: 14),
                const HeatmapGrid(),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Insights', style: Theme.of(context).textTheme.titleLarge),
                      Text('What the data is telling you', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      ...insights.map((i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(color: p.brandSoft, shape: BoxShape.circle),
                                  child: Icon(i.$1, size: 15, color: p.brandStrong),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(i.$2, style: Theme.of(context).textTheme.bodyMedium)),
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
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
}
