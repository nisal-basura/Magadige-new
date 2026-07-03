import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/priority_dot.dart';
import '../../../data/repositories/task_repository.dart';
import '../cubit/task_details_cubit.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskDetailsCubit(context.read<TaskRepository>(), taskId),
      child: const _TaskDetailsView(),
    );
  }
}

class _TaskDetailsView extends StatelessWidget {
  const _TaskDetailsView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<TaskDetailsCubit, TaskDetailsState>(
      builder: (context, state) {
        final cubit = context.read<TaskDetailsCubit>();
        if (state.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final task = state.task;
        if (task == null) {
          return const Scaffold(body: Center(child: Text('Task not found')));
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Task Details'),
              actions: [
                IconButton(
                  icon: Icon(task.favorite ? Icons.star_rounded : Icons.star_border_rounded, color: task.favorite ? p.accent : null),
                  onPressed: cubit.toggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    await cubit.delete();
                    if (context.mounted) context.pop();
                  },
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  AppBadge(label: task.status.label, color: task.status.color, background: task.status.color.withValues(alpha: 0.14)),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    PriorityDot(priority: task.priority),
                    const SizedBox(width: 4),
                    Text('${task.priority.label} priority', style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                  Text('Due ${DateFormat('MMM d, y').format(task.due)}', style: Theme.of(context).textTheme.bodyMedium),
                ]),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.borderSubtle)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DESCRIPTION', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 6),
                      Text(task.description.isEmpty ? 'No description added yet.' : task.description, style: Theme.of(context).textTheme.bodyLarge),
                      const Divider(height: 28),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('PROGRESS', style: Theme.of(context).textTheme.labelSmall),
                        Text('${task.progress}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ]),
                      const SizedBox(height: 8),
                      AppProgressBar(progress: task.progress),
                      const SizedBox(height: 18),
                      Text('SUBTASKS', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 4),
                      if (task.subtasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('No subtasks added.', style: Theme.of(context).textTheme.bodyMedium),
                        )
                      else
                        ...task.subtasks.asMap().entries.map((e) {
                          final done = cubit.isSubtaskDone(e.key);
                          return CheckboxListTile(
                            value: done,
                            onChanged: (_) => cubit.toggleSubtask(e.key),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 13.5,
                                decoration: done ? TextDecoration.lineThrough : null,
                                color: done ? p.textTertiary : p.textPrimary,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.borderSubtle)),
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: p.brand,
                        unselectedLabelColor: p.textTertiary,
                        indicatorColor: p.brand,
                        tabs: const [Tab(text: 'Timeline'), Tab(text: 'Comments'), Tab(text: 'Activity')],
                      ),
                      SizedBox(
                        height: 260,
                        child: TabBarView(
                          children: [
                            _TimelineTab(task: task),
                            _CommentsTab(cubit: cubit, comments: state.comments),
                            _ActivityTab(task: task),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.borderSubtle)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DETAILS', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 8),
                      _detailRow(context, 'Category', task.category.label),
                      _detailRow(context, 'Estimated time', task.estimate),
                      _detailRow(context, 'Created', DateFormat('MMM d, y').format(task.createdAt), showDivider: false),
                      if (task.tags.isNotEmpty) ...[
                        const Divider(height: 24),
                        Wrap(spacing: 6, children: task.tags.map((t) => Chip(label: Text('#$t', style: const TextStyle(fontSize: 11)))).toList()),
                      ],
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

  Widget _detailRow(BuildContext context, String label, String value, {bool showDivider = true}) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: p.borderSubtle)) : null),
      child: Row(children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis, maxLines: 1)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5), overflow: TextOverflow.ellipsis, maxLines: 1),
      ]),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final dynamic task;
  const _TimelineTab({required this.task});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = [
      ('Task created', task.createdAt, true),
      ('Work started', task.createdAt.add(const Duration(days: 1)), task.progress > 0),
      ('Halfway checkpoint', task.createdAt.add(const Duration(days: 3)), task.progress >= 50),
      (task.status.name == 'completed' ? 'Task completed' : 'Due date', task.due, task.status.name == 'completed'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final (label, date, done) = items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(shape: BoxShape.circle, color: done ? const Color(0xFF22C58B) : Colors.transparent, border: Border.all(color: done ? const Color(0xFF22C58B) : p.borderStrong, width: 2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(DateFormat('MMM d, y').format(date), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentsTab extends StatefulWidget {
  final TaskDetailsCubit cubit;
  final List<TaskComment> comments;
  const _CommentsTab({required this.cubit, required this.comments});

  @override
  State<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<_CommentsTab> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.comments.length,
            itemBuilder: (context, i) {
              final c = widget.comments[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 15, child: Text(c.initials, style: const TextStyle(fontSize: 11))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(c.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                            const SizedBox(width: 6),
                            Text(c.time, style: Theme.of(context).textTheme.bodySmall),
                          ]),
                          const SizedBox(height: 2),
                          Text(c.text, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Add a comment…', isDense: true))),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  widget.cubit.addComment(_controller.text);
                  _controller.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final dynamic task;
  const _ActivityTab({required this.task});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Task created',
      'Priority set to ${task.priority.label}',
      'Category assigned: ${task.category.label}',
      if (task.progress > 0) 'Progress updated to ${task.progress}%',
      if (task.favorite) 'Marked as favorite',
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          const Icon(Icons.circle, size: 6),
          const SizedBox(width: 10),
          Expanded(child: Text(items[i], style: Theme.of(context).textTheme.bodyMedium)),
        ]),
      ),
    );
  }
}
