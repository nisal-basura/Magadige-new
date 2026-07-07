import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/priority_dot.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final bool selected;
  final ValueChanged<bool?>? onSelectChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onDuplicate,
    required this.onDelete,
    this.selected = false,
    this.onSelectChanged,
  });

  (Color, Color) _statusColors(AppPalette p) => switch (task.status) {
        TaskStatus.pending => (p.secondary, p.secondarySoft),
        TaskStatus.inProgress => (p.brand, p.brandSoft),
        TaskStatus.completed => (AppColors.mint600, AppColors.mintSoft),
        TaskStatus.overdue => (AppColors.coral600, AppColors.coralSoft),
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (statusColor, statusSoft) = _statusColors(p);
    final overdue = task.status == TaskStatus.overdue;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? p.brand : p.borderSubtle, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onSelectChanged == null ? null : () => onSelectChanged!(!selected),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (onSelectChanged != null) ...[
                    Checkbox(value: selected, onChanged: onSelectChanged, visualDensity: VisualDensity.compact),
                    const SizedBox(width: 2),
                  ],
                  PriorityDot(priority: task.priority),
                  const Spacer(),
                  IconButton(
                    icon: Icon(task.favorite ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: task.favorite ? p.accent : p.textTertiary),
                    onPressed: onToggleFavorite,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded, size: 20, color: p.textTertiary),
                    padding: EdgeInsets.zero,
                    onSelected: (v) {
                      switch (v) {
                        case 'duplicate':
                          onDuplicate();
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                AppBadge(label: task.category.label, color: task.category.color, background: task.category.softColor),
                AppBadge(label: task.status.label, color: statusColor, background: statusSoft),
              ]),
              if (task.progress > 0) ...[
                const SizedBox(height: 10),
                AppProgressBar(progress: task.progress, height: 6),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: overdue ? AppColors.coral600 : p.textTertiary),
                    const SizedBox(width: 4),
                    Text(task.due == null ? 'No due date' : DateFormat('MMM d').format(task.due!),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: overdue ? AppColors.coral600 : p.textTertiary)),
                  ]),
                  Text(task.estimate, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
