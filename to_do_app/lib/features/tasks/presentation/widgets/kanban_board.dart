import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/priority_dot.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/task_model.dart';

class KanbanBoard extends StatelessWidget {
  final List<TaskModel> tasks;
  final void Function(TaskModel task, TaskStatus newStatus) onMove;
  final ValueChanged<TaskModel> onOpen;

  const KanbanBoard({super.key, required this.tasks, required this.onMove, required this.onOpen});

  static const _columns = [
    (TaskStatus.pending, 'Pending'),
    (TaskStatus.inProgress, 'In Progress'),
    (TaskStatus.completed, 'Completed'),
    (TaskStatus.overdue, 'Overdue'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _columns.map((c) {
          final items = tasks.where((t) => t.status == c.$1).toList();
          return _KanbanColumn(status: c.$1, label: c.$2, tasks: items, onMove: onMove, onOpen: onOpen);
        }).toList(),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final String label;
  final List<TaskModel> tasks;
  final void Function(TaskModel, TaskStatus) onMove;
  final ValueChanged<TaskModel> onOpen;

  const _KanbanColumn({required this.status, required this.label, required this.tasks, required this.onMove, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: p.bgSunken, borderRadius: BorderRadius.circular(16)),
      child: DragTarget<TaskModel>(
        onWillAcceptWithDetails: (details) => details.data.status != status,
        onAcceptWithDetails: (details) => onMove(details.data, status),
        builder: (context, candidateData, rejectedData) {
          final isTarget = candidateData.isNotEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: p.textSecondary, letterSpacing: 0.4)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(999)),
                      child: Text('${tasks.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.textSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: BoxConstraints(minHeight: isTarget ? 80 : 0),
                decoration: isTarget
                    ? BoxDecoration(border: Border.all(color: p.brand, width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10))
                    : null,
                child: Column(
                  children: tasks
                      .map((t) => LongPressDraggable<TaskModel>(
                            data: t,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(width: 220, child: _KanbanCard(task: t, onTap: () {})),
                            ),
                            childWhenDragging: Opacity(opacity: 0.3, child: _KanbanCard(task: t, onTap: () {})),
                            child: _KanbanCard(task: t, onTap: () => onOpen(t)),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  const _KanbanCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: p.borderSubtle)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                children: [
                  PriorityDot(priority: task.priority, size: 6),
                  const SizedBox(width: 5),
                  Text(task.category.label, style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  Text(task.due == null ? '—' : DateFormat('MMM d').format(task.due!), style: TextStyle(fontSize: 10, color: p.textTertiary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
