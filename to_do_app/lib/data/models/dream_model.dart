import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DreamModel extends Equatable {
  final String id;
  final String title;
  final String emoji;
  final String motivation;
  final DateTime target;
  final int progress; // 0-100
  final Color color;
  final List<String> relatedTaskIds;

  const DreamModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.motivation,
    required this.target,
    this.progress = 0,
    this.color = AppColors.indigo500,
    this.relatedTaskIds = const [],
  });

  DreamModel copyWith({
    String? title,
    String? emoji,
    String? motivation,
    DateTime? target,
    int? progress,
    Color? color,
    List<String>? relatedTaskIds,
  }) {
    return DreamModel(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      motivation: motivation ?? this.motivation,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      relatedTaskIds: relatedTaskIds ?? this.relatedTaskIds,
    );
  }

  int get daysLeft => target.difference(DateTime.now()).inDays;

  factory DreamModel.fromJson(Map<String, dynamic> json) {
    return DreamModel(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      motivation: json['motivation'] as String,
      target: DateTime.parse(json['target'] as String),
      progress: json['progress'] as int? ?? 0,
      color: Color(json['color'] as int? ?? AppColors.indigo500.toARGB32()),
      relatedTaskIds: (json['relatedTaskIds'] as List?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'motivation': motivation,
        'target': target.toIso8601String(),
        'progress': progress,
        'color': color.toARGB32(),
        'relatedTaskIds': relatedTaskIds,
      };

  @override
  List<Object?> get props => [id, title, emoji, motivation, target, progress, color, relatedTaskIds];
}
