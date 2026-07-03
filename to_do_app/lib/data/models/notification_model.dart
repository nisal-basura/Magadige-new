import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum NotificationType {
  reminder,
  achievement,
  dream,
  summary,
  comment,
  system;

  IconData get icon => switch (this) {
        NotificationType.reminder => Icons.notifications_none_rounded,
        NotificationType.achievement => Icons.emoji_events_outlined,
        NotificationType.dream => Icons.auto_awesome_outlined,
        NotificationType.summary => Icons.bar_chart_rounded,
        NotificationType.comment => Icons.mail_outline_rounded,
        NotificationType.system => Icons.lightbulb_outline_rounded,
      };

  Color get color => switch (this) {
        NotificationType.reminder => AppColors.coral500,
        NotificationType.achievement => AppColors.amber500,
        NotificationType.dream => AppColors.indigo500,
        NotificationType.summary => AppColors.sky500,
        NotificationType.comment => AppColors.sky500,
        NotificationType.system => AppColors.mint500,
      };

  static NotificationType fromName(String name) =>
      NotificationType.values.firstWhere((t) => t.name == name, orElse: () => NotificationType.system);
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final NotificationType type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    required this.type,
  });

  NotificationModel copyWith({bool? unread}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        time: time,
        unread: unread ?? this.unread,
        type: type,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        time: json['time'] as String,
        unread: json['unread'] as bool? ?? false,
        type: NotificationType.fromName(json['type'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time,
        'unread': unread,
        'type': type.name,
      };

  @override
  List<Object?> get props => [id, title, body, time, unread, type];
}
