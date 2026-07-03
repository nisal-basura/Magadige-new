import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Task category — mirrors CATEGORIES in data.js.
enum TaskCategory {
  work,
  personal,
  health,
  learning,
  finance;

  String get label => switch (this) {
        TaskCategory.work => 'Work',
        TaskCategory.personal => 'Personal',
        TaskCategory.health => 'Health',
        TaskCategory.learning => 'Learning',
        TaskCategory.finance => 'Finance',
      };

  IconData get icon => switch (this) {
        TaskCategory.work => Icons.work_outline_rounded,
        TaskCategory.personal => Icons.person_outline_rounded,
        TaskCategory.health => Icons.favorite_outline_rounded,
        TaskCategory.learning => Icons.menu_book_outlined,
        TaskCategory.finance => Icons.account_balance_wallet_outlined,
      };

  Color get color => switch (this) {
        TaskCategory.work => AppColors.indigo500,
        TaskCategory.personal => AppColors.sky500,
        TaskCategory.health => AppColors.mint500,
        TaskCategory.learning => AppColors.amber500,
        TaskCategory.finance => AppColors.gray500,
      };

  Color get softColor => switch (this) {
        TaskCategory.work => AppColors.indigo50,
        TaskCategory.personal => AppColors.sky50,
        TaskCategory.health => const Color(0xFFE3F9EF),
        TaskCategory.learning => AppColors.amber50,
        TaskCategory.finance => AppColors.gray100,
      };

  static TaskCategory fromName(String name) =>
      TaskCategory.values.firstWhere((c) => c.name == name, orElse: () => TaskCategory.work);
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

  static TaskPriority fromName(String name) =>
      TaskPriority.values.firstWhere((p) => p.name == name, orElse: () => TaskPriority.medium);
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

  static TaskStatus fromName(String name) =>
      TaskStatus.values.firstWhere((s) => s.name == name, orElse: () => TaskStatus.pending);
}
