import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/task_model.dart';

class MiniCalendar extends StatelessWidget {
  final List<TaskModel> tasks;
  const MiniCalendar({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday-start grid
    final taskDays = tasks.map((t) => t.due.day).toSet();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM y').format(now), style: Theme.of(context).textTheme.titleMedium),
              Icon(Icons.calendar_month_outlined, size: 16, color: p.brand),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final isToday = day == now.day;
              final hasTask = taskDays.contains(day);
              return Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isToday ? p.brand : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday ? Colors.white : p.textSecondary,
                      ),
                    ),
                    if (hasTask && !isToday)
                      Positioned(
                        bottom: 1,
                        child: Container(width: 3, height: 3, decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle)),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
