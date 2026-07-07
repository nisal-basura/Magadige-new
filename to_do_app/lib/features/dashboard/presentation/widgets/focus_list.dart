import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/priority_dot.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/task_model.dart';

class FocusList extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<TaskModel> onToggle;
  final ValueChanged<String> onQuickAdd;
  final ValueChanged<TaskModel> onOpen;

  const FocusList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onQuickAdd,
    required this.onOpen,
  });

  @override
  State<FocusList> createState() => _FocusListState();
}

class _FocusListState extends State<FocusList> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Focus", style: Theme.of(context).textTheme.titleLarge),
          Text('Tasks due today', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Quick add a task for today…', isDense: true),
                  onSubmitted: (v) {
                    widget.onQuickAdd(v);
                    _controller.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: p.brand,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    widget.onQuickAdd(_controller.text);
                    _controller.clear();
                  },
                  child: const Padding(padding: EdgeInsets.all(13), child: Icon(Icons.add_rounded, color: Colors.white, size: 20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.tasks.isEmpty)
            const EmptyStateView(
              icon: Icons.task_alt_rounded,
              title: 'Nothing due today',
              message: 'Enjoy the clear runway, or line something up for tomorrow.',
            )
          else
            ...widget.tasks.map((t) => _FocusRow(task: t, onToggle: widget.onToggle, onOpen: widget.onOpen)),
        ],
      ),
    );
  }
}

class _FocusRow extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<TaskModel> onToggle;
  final ValueChanged<TaskModel> onOpen;
  const _FocusRow({required this.task, required this.onToggle, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = task.status == TaskStatus.completed;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onOpen(task),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => onToggle(task),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.mint500 : Colors.transparent,
                  border: Border.all(color: done ? AppColors.mint500 : p.borderStrong, width: 2),
                ),
                child: done ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? p.textTertiary : p.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      PriorityDot(priority: task.priority, size: 6),
                      const SizedBox(width: 5),
                      Text('${task.category.label} · ${task.estimate}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
