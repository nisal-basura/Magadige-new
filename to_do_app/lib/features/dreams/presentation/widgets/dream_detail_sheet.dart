import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/priority_dot.dart';
import '../../../../data/models/dream_model.dart';
import '../../../../data/models/task_model.dart';

Future<void> showDreamDetailSheet(
  BuildContext context, {
  required DreamModel dream,
  required List<TaskModel> relatedTasks,
  required VoidCallback onDelete,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final p = context.palette;
      final daysLeft = dream.daysLeft;
      return Container(
        decoration: BoxDecoration(color: p.bgSurface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: p.borderStrong, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: p.bgSunken, borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Text(dream.emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dream.title, style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        dream.target == null
                            ? 'No target date set'
                            : 'Target: ${DateFormat('MMM d, y').format(dream.target!)} · ${(daysLeft ?? 0) > 0 ? "$daysLeft days left" : "passed"}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),
            Text('"${dream.motivation}"', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 18),
            Text('PROGRESS', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: AppProgressBar(progress: dream.progress, gradient: [dream.color, p.secondary])),
              const SizedBox(width: 10),
              Text('${dream.progress}%', style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 18),
            Text('RELATED TASKS', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            if (relatedTasks.isEmpty)
              Text('No tasks linked yet.', style: Theme.of(context).textTheme.bodyMedium)
            else
              ...relatedTasks.map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      PriorityDot(priority: t.priority),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      Text(t.status.label, style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  )),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.coral600, side: const BorderSide(color: AppColors.coral600)),
                    onPressed: () {
                      onDelete();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
