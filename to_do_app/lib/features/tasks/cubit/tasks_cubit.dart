import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

enum TaskViewMode { list, kanban }

enum TaskSort { due, priority, created }

enum TaskStatusFilter { all, pending, inProgress, completed, overdue }

class TasksState extends Equatable {
  final FormStatus status;
  final List<TaskModel> tasks;
  final String search;
  final TaskStatusFilter statusFilter;
  final bool highPriorityOnly;
  final bool favoriteOnly;
  final TaskSort sort;
  final TaskViewMode view;
  final Set<String> selected;

  const TasksState({
    this.status = FormStatus.initial,
    this.tasks = const [],
    this.search = '',
    this.statusFilter = TaskStatusFilter.all,
    this.highPriorityOnly = false,
    this.favoriteOnly = false,
    this.sort = TaskSort.due,
    this.view = TaskViewMode.list,
    this.selected = const {},
  });

  List<TaskModel> get filtered {
    var list = tasks.where((t) => !t.archived).toList();
    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((t) => t.title.toLowerCase().contains(q) || t.tags.any((tag) => tag.toLowerCase().contains(q))).toList();
    }
    switch (statusFilter) {
      case TaskStatusFilter.all:
        break;
      case TaskStatusFilter.pending:
        list = list.where((t) => t.status == TaskStatus.pending).toList();
      case TaskStatusFilter.inProgress:
        list = list.where((t) => t.status == TaskStatus.inProgress).toList();
      case TaskStatusFilter.completed:
        list = list.where((t) => t.status == TaskStatus.completed).toList();
      case TaskStatusFilter.overdue:
        list = list.where((t) => t.status == TaskStatus.overdue).toList();
    }
    if (highPriorityOnly) list = list.where((t) => t.priority == TaskPriority.high).toList();
    if (favoriteOnly) list = list.where((t) => t.favorite).toList();

    list.sort((a, b) {
      switch (sort) {
        case TaskSort.due:
          return a.due.compareTo(b.due);
        case TaskSort.priority:
          const rank = {TaskPriority.high: 0, TaskPriority.medium: 1, TaskPriority.low: 2};
          return rank[a.priority]!.compareTo(rank[b.priority]!);
        case TaskSort.created:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    return list;
  }

  TasksState copyWith({
    FormStatus? status,
    List<TaskModel>? tasks,
    String? search,
    TaskStatusFilter? statusFilter,
    bool? highPriorityOnly,
    bool? favoriteOnly,
    TaskSort? sort,
    TaskViewMode? view,
    Set<String>? selected,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      highPriorityOnly: highPriorityOnly ?? this.highPriorityOnly,
      favoriteOnly: favoriteOnly ?? this.favoriteOnly,
      sort: sort ?? this.sort,
      view: view ?? this.view,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [status, tasks, search, statusFilter, highPriorityOnly, favoriteOnly, sort, view, selected];
}

class TasksCubit extends Cubit<TasksState> {
  final TaskRepository _repository;

  TasksCubit(this._repository) : super(const TasksState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final tasks = await _repository.fetchTasks();
    emit(state.copyWith(status: FormStatus.success, tasks: tasks));
  }

  void setSearch(String v) => emit(state.copyWith(search: v));
  void setStatusFilter(TaskStatusFilter f) => emit(state.copyWith(statusFilter: f));
  void toggleHighPriority() => emit(state.copyWith(highPriorityOnly: !state.highPriorityOnly));
  void toggleFavoriteOnly() => emit(state.copyWith(favoriteOnly: !state.favoriteOnly));
  void setSort(TaskSort s) => emit(state.copyWith(sort: s));
  void setView(TaskViewMode v) => emit(state.copyWith(view: v));

  void clearFilters() => emit(state.copyWith(
        search: '',
        statusFilter: TaskStatusFilter.all,
        highPriorityOnly: false,
        favoriteOnly: false,
      ));

  void toggleSelect(String id) {
    final next = {...state.selected};
    if (!next.remove(id)) next.add(id);
    emit(state.copyWith(selected: next));
  }

  void clearSelection() => emit(state.copyWith(selected: {}));

  Future<void> toggleFavorite(TaskModel task) async {
    final updated = task.copyWith(favorite: !task.favorite);
    await _repository.updateTask(updated);
    _replace(updated);
  }

  Future<void> updateStatus(TaskModel task, TaskStatus status) async {
    final updated = task.copyWith(status: status, progress: status == TaskStatus.completed ? 100 : task.progress);
    await _repository.updateTask(updated);
    _replace(updated);
  }

  Future<void> duplicateTask(TaskModel task) async {
    final copy = task.copyWith(title: '${task.title} (copy)');
    final withId = TaskModel(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: copy.title,
      description: copy.description,
      category: copy.category,
      priority: copy.priority,
      status: copy.status,
      due: copy.due,
      tags: copy.tags,
      estimate: copy.estimate,
      progress: copy.progress,
      favorite: copy.favorite,
      createdAt: DateTime.now(),
      subtasks: copy.subtasks,
    );
    await _repository.createTask(withId);
    emit(state.copyWith(tasks: [withId, ...state.tasks]));
  }

  Future<void> archiveTask(TaskModel task) async {
    final updated = task.copyWith(archived: true);
    await _repository.updateTask(updated);
    _replace(updated);
  }

  Future<void> deleteTask(TaskModel task) async {
    await _repository.deleteTask(task.id);
    emit(state.copyWith(tasks: state.tasks.where((t) => t.id != task.id).toList()));
  }

  Future<void> saveTask(TaskModel task, {required bool isNew}) async {
    if (isNew) {
      await _repository.createTask(task);
      emit(state.copyWith(tasks: [task, ...state.tasks]));
    } else {
      await _repository.updateTask(task);
      _replace(task);
    }
  }

  Future<void> bulkApply(String action) async {
    final ids = state.selected;
    for (final id in ids) {
      final task = state.tasks.firstWhere((t) => t.id == id, orElse: () => state.tasks.first);
      switch (action) {
        case 'complete':
          await updateStatus(task, TaskStatus.completed);
        case 'archive':
          await archiveTask(task);
        case 'delete':
          await deleteTask(task);
        case 'duplicate':
          await duplicateTask(task);
      }
    }
    emit(state.copyWith(selected: {}));
  }

  void _replace(TaskModel updated) {
    emit(state.copyWith(tasks: state.tasks.map((t) => t.id == updated.id ? updated : t).toList()));
  }
}
