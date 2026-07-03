import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AvatarInitials extends StatelessWidget {
  final String initials;
  final double size;

  const AvatarInitials({super.key, required this.initials, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [p.brand.withValues(alpha: 0.9), p.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.36),
      ),
    );
  }
}
