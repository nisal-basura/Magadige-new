import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BadgeModel extends Equatable {
  final String id;
  final String label;
  final IconData icon;
  final String description;
  final bool earned;
  final DateTime? earnedDate;
  final int progress; // 0-100, only meaningful when not earned

  const BadgeModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
    this.earned = false,
    this.earnedDate,
    this.progress = 0,
  });

  @override
  List<Object?> get props => [id, label, icon, description, earned, earnedDate, progress];
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
