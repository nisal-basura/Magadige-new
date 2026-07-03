import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/datasources/seed_data.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/user_repository.dart';

enum AnalyticsRange { week, month, year }

class AnalyticsState extends Equatable {
  final FormStatus status;
  final List<TaskModel> tasks;
  final int streakCurrent;
  final int streakLongest;
  final AnalyticsRange range;

  const AnalyticsState({
    this.status = FormStatus.initial,
    this.tasks = const [],
    this.streakCurrent = 0,
    this.streakLongest = 0,
    this.range = AnalyticsRange.week,
  });

  int get completed => tasks.where((t) => t.status == TaskStatus.completed).length;
  int get overdue => tasks.where((t) => t.status == TaskStatus.overdue).length;
  int get completionRate => tasks.isEmpty ? 0 : ((completed / tasks.length) * 100).round();
  int get highPriorityOpen => tasks.where((t) => t.priority == TaskPriority.high && t.status != TaskStatus.completed).length;

  double get avgTasksPerDay {
    final total = SeedData.weeklyProgress.fold<int>(0, (sum, d) => sum + d['completed']!);
    return total / 7;
  }

  ({String day, double rate}) get bestDay {
    var best = SeedData.weeklyProgress[0];
    var bestIndex = 0;
    for (var i = 0; i < SeedData.weeklyProgress.length; i++) {
      final d = SeedData.weeklyProgress[i];
      if (d['completed']! / d['total']! > best['completed']! / best['total']!) {
        best = d;
        bestIndex = i;
      }
    }
    return (day: SeedData.weekdayLabels[bestIndex], rate: best['completed']! / best['total']!);
  }

  ({String day, double rate}) get worstDay {
    var worst = SeedData.weeklyProgress[0];
    var worstIndex = 0;
    for (var i = 0; i < SeedData.weeklyProgress.length; i++) {
      final d = SeedData.weeklyProgress[i];
      if (d['completed']! / d['total']! < worst['completed']! / worst['total']!) {
        worst = d;
        worstIndex = i;
      }
    }
    return (day: SeedData.weekdayLabels[worstIndex], rate: worst['completed']! / worst['total']!);
  }

  double get totalFocusHours {
    double total = 0;
    for (final t in tasks) {
      final hMatch = RegExp(r'([\d.]+)h').firstMatch(t.estimate);
      final mMatch = RegExp(r'([\d.]+)m').firstMatch(t.estimate);
      if (hMatch != null) total += double.parse(hMatch.group(1)!);
      if (mMatch != null) total += double.parse(mMatch.group(1)!) / 60;
    }
    return total;
  }

  Map<TaskPriority, int> get priorityBreakdown {
    final map = {for (final p in TaskPriority.values) p: 0};
    for (final t in tasks.where((t) => t.status != TaskStatus.completed)) {
      map[t.priority] = (map[t.priority] ?? 0) + 1;
    }
    return map;
  }

  Map<TaskCategory, int> get categoryBreakdown {
    final map = {for (final c in TaskCategory.values) c: 0};
    for (final t in tasks) {
      map[t.category] = (map[t.category] ?? 0) + 1;
    }
    return map;
  }

  AnalyticsState copyWith({FormStatus? status, List<TaskModel>? tasks, int? streakCurrent, int? streakLongest, AnalyticsRange? range}) {
    return AnalyticsState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      streakCurrent: streakCurrent ?? this.streakCurrent,
      streakLongest: streakLongest ?? this.streakLongest,
      range: range ?? this.range,
    );
  }

  @override
  List<Object?> get props => [status, tasks, streakCurrent, streakLongest, range];
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;

  AnalyticsCubit(this._taskRepository, this._userRepository) : super(const AnalyticsState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final tasks = await _taskRepository.fetchTasks();
    final user = await _userRepository.getCurrentUser();
    emit(state.copyWith(status: FormStatus.success, tasks: tasks, streakCurrent: user.streakCurrent, streakLongest: user.streakLongest));
  }

  void setRange(AnalyticsRange r) => emit(state.copyWith(range: r));
}
