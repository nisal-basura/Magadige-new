import 'package:equatable/equatable.dart';

import 'category_model.dart';

class TaskModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime due;
  final List<String> tags;
  final String estimate;
  final int progress; // 0-100
  final bool favorite;
  final bool archived;
  final DateTime createdAt;
  final List<String> subtasks;
  final String? dreamId;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.priority,
    required this.status,
    required this.due,
    this.tags = const [],
    this.estimate = '30m',
    this.progress = 0,
    this.favorite = false,
    this.archived = false,
    required this.createdAt,
    this.subtasks = const [],
    this.dreamId,
  });

  TaskModel copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? due,
    List<String>? tags,
    String? estimate,
    int? progress,
    bool? favorite,
    bool? archived,
    List<String>? subtasks,
    String? dreamId,
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
      estimate: estimate ?? this.estimate,
      progress: progress ?? this.progress,
      favorite: favorite ?? this.favorite,
      archived: archived ?? this.archived,
      createdAt: createdAt,
      subtasks: subtasks ?? this.subtasks,
      dreamId: dreamId ?? this.dreamId,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: TaskCategory.fromName(json['category'] as String),
      priority: TaskPriority.fromName(json['priority'] as String),
      status: TaskStatus.fromName(json['status'] as String),
      due: DateTime.parse(json['due'] as String),
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      estimate: json['estimate'] as String? ?? '30m',
      progress: json['progress'] as int? ?? 0,
      favorite: json['favorite'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subtasks: (json['subtasks'] as List?)?.cast<String>() ?? const [],
      dreamId: json['dreamId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'priority': priority.name,
        'status': status.name,
        'due': due.toIso8601String(),
        'tags': tags,
        'estimate': estimate,
        'progress': progress,
        'favorite': favorite,
        'archived': archived,
        'createdAt': createdAt.toIso8601String(),
        'subtasks': subtasks,
        'dreamId': dreamId,
      };

  bool isDueOn(DateTime date) =>
      due.year == date.year && due.month == date.month && due.day == date.day;

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
        estimate,
        progress,
        favorite,
        archived,
        createdAt,
        subtasks,
        dreamId,
      ];
}
