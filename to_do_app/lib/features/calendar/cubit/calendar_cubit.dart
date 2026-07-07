import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../categories/cubit/categories_cubit.dart';

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
  final CategoriesCubit _categoriesCubit;

  CalendarCubit(this._repository, this._categoriesCubit) : super(CalendarState()) {
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
    final newStatus = task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed;
    final updated = await _repository.setStatus(task.id, newStatus);
    final merged = updated.mergeInto(task);
    emit(state.copyWith(tasks: state.tasks.map((t) => t.id == task.id ? merged : t).toList()));
  }

  Future<void> quickAddTask(String title) async {
    if (title.trim().isEmpty) return;
    final categories = _categoriesCubit.state.categories;
    final category = state.tasks.isNotEmpty
        ? state.tasks.first.category
        : (categories.isNotEmpty ? categories.first : CategoryModel.unknown);
    final task = TaskModel(
      id: '',
      title: title.trim(),
      category: category,
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      due: state.selectedDate,
      createdAt: DateTime.now(),
    );
    final created = await _repository.createTask(task);
    emit(state.copyWith(tasks: [created, ...state.tasks]));
  }
}
