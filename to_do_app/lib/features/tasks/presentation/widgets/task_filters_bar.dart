import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../cubit/tasks_cubit.dart';

class TaskFiltersBar extends StatelessWidget {
  final TasksState state;
  final TasksCubit cubit;

  const TaskFiltersBar({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget chip(String label, bool active, VoidCallback onTap, {IconData? icon}) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: active,
          onSelected: (_) => onTap(),
          avatar: icon != null ? Icon(icon, size: 14, color: active ? Colors.white : p.textSecondary) : null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: cubit.setSearch,
          decoration: const InputDecoration(hintText: 'Search tasks by title, tag…', prefixIcon: Icon(Icons.search_rounded, size: 20), isDense: true),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              chip('Due date', state.sort == TaskSort.due, () => cubit.setSort(TaskSort.due)),
              chip('Priority', state.sort == TaskSort.priority, () => cubit.setSort(TaskSort.priority)),
              chip('Newest', state.sort == TaskSort.created, () => cubit.setSort(TaskSort.created)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              chip('All', state.statusFilter == TaskStatusFilter.all, () => cubit.setStatusFilter(TaskStatusFilter.all), icon: Icons.filter_list_rounded),
              chip('Pending', state.statusFilter == TaskStatusFilter.pending, () => cubit.setStatusFilter(TaskStatusFilter.pending)),
              chip('In progress', state.statusFilter == TaskStatusFilter.inProgress, () => cubit.setStatusFilter(TaskStatusFilter.inProgress)),
              chip('Completed', state.statusFilter == TaskStatusFilter.completed, () => cubit.setStatusFilter(TaskStatusFilter.completed)),
              chip('Overdue', state.statusFilter == TaskStatusFilter.overdue, () => cubit.setStatusFilter(TaskStatusFilter.overdue)),
              chip('High priority', state.highPriorityOnly, cubit.toggleHighPriority),
              chip('★ Favorites', state.favoriteOnly, cubit.toggleFavoriteOnly),
            ],
          ),
        ),
      ],
    );
  }
}
