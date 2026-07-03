import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/repositories/task_repository.dart';
import '../cubit/tasks_cubit.dart';
import 'widgets/create_task_sheet.dart';
import 'widgets/kanban_board.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filters_bar.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasksCubit(context.read<TaskRepository>()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final cubit = context.read<TasksCubit>();
        final filtered = state.filtered;
        final p = context.palette;

        return AppScaffold(
          title: 'Tasks',
          subtitle: 'Everything you need to do.',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showTaskFormSheet(context, onSave: (task, isNew) => cubit.saveTask(task, isNew: isNew)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Task'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${filtered.length} task${filtered.length == 1 ? "" : "s"}', style: Theme.of(context).textTheme.bodyMedium),
                    SegmentedButton<TaskViewMode>(
                      segments: const [
                        ButtonSegment(value: TaskViewMode.list, icon: Icon(Icons.view_agenda_outlined, size: 16)),
                        ButtonSegment(value: TaskViewMode.kanban, icon: Icon(Icons.view_column_outlined, size: 16)),
                      ],
                      selected: {state.view},
                      onSelectionChanged: (s) => cubit.setView(s.first),
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: TaskFiltersBar(state: state, cubit: cubit),
              ),
              if (state.selected.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: p.textPrimary, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${state.selected.length} selected', style: TextStyle(color: p.bgSurface, fontWeight: FontWeight.w700, fontSize: 12.5)),
                      Row(children: [
                        IconButton(icon: Icon(Icons.check_rounded, color: p.bgSurface, size: 18), onPressed: () => cubit.bulkApply('complete'), tooltip: 'Complete'),
                        IconButton(icon: Icon(Icons.archive_outlined, color: p.bgSurface, size: 18), onPressed: () => cubit.bulkApply('archive'), tooltip: 'Archive'),
                        IconButton(icon: Icon(Icons.copy_rounded, color: p.bgSurface, size: 18), onPressed: () => cubit.bulkApply('duplicate'), tooltip: 'Duplicate'),
                        IconButton(icon: Icon(Icons.delete_outline_rounded, color: p.bgSurface, size: 18), onPressed: () => cubit.bulkApply('delete'), tooltip: 'Delete'),
                      ]),
                    ],
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No matching tasks',
                        message: 'Try a different search term or clear your filters.',
                        actionLabel: 'Clear filters',
                        onAction: cubit.clearFilters,
                      )
                    : state.view == TaskViewMode.list
                        ? RefreshIndicator(
                            onRefresh: cubit.load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final t = filtered[i];
                                return TaskCard(
                                  task: t,
                                  selected: state.selected.contains(t.id),
                                  onSelectChanged: (_) => cubit.toggleSelect(t.id),
                                  onTap: () => context.push('/tasks/${t.id}'),
                                  onToggleFavorite: () => cubit.toggleFavorite(t),
                                  onDuplicate: () => cubit.duplicateTask(t),
                                  onArchive: () => cubit.archiveTask(t),
                                  onDelete: () => cubit.deleteTask(t),
                                );
                              },
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            child: KanbanBoard(
                              tasks: filtered,
                              onMove: (task, status) => cubit.updateStatus(task, status),
                              onOpen: (t) => context.push('/tasks/${t.id}'),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
