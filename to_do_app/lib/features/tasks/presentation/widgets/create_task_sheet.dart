import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../categories/cubit/categories_cubit.dart';

/// Shows the create/edit task form as a modal bottom sheet. `subtaskTitles`
/// is only ever non-empty for a brand-new task (subtasks need a real task id
/// to attach to, so editing an existing task manages them from the Task
/// Details screen instead, where they have real per-item persistence).
Future<void> showTaskFormSheet(
  BuildContext context, {
  TaskModel? existing,
  required void Function(TaskModel task, bool isNew, List<String> subtaskTitles) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TaskFormSheet(existing: existing, onSave: onSave),
  );
}

class _TaskFormSheet extends StatefulWidget {
  final TaskModel? existing;
  final void Function(TaskModel task, bool isNew, List<String> subtaskTitles) onSave;
  const _TaskFormSheet({this.existing, required this.onSave});

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _estimate;
  CategoryModel? _category;
  late TaskPriority _priority;
  DateTime? _due;
  final List<TextEditingController> _subtaskControllers = [];

  bool get isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _estimate = TextEditingController(text: t?.estimateMinutes != null ? formatMinutes(t!.estimateMinutes) : '');
    _category = t?.category;
    _priority = t?.priority ?? TaskPriority.medium;
    _due = t?.due ?? DateTime.now();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _estimate.dispose();
    for (final c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save(CategoryModel fallbackCategory) {
    if (_title.text.trim().isEmpty) return;
    final category = _category ?? fallbackCategory;
    final task = TaskModel(
      id: widget.existing?.id ?? '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: category,
      priority: _priority,
      status: widget.existing?.status ?? TaskStatus.pending,
      due: _due,
      tags: widget.existing?.tags ?? const [],
      estimateMinutes: parseMinutesFromLabel(_estimate.text),
      favorite: widget.existing?.favorite ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      dreamId: widget.existing?.dreamId,
    );
    final subtaskTitles = _subtaskControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    widget.onSave(task, isNew, isNew ? subtaskTitles : const []);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final categories = context.watch<CategoriesCubit>().state.categories;
    final fallbackCategory = categories.isNotEmpty ? categories.first : CategoryModel.unknown;
    final selectedCategory = _category ?? (categories.contains(widget.existing?.category) ? widget.existing?.category : null) ?? fallbackCategory;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(color: p.bgSurface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: p.borderStrong, borderRadius: BorderRadius.circular(999))),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isNew ? 'Create Task' : 'Edit Task', style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Design onboarding flow')),
                const SizedBox(height: 14),
                TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', hintText: 'Add more detail…')),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        initialValue: _priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<CategoryModel>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: categories.isEmpty
                            ? [DropdownMenuItem(value: fallbackCategory, child: Text(fallbackCategory.label))]
                            : categories.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                        onChanged: (v) => setState(() => _category = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: _due ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                          if (picked != null) setState(() => _due = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Deadline'),
                          child: Text(_due == null ? 'Not set' : '${_due!.year}-${_due!.month.toString().padLeft(2, '0')}-${_due!.day.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _estimate, decoration: const InputDecoration(labelText: 'Estimated time', hintText: 'e.g. 1h 30m'))),
                  ],
                ),
                if (isNew) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtasks', style: Theme.of(context).textTheme.labelLarge),
                      TextButton.icon(
                        onPressed: () => setState(() => _subtaskControllers.add(TextEditingController())),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  ..._subtaskControllers.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: TextField(controller: e.value, decoration: const InputDecoration(hintText: 'Subtask title', isDense: true))),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => setState(() => _subtaskControllers.removeAt(e.key)),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 12),
                GradientButton(label: 'Save Task', onPressed: () => _save(fallbackCategory)),
              ],
            ),
          );
        },
      ),
    );
  }
}
