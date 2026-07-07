import 'package:equatable/equatable.dart';

class SubtaskModel extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final bool isDone;
  final int position;

  const SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.isDone = false,
    this.position = 0,
  });

  SubtaskModel copyWith({String? title, bool? isDone, int? position}) => SubtaskModel(
        id: id,
        taskId: taskId,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        position: position ?? this.position,
      );

  factory SubtaskModel.fromJson(Map<String, dynamic> json) => SubtaskModel(
        id: json['id'].toString(),
        taskId: json['task_id'].toString(),
        title: json['title'] as String,
        isDone: json['is_done'] as bool? ?? false,
        position: json['position'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, taskId, title, isDone, position];
}
