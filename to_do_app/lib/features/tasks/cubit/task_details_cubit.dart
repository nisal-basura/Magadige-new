import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

class TaskComment extends Equatable {
  final String author;
  final String initials;
  final String time;
  final String text;
  const TaskComment({required this.author, required this.initials, required this.time, required this.text});

  @override
  List<Object?> get props => [author, initials, time, text];
}

class TaskDetailsState extends Equatable {
  final TaskModel? task;
  final List<TaskComment> comments;
  final bool loading;

  const TaskDetailsState({this.task, this.comments = const [], this.loading = true});

  TaskDetailsState copyWith({TaskModel? task, List<TaskComment>? comments, bool? loading}) {
    return TaskDetailsState(task: task ?? this.task, comments: comments ?? this.comments, loading: loading ?? this.loading);
  }

  @override
  List<Object?> get props => [task, comments, loading];
}

class TaskDetailsCubit extends Cubit<TaskDetailsState> {
  final TaskRepository _repository;
  final String taskId;

  TaskDetailsCubit(this._repository, this.taskId) : super(const TaskDetailsState()) {
    _load();
  }

  Future<void> _load() async {
    final all = await _repository.fetchTasks();
    final task = all.where((t) => t.id == taskId).cast<TaskModel?>().firstWhere((t) => t != null, orElse: () => null);
    emit(state.copyWith(
      task: task,
      loading: false,
      comments: const [
        TaskComment(author: 'Amaka Nwosu', initials: 'AN', time: '2 days ago', text: "Let's make sure this aligns with the roadmap before we finalize."),
        TaskComment(author: 'Tunde Bakare', initials: 'TB', time: '1 day ago', text: 'Looks solid — left a couple of notes on the draft doc.'),
      ],
    ));
  }

  Future<void> toggleSubtask(int index) async {
    final task = state.task;
    if (task == null) return;
    final total = task.subtasks.length;
    if (total == 0) return;
    final doneCount = ((task.progress / 100) * total).round();
    final currentlyDone = index < doneCount;
    final newDoneCount = currentlyDone ? doneCount - 1 : doneCount + 1;
    final progress = ((newDoneCount / total) * 100).round();
    final status = progress == 100 ? TaskStatus.completed : (progress > 0 ? TaskStatus.inProgress : TaskStatus.pending);
    final updated = task.copyWith(progress: progress, status: status);
    await _repository.updateTask(updated);
    emit(state.copyWith(task: updated));
  }

  Future<void> toggleFavorite() async {
    final task = state.task;
    if (task == null) return;
    final updated = task.copyWith(favorite: !task.favorite);
    await _repository.updateTask(updated);
    emit(state.copyWith(task: updated));
  }

  Future<void> delete() async {
    final task = state.task;
    if (task == null) return;
    await _repository.deleteTask(task.id);
  }

  void addComment(String text) {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(comments: [
      ...state.comments,
      TaskComment(author: 'You', initials: 'ME', time: 'Just now', text: text.trim()),
    ]));
  }

  /// How many of the subtasks are "done" given the task's overall progress —
  /// mirrors the same derived-checklist trick used on web (progress drives
  /// how many items read as complete).
  bool isSubtaskDone(int index) {
    final task = state.task;
    if (task == null || task.subtasks.isEmpty) return false;
    final doneCount = ((task.progress / 100) * task.subtasks.length).round();
    return index < doneCount;
  }
}
