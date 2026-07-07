import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/activity_synthesizer.dart';
import '../../../core/utils/form_status.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/dream_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/dream_repository.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../categories/cubit/categories_cubit.dart';

class DashboardState extends Equatable {
  final FormStatus status;
  final List<TaskModel> tasks;
  final List<DreamModel> dreams;
  final UserModel? user;
  final List<UserBadgeModel> badges;
  final List<ActivityModel> activity;
  final QuoteModel? quote;

  const DashboardState({
    this.status = FormStatus.initial,
    this.tasks = const [],
    this.dreams = const [],
    this.user,
    this.badges = const [],
    this.activity = const [],
    this.quote,
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
    final today = DateTime(now.year, now.month, now.day);
    final list = tasks.where((t) => t.status != TaskStatus.completed && t.due != null && t.due!.isAfter(today)).toList()
      ..sort((a, b) => a.due!.compareTo(b.due!));
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
    List<UserBadgeModel>? badges,
    List<ActivityModel>? activity,
    QuoteModel? quote,
  }) {
    return DashboardState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      dreams: dreams ?? this.dreams,
      user: user ?? this.user,
      badges: badges ?? this.badges,
      activity: activity ?? this.activity,
      quote: quote ?? this.quote,
    );
  }

  @override
  List<Object?> get props => [status, tasks, dreams, user, badges, activity, quote];
}

class DashboardCubit extends Cubit<DashboardState> {
  final TaskRepository _taskRepository;
  final DreamRepository _dreamRepository;
  final UserRepository _userRepository;
  final QuoteRepository _quoteRepository;
  final CategoriesCubit _categoriesCubit;

  DashboardCubit(
    this._taskRepository,
    this._dreamRepository,
    this._userRepository,
    this._quoteRepository,
    this._categoriesCubit,
  ) : super(const DashboardState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      final results = await Future.wait([
        _taskRepository.fetchTasks(),
        _dreamRepository.fetchDreams(),
        _userRepository.getCurrentUser(),
        _userRepository.getBadges(),
      ]);
      final tasks = results[0] as List<TaskModel>;
      final badges = results[3] as List<UserBadgeModel>;
      QuoteModel? quote;
      try {
        quote = await _quoteRepository.getRandom();
      } catch (_) {
        quote = null;
      }
      emit(state.copyWith(
        status: FormStatus.success,
        tasks: tasks,
        dreams: results[1] as List<DreamModel>,
        user: results[2] as UserModel,
        badges: badges,
        activity: synthesizeActivity(tasks: tasks, badges: badges),
        quote: quote,
      ));
    } catch (_) {
      // A 401 here means the session was just invalidated (expired/revoked)
      // — ApiClient has already cleared it and flipped SessionCubit, which
      // will redirect to /login. Any other failure just surfaces as an
      // empty-state dashboard rather than crashing.
      emit(state.copyWith(status: FormStatus.failure));
    }
  }

  Future<void> toggleComplete(TaskModel task) async {
    final newStatus = task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed;
    final updated = await _taskRepository.setStatus(task.id, newStatus);
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
      due: DateTime.now(),
      createdAt: DateTime.now(),
    );
    final created = await _taskRepository.createTask(task);
    emit(state.copyWith(tasks: [created, ...state.tasks]));
  }
}
