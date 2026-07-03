import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

class CalendarState extends Equatable {
  final FormStatus status;
  final List<TaskModel> tasks;
  final DateTime visibleMonth;
  final DateTime selectedDate;

  CalendarState({
    this.status = FormStatus.initial,
    this.tasks = const [],
    DateTime? visibleMonth,
    DateTime? selectedDate,
  })  : visibleMonth = visibleMonth ?? DateTime(DateTime.now().year, DateTime.now().month),
        selectedDate = selectedDate ?? DateTime.now();

  List<TaskModel> tasksOn(DateTime date) => tasks.where((t) => t.isDueOn(date)).toList()
    ..sort((a, b) => (a.status == TaskStatus.completed ? 1 : 0).compareTo(b.status == TaskStatus.completed ? 1 : 0));

  CalendarState copyWith({FormStatus? status, List<TaskModel>? tasks, DateTime? visibleMonth, DateTime? selectedDate}) {
    return CalendarState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      visibleMonth: visibleMonth ?? this.visibleMonth,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [status, tasks, visibleMonth, selectedDate];
}

class CalendarCubit extends Cubit<CalendarState> {
  final TaskRepository _repository;

  CalendarCubit(this._repository) : super(CalendarState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final tasks = await _repository.fetchTasks();
    emit(state.copyWith(status: FormStatus.success, tasks: tasks));
  }

  void selectDate(DateTime date) => emit(state.copyWith(selectedDate: date));

  void shiftMonth(int delta) {
    final m = DateTime(state.visibleMonth.year, state.visibleMonth.month + delta);
    emit(state.copyWith(visibleMonth: m));
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(visibleMonth: DateTime(now.year, now.month), selectedDate: now));
  }

  Future<void> toggleComplete(TaskModel task) async {
    final updated = task.copyWith(
      status: task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed,
      progress: task.status == TaskStatus.completed ? 40 : 100,
    );
    await _repository.updateTask(updated);
    emit(state.copyWith(tasks: state.tasks.map((t) => t.id == task.id ? updated : t).toList()));
  }

  Future<void> quickAddTask(String title) async {
    if (title.trim().isEmpty) return;
    final task = TaskModel(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      category: TaskCategory.work,
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      due: state.selectedDate,
      createdAt: DateTime.now(),
    );
    await _repository.createTask(task);
    emit(state.copyWith(tasks: [task, ...state.tasks]));
  }
}
