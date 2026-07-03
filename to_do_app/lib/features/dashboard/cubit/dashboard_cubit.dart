import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/dream_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/dream_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/user_repository.dart';

class DashboardState extends Equatable {
  final FormStatus status;
  final List<TaskModel> tasks;
  final List<DreamModel> dreams;
  final UserModel? user;
  final List<BadgeModel> badges;
  final List<ActivityModel> activity;

  const DashboardState({
    this.status = FormStatus.initial,
    this.tasks = const [],
    this.dreams = const [],
    this.user,
    this.badges = const [],
    this.activity = const [],
  });

  int get completed => tasks.where((t) => t.status == TaskStatus.completed).length;
  int get pending => tasks.where((t) => t.status == TaskStatus.pending || t.status == TaskStatus.inProgress).length;
  int get overdue => tasks.where((t) => t.status == TaskStatus.overdue).length;
  int get highPriority => tasks.where((t) => t.priority == TaskPriority.high && t.status != TaskStatus.completed).length;
  int get completionRate => tasks.isEmpty ? 0 : ((completed / tasks.length) * 100).round();

  List<TaskModel> get todayFocus {
    final now = DateTime.now();
    return tasks.where((t) => t.isDueOn(now)).toList()
      ..sort((a, b) => (a.status == TaskStatus.completed ? 1 : 0).compareTo(b.status == TaskStatus.completed ? 1 : 0));
  }

  List<TaskModel> get upcoming {
    final now = DateTime.now();
    final list = tasks.where((t) => t.status != TaskStatus.completed && t.due.isAfter(DateTime(now.year, now.month, now.day))).toList()
      ..sort((a, b) => a.due.compareTo(b.due));
    return list.take(5).toList();
  }

  DreamModel? get topDream {
    if (dreams.isEmpty) return null;
    final sorted = [...dreams]..sort((a, b) => b.progress.compareTo(a.progress));
    return sorted.first;
  }

  DashboardState copyWith({
    FormStatus? status,
    List<TaskModel>? tasks,
    List<DreamModel>? dreams,
    UserModel? user,
    List<BadgeModel>? badges,
    List<ActivityModel>? activity,
  }) {
    return DashboardState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      dreams: dreams ?? this.dreams,
      user: user ?? this.user,
      badges: badges ?? this.badges,
      activity: activity ?? this.activity,
    );
  }

  @override
  List<Object?> get props => [status, tasks, dreams, user, badges, activity];
}

class DashboardCubit extends Cubit<DashboardState> {
  final TaskRepository _taskRepository;
  final DreamRepository _dreamRepository;
  final UserRepository _userRepository;

  DashboardCubit(this._taskRepository, this._dreamRepository, this._userRepository) : super(const DashboardState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final results = await Future.wait([
      _taskRepository.fetchTasks(),
      _dreamRepository.fetchDreams(),
      _userRepository.getCurrentUser(),
      _userRepository.getBadges(),
      _userRepository.getActivity(),
    ]);
    emit(state.copyWith(
      status: FormStatus.success,
      tasks: results[0] as List<TaskModel>,
      dreams: results[1] as List<DreamModel>,
      user: results[2] as UserModel,
      badges: results[3] as List<BadgeModel>,
      activity: results[4] as List<ActivityModel>,
    ));
  }

  Future<void> toggleComplete(TaskModel task) async {
    final updated = task.copyWith(
      status: task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed,
      progress: task.status == TaskStatus.completed ? 40 : 100,
    );
    await _taskRepository.updateTask(updated);
    emit(state.copyWith(tasks: state.tasks.map((t) => t.id == task.id ? updated : t).toList()));
  }

  Future<void> quickAddTask(String title) async {
    if (title.trim().isEmpty) return;
    final task = TaskModel(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      category: state.tasks.isNotEmpty ? state.tasks.first.category : TaskCategory.work,
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      due: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _taskRepository.createTask(task);
    emit(state.copyWith(tasks: [task, ...state.tasks]));
  }
}
