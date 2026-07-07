import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/color_parser.dart';
import '../../core/utils/icon_mapper.dart';

/// Task category — a dynamic, DB-backed catalog on the real backend
/// (`GET /categories`), not a fixed set. `color`/`icon` are free-form
/// strings server-side, parsed defensively here.
class CategoryModel extends Equatable {
  final String id;
  final String label;
  final String colorRaw;
  final String iconRaw;

  const CategoryModel({required this.id, required this.label, required this.colorRaw, required this.iconRaw});

  Color get color => colorFromHex(colorRaw);
  Color get softColor => color.withValues(alpha: 0.14);
  IconData get icon => iconForName(iconRaw);

  static const unknown = CategoryModel(id: '', label: 'Uncategorized', colorRaw: '#9CA3AF', iconRaw: '');

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        label: json['label'] as String,
        colorRaw: json['color'] as String? ?? '',
        iconRaw: json['icon'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, label, colorRaw, iconRaw];
}

enum TaskPriority {
  low,
  medium,
  high;

  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };

  Color get color => switch (this) {
        TaskPriority.low => AppColors.mint500,
        TaskPriority.medium => AppColors.amber500,
        TaskPriority.high => AppColors.coral500,
      };

  String get apiValue => name;

  static TaskPriority fromApi(String? value) =>
      TaskPriority.values.firstWhere((p) => p.name == value, orElse: () => TaskPriority.medium);
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  overdue;

  String get label => switch (this) {
        TaskStatus.pending => 'Pending',
        TaskStatus.inProgress => 'In progress',
        TaskStatus.completed => 'Completed',
        TaskStatus.overdue => 'Overdue',
      };

  Color get color => switch (this) {
        TaskStatus.pending => AppColors.sky500,
        TaskStatus.inProgress => AppColors.indigo500,
        TaskStatus.completed => AppColors.mint500,
        TaskStatus.overdue => AppColors.coral500,
      };

  /// The backend's literal value is hyphenated (`in-progress`) so it can't
  /// be a bare Dart identifier — map explicitly rather than relying on `.name`.
  String get apiValue => switch (this) {
        TaskStatus.pending => 'pending',
        TaskStatus.inProgress => 'in-progress',
        TaskStatus.completed => 'completed',
        TaskStatus.overdue => 'overdue',
      };

  static TaskStatus fromApi(String? value) => switch (value) {
        'in-progress' => TaskStatus.inProgress,
        'completed' => TaskStatus.completed,
        'overdue' => TaskStatus.overdue,
        _ => TaskStatus.pending,
      };
}

enum ReminderOption {
  none,
  tenMinutes,
  oneHour,
  oneDay;

  String get label => switch (this) {
        ReminderOption.none => 'No reminder',
        ReminderOption.tenMinutes => '10 minutes before',
        ReminderOption.oneHour => '1 hour before',
        ReminderOption.oneDay => '1 day before',
      };

  String get apiValue => switch (this) {
        ReminderOption.none => 'none',
        ReminderOption.tenMinutes => '10m',
        ReminderOption.oneHour => '1h',
        ReminderOption.oneDay => '1d',
      };

  static ReminderOption fromApi(String? value) => switch (value) {
        '10m' => ReminderOption.tenMinutes,
        '1h' => ReminderOption.oneHour,
        '1d' => ReminderOption.oneDay,
        _ => ReminderOption.none,
      };
}

enum RepeatRule {
  none,
  daily,
  weekly,
  monthly;

  String get label => switch (this) {
        RepeatRule.none => 'Does not repeat',
        RepeatRule.daily => 'Daily',
        RepeatRule.weekly => 'Weekly',
        RepeatRule.monthly => 'Monthly',
      };

  String get apiValue => name;

  static RepeatRule fromApi(String? value) =>
      RepeatRule.values.firstWhere((r) => r.name == value, orElse: () => RepeatRule.none);
}
