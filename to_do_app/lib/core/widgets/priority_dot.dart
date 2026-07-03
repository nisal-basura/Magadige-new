import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';

class PriorityDot extends StatelessWidget {
  final TaskPriority priority;
  final double size;

  const PriorityDot({super.key, required this.priority, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: priority.color, shape: BoxShape.circle),
    );
  }
}
