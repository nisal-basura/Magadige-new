import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/relative_time.dart';

enum NotificationType {
  taskDue,
  badgeEarned,
  streakReminder,
  dreamProgress,
  system;

  IconData get icon => switch (this) {
        NotificationType.taskDue => Icons.notifications_none_rounded,
        NotificationType.badgeEarned => Icons.emoji_events_outlined,
        NotificationType.streakReminder => Icons.local_fire_department_outlined,
        NotificationType.dreamProgress => Icons.auto_awesome_outlined,
        NotificationType.system => Icons.lightbulb_outline_rounded,
      };

  Color get color => switch (this) {
        NotificationType.taskDue => AppColors.coral500,
        NotificationType.badgeEarned => AppColors.amber500,
        NotificationType.streakReminder => AppColors.coral500,
        NotificationType.dreamProgress => AppColors.indigo500,
        NotificationType.system => AppColors.mint500,
      };

  static NotificationType fromApi(String? value) => switch (value) {
        'task_due' => NotificationType.taskDue,
        'badge_earned' => NotificationType.badgeEarned,
        'streak_reminder' => NotificationType.streakReminder,
        'dream_progress' => NotificationType.dreamProgress,
        _ => NotificationType.system,
      };
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isUnread;
  final NotificationType type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isUnread = false,
    required this.type,
  });

  String get time => relativeTime(createdAt);

  NotificationModel copyWith({bool? isUnread}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        isUnread: isUnread ?? this.isUnread,
        type: type,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'].toString(),
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        isUnread: json['is_unread'] as bool? ?? false,
        type: NotificationType.fromApi(json['type'] as String?),
      );

  @override
  List<Object?> get props => [id, title, body, createdAt, isUnread, type];
}
