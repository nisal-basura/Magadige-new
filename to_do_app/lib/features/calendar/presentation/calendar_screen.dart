import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/priority_dot.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../categories/cubit/categories_cubit.dart';
import '../cubit/calendar_cubit.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarCubit(context.read<TaskRepository>(), context.read<CategoriesCubit>()),
      child: const _CalendarView(),
    );
  }
}

const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final cubit = context.read<CalendarCubit>();
        final month = state.visibleMonth;
        final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
        final taskDays = state.tasks.where((t) => t.due != null).map((t) => DateTime(t.due!.year, t.due!.month, t.due!.day)).toSet();
        final selectedTasks = state.tasksOn(state.selectedDate);
        final now = DateTime.now();

        return AppScaffold(
          title: 'Calendar',
          subtitle: 'Every task, mapped to a day.',
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => cubit.shiftMonth(-1)),
                    Text(DateFormat('MMMM y').format(month), style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => cubit.shiftMonth(1)),
                  ]),
                  TextButton(onPressed: cubit.goToToday, child: const Text('Today')),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                child: Column(
                  children: [
                    Row(children: _weekdayLabels.map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: p.textTertiary))))).toList()),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: firstWeekday + daysInMonth,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 0.85),
                      itemBuilder: (context, index) {
                        if (index < firstWeekday) return const SizedBox.shrink();
                        final day = index - firstWeekday + 1;
                        final date = DateTime(month.year, month.month, day);
                        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                        final isSelected = date.year == state.selectedDate.year && date.month == state.selectedDate.month && date.day == state.selectedDate.day;
                        final hasTask = taskDays.contains(date);
                        return GestureDetector(
                          onTap: () => cubit.selectDate(date),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isToday ? p.brand : (isSelected ? p.brandSoft : Colors.transparent),
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected && !isToday ? Border.all(color: p.brand) : null,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$day', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isToday ? Colors.white : p.textPrimary)),
                                if (hasTask)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(color: isToday ? Colors.white : p.accent, shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE, MMMM d').format(state.selectedDate), style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (selectedTasks.isEmpty)
                      const EmptyStateView(icon: Icons.event_available_outlined, title: 'Nothing scheduled', message: 'No tasks due on this day.')
                    else
                      ...selectedTasks.map((t) {
                        final done = t.status == TaskStatus.completed;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => cubit.toggleComplete(t),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: done ? AppColors.mint500 : Colors.transparent,
                                    border: Border.all(color: done ? AppColors.mint500 : p.borderStrong, width: 2),
                                  ),
                                  child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.push('/tasks/${t.id}'),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, decoration: done ? TextDecoration.lineThrough : null, color: done ? p.textTertiary : p.textPrimary)),
                                      Row(children: [PriorityDot(priority: t.priority, size: 6), const SizedBox(width: 5), Text(t.category.label, style: Theme.of(context).textTheme.bodySmall)]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                    _QuickAddRow(onAdd: cubit.quickAddTask),
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

class _QuickAddRow extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _QuickAddRow({required this.onAdd});

  @override
  State<_QuickAddRow> createState() => _QuickAddRowState();
}

class _QuickAddRowState extends State<_QuickAddRow> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Add a task for this day…', isDense: true))),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            widget.onAdd(_controller.text);
            _controller.clear();
          },
        ),
      ],
    );
  }
}
