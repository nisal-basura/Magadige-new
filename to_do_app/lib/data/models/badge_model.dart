import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/utils/icon_mapper.dart';

/// The badge catalog entry (`GET /badges`) — no per-user progress here.
class BadgeModel extends Equatable {
  final String id;
  final String label;
  final String iconRaw;
  final String description;

  const BadgeModel({required this.id, required this.label, required this.iconRaw, required this.description});

  IconData get icon => iconForName(iconRaw);

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
        id: json['id'] as String,
        label: json['label'] as String,
        iconRaw: json['icon'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, label, iconRaw, description];
}

/// A catalog badge annotated with the authenticated user's progress toward
/// it (`GET /users/me/badges`) — a genuinely different endpoint/shape than
/// the plain catalog above.
class UserBadgeModel extends Equatable {
  final BadgeModel badge;
  final bool earned;
  final DateTime? earnedDate;
  final int progress;

  const UserBadgeModel({required this.badge, this.earned = false, this.earnedDate, this.progress = 0});

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) => UserBadgeModel(
        badge: BadgeModel.fromJson(json['badge'] as Map<String, dynamic>),
        earned: json['earned'] as bool? ?? false,
        earnedDate: json['earned_date'] != null ? DateTime.tryParse(json['earned_date'] as String) : null,
        progress: json['progress'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [badge, earned, earnedDate, progress];
}

class ActivityModel extends Equatable {
  final String id;
  final String type; // complete | create | dream | badge | overdue
  final String text;
  final String time;

  const ActivityModel({required this.id, required this.type, required this.text, required this.time});

  @override
  List<Object?> get props => [id, type, text, time];
}
