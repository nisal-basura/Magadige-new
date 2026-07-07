import 'package:equatable/equatable.dart';

class TagModel extends Equatable {
  final String id;
  final String label;

  const TagModel({required this.id, required this.label});

  factory TagModel.fromJson(Map<String, dynamic> json) => TagModel(
        id: json['id'].toString(),
        label: json['label'] as String,
      );

  @override
  List<Object?> get props => [id, label];
}
