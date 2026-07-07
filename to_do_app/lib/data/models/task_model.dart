import 'package:equatable/equatable.dart';

import '../../core/utils/duration_format.dart';
import 'category_model.dart';
import 'subtask_model.dart';
import 'tag_model.dart';

/// The mini dream reference embedded on a task (`{id, title, emoji, color}`)
/// — not a full DreamResource, that's all the backend sends inline.
class TaskDreamRef extends Equatable {
  final String id;
  final String title;
  final String emoji;
  final String? colorRaw;

  const TaskDreamRef({required this.id, required this.title, required this.emoji, this.colorRaw});

  factory TaskDreamRef.fromJson(Map<String, dynamic> json) => TaskDreamRef(
        id: json['id'].toString(),
        title: json['title'] as String,
        emoji: json['emoji'] as String? ?? '',
        colorRaw: json['color'] as String?,
      );

  @override
  List<Object?> get props => [id, title, emoji, colorRaw];
}

class TaskModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final CategoryModel category;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? due;
  final List<TagModel> tags;
  final int? estimateMinutes;
  final bool favorite;
  final String? colorTag;
  final ReminderOption reminder;
  final RepeatRule repeatRule;
  final DateTime? completedAt;
  final DateTime createdAt;
  final String? dreamId;
  final TaskDreamRef? dream;
  final int? subtasksCount;
  final List<SubtaskModel>? subtasks;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.priority,
    required this.status,
    this.due,
    this.tags = const [],
    this.estimateMinutes,
    this.favorite = false,
    this.colorTag,
    this.reminder = ReminderOption.none,
    this.repeatRule = RepeatRule.none,
    this.completedAt,
    required this.createdAt,
    this.subtasksCount,
    this.subtasks,
    this.dreamId,
    this.dream,
  });

  /// `Task.progress` is a dead column on the backend (nothing ever
  /// recalculates it), so it's derived here instead: 100 once completed,
  /// otherwise from real subtask completion when subtasks are loaded
  /// (only true on the task-detail "show" response), else 0.
  int get progress {
    if (status == TaskStatus.completed) return 100;
    final items = subtasks;
    if (items == null || items.isEmpty) return 0;
    final done = items.where((s) => s.isDone).length;
    return ((done / items.length) * 100).round();
  }

  String get estimate => formatMinutes(estimateMinutes);

  bool isDueOn(DateTime date) {
    final d = due;
    return d != null && d.year == date.year && d.month == date.month && d.day == date.day;
  }

  TaskModel copyWith({
    String? title,
    String? description,
    CategoryModel? category,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? due,
    List<TagModel>? tags,
    int? estimateMinutes,
    bool? favorite,
    String? colorTag,
    ReminderOption? reminder,
    RepeatRule? repeatRule,
    DateTime? completedAt,
    int? subtasksCount,
    List<SubtaskModel>? subtasks,
    String? dreamId,
    TaskDreamRef? dream,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      due: due ?? this.due,
      tags: tags ?? this.tags,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      favorite: favorite ?? this.favorite,
      colorTag: colorTag ?? this.colorTag,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      subtasksCount: subtasksCount ?? this.subtasksCount,
      subtasks: subtasks ?? this.subtasks,
      dreamId: dreamId ?? this.dreamId,
      dream: dream ?? this.dream,
    );
  }

  /// Merges a response that omitted `tags`/`subtasks`/`subtasksCount` (every
  /// task write endpoint except `show`) into what we already knew locally,
  /// so the UI doesn't flash those lists empty after an edit.
  TaskModel mergeInto(TaskModel previous) => TaskModel(
        id: id,
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: status,
        due: due,
        tags: tags.isNotEmpty ? tags : previous.tags,
        estimateMinutes: estimateMinutes,
        favorite: favorite,
        colorTag: colorTag,
        reminder: reminder,
        repeatRule: repeatRule,
        completedAt: completedAt,
        createdAt: createdAt,
        subtasksCount: subtasksCount ?? previous.subtasksCount,
        subtasks: subtasks ?? previous.subtasks,
        dreamId: dreamId,
        dream: dream,
      );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>?;
    final dreamJson = json['dream'] as Map<String, dynamic>?;
    final tagsJson = json['tags'] as List?;
    final subtasksJson = json['subtasks'] as List?;
    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: categoryJson != null ? CategoryModel.fromJson(categoryJson) : CategoryModel.unknown,
      priority: TaskPriority.fromApi(json['priority'] as String?),
      status: TaskStatus.fromApi(json['status'] as String?),
      due: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      tags: tagsJson?.map((t) => TagModel.fromJson(t as Map<String, dynamic>)).toList() ?? const [],
      estimateMinutes: json['estimate_minutes'] as int?,
      favorite: json['is_favorite'] as bool? ?? false,
      colorTag: json['color_tag'] as String?,
      reminder: ReminderOption.fromApi(json['reminder'] as String?),
      repeatRule: RepeatRule.fromApi(json['repeat_rule'] as String?),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      subtasksCount: json['subtasks_count'] as int?,
      subtasks: subtasksJson?.map((s) => SubtaskModel.fromJson(s as Map<String, dynamic>)).toList(),
      dreamId: dreamJson?['id']?.toString() ?? json['dream_id']?.toString(),
      dream: dreamJson != null ? TaskDreamRef.fromJson(dreamJson) : null,
    );
  }

  /// Payload for `POST /tasks` / `PUT /tasks/{id}`.
  Map<String, dynamic> toRequestJson() => {
        'title': title,
        'description': description.isEmpty ? null : description,
        'category_id': category.id,
        'dream_id': dreamId == null ? null : int.tryParse(dreamId!),
        'priority': priority.apiValue,
        'status': status.apiValue,
        'due_date': due?.toIso8601String().split('T').first,
        'estimate_minutes': estimateMinutes,
        'is_favorite': favorite,
        'color_tag': colorTag,
        'reminder': reminder.apiValue,
        'repeat_rule': repeatRule.apiValue,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        priority,
        status,
        due,
        tags,
        estimateMinutes,
        favorite,
        colorTag,
        reminder,
        repeatRule,
        completedAt,
        createdAt,
        subtasksCount,
        subtasks,
        dreamId,
        dream,
      ];
}
