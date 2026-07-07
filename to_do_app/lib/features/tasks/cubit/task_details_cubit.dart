import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/subtask_model.dart';
import '../../../data/models/tag_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/subtask_repository.dart';
import '../../../data/repositories/tag_repository.dart';
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

/// Loads via the task-show endpoint specifically (not the list), since only
/// `show` returns the full `subtasks`/`tags` needed for this screen.
class TaskDetailsCubit extends Cubit<TaskDetailsState> {
  final TaskRepository _taskRepository;
  final SubtaskRepository _subtaskRepository;
  final TagRepository _tagRepository;
  final String taskId;

  TaskDetailsCubit(this._taskRepository, this._subtaskRepository, this._tagRepository, this.taskId)
      : super(const TaskDetailsState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final task = await _taskRepository.fetchTask(taskId);
      emit(state.copyWith(
        task: task,
        loading: false,
        comments: const [
          TaskComment(author: 'Amaka Nwosu', initials: 'AN', time: '2 days ago', text: "Let's make sure this aligns with the roadmap before we finalize."),
          TaskComment(author: 'Tunde Bakare', initials: 'TB', time: '1 day ago', text: 'Looks solid — left a couple of notes on the draft doc.'),
        ],
      ));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> toggleFavorite() async {
    final task = state.task;
    if (task == null) return;
    final updated = await _taskRepository.toggleFavorite(task.id);
    emit(state.copyWith(task: updated.mergeInto(task)));
  }

  Future<void> delete() async {
    final task = state.task;
    if (task == null) return;
    await _taskRepository.deleteTask(task.id);
  }

  Future<void> addSubtask(String title) async {
    final task = state.task;
    if (task == null || title.trim().isEmpty) return;
    final subtask = await _subtaskRepository.addSubtask(task.id, title.trim());
    emit(state.copyWith(
      task: task.copyWith(subtasks: [...?task.subtasks, subtask], subtasksCount: (task.subtasksCount ?? 0) + 1),
    ));
  }

  Future<void> toggleSubtask(SubtaskModel subtask) async {
    final task = state.task;
    if (task == null) return;
    final updated = await _subtaskRepository.updateSubtask(subtask.id, isDone: !subtask.isDone);
    final subtasks = task.subtasks?.map((s) => s.id == updated.id ? updated : s).toList();
    emit(state.copyWith(task: task.copyWith(subtasks: subtasks)));
  }

  Future<void> deleteSubtask(SubtaskModel subtask) async {
    final task = state.task;
    if (task == null) return;
    await _subtaskRepository.deleteSubtask(subtask.id);
    final subtasks = task.subtasks?.where((s) => s.id != subtask.id).toList();
    final count = task.subtasksCount;
    emit(state.copyWith(task: task.copyWith(subtasks: subtasks, subtasksCount: count == null ? null : count - 1)));
  }

  Future<List<TagModel>> fetchAllTags() => _tagRepository.fetchTags();

  Future<TagModel> createTag(String label) => _tagRepository.createTag(label);

  /// Unlike the other write endpoints, tag-sync's response only reloads
  /// `tags` (no `category`/`dream`) — so this applies just the tags onto the
  /// already-known task rather than going through the generic [TaskModel.mergeInto],
  /// which would otherwise read the response's missing category/dream as
  /// "cleared" and wipe them from state.
  Future<void> setTags(List<String> tagIds) async {
    final task = state.task;
    if (task == null) return;
    final updated = await _tagRepository.syncTaskTags(task.id, tagIds);
    emit(state.copyWith(task: task.copyWith(tags: updated.tags)));
  }

  void addComment(String text) {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(comments: [
      ...state.comments,
      TaskComment(author: 'You', initials: 'ME', time: 'Just now', text: text.trim()),
    ]));
  }
}
