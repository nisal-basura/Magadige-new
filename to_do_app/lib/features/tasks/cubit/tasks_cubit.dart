import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/subtask_repository.dart';
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
    var list = tasks.toList();
    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((t) => t.title.toLowerCase().contains(q) || t.tags.any((tag) => tag.label.toLowerCase().contains(q))).toList();
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
          if (a.due == null && b.due == null) return 0;
          if (a.due == null) return 1;
          if (b.due == null) return -1;
          return a.due!.compareTo(b.due!);
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
  final SubtaskRepository _subtaskRepository;

  TasksCubit(this._repository, this._subtaskRepository) : super(const TasksState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      final tasks = await _repository.fetchTasks();
      emit(state.copyWith(status: FormStatus.success, tasks: tasks));
    } catch (_) {
      emit(state.copyWith(status: FormStatus.failure));
    }
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
    final updated = await _repository.toggleFavorite(task.id);
    _replace(updated.mergeInto(task));
  }

  Future<void> updateStatus(TaskModel task, TaskStatus status) async {
    final updated = await _repository.setStatus(task.id, status);
    _replace(updated.mergeInto(task));
  }

  Future<void> duplicateTask(TaskModel task) async {
    final copy = task.copyWith(title: '${task.title} (copy)', favorite: false);
    final created = await _repository.createTask(copy);
    emit(state.copyWith(tasks: [created, ...state.tasks]));
  }

  Future<void> deleteTask(TaskModel task) async {
    await _repository.deleteTask(task.id);
    emit(state.copyWith(tasks: state.tasks.where((t) => t.id != task.id).toList()));
  }

  Future<void> saveTask(TaskModel task, {required bool isNew, List<String> subtaskTitles = const []}) async {
    if (isNew) {
      var created = await _repository.createTask(task);
      final titles = subtaskTitles.map((t) => t.trim()).where((t) => t.isNotEmpty);
      for (final title in titles) {
        await _subtaskRepository.addSubtask(created.id, title);
      }
      if (titles.isNotEmpty) created = await _repository.fetchTask(created.id);
      emit(state.copyWith(tasks: [created, ...state.tasks]));
    } else {
      final updated = await _repository.updateTask(task);
      _replace(updated);
    }
  }

  Future<void> bulkApply(String action) async {
    final ids = state.selected;
    for (final id in ids) {
      final task = state.tasks.firstWhere((t) => t.id == id, orElse: () => state.tasks.first);
      switch (action) {
        case 'complete':
          await updateStatus(task, TaskStatus.completed);
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
