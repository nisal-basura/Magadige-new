import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/color_parser.dart';

class DreamModel extends Equatable {
  final String id;
  final String title;
  final String emoji;
  final String motivation;
  final DateTime? target;
  final int progress; // 0-100, server-computed from linked task completion
  final String? colorRaw;
  final int tasksCount;
  final int completedTasksCount;
  final DateTime? createdAt;

  const DreamModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.motivation,
    this.target,
    this.progress = 0,
    this.colorRaw,
    this.tasksCount = 0,
    this.completedTasksCount = 0,
    this.createdAt,
  });

  Color get color => colorFromHex(colorRaw, fallback: AppColors.indigo500);

  /// Null when no target date was set.
  int? get daysLeft => target?.difference(DateTime.now()).inDays;

  DreamModel copyWith({
    String? title,
    String? emoji,
    String? motivation,
    DateTime? target,
    int? progress,
    String? colorRaw,
    int? tasksCount,
    int? completedTasksCount,
  }) {
    return DreamModel(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      motivation: motivation ?? this.motivation,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      colorRaw: colorRaw ?? this.colorRaw,
      tasksCount: tasksCount ?? this.tasksCount,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      createdAt: createdAt,
    );
  }

  factory DreamModel.fromJson(Map<String, dynamic> json) {
    return DreamModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '',
      motivation: json['motivation'] as String? ?? '',
      target: json['target_date'] != null ? DateTime.tryParse(json['target_date'] as String) : null,
      progress: json['progress'] as int? ?? 0,
      colorRaw: json['color'] as String?,
      tasksCount: json['tasks_count'] as int? ?? 0,
      completedTasksCount: json['completed_tasks_count'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  /// Payload for `POST /dreams` / `PUT /dreams/{id}` — `progress` is
  /// server-computed and stripped by the backend even if sent, so it's
  /// deliberately not included here.
  Map<String, dynamic> toRequestJson() => {
        'title': title,
        'emoji': emoji.isEmpty ? null : emoji,
        'motivation': motivation.isEmpty ? null : motivation,
        'target_date': target?.toIso8601String().split('T').first,
        'color': colorRaw,
      };

  @override
  List<Object?> get props =>
      [id, title, emoji, motivation, target, progress, colorRaw, tasksCount, completedTasksCount, createdAt];
}
