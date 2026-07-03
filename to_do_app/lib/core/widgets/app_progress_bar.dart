import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Linear progress bar with a brand gradient fill — mirrors .progress-bar.
class AppProgressBar extends StatelessWidget {
  final int progress; // 0-100
  final double height;
  final List<Color>? gradient;

  const AppProgressBar({super.key, required this.progress, this.height = 8, this.gradient});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pct = (progress.clamp(0, 100)) / 100;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: height, color: p.bgSunken),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: height,
                width: constraints.maxWidth * pct,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient ?? [p.secondary, p.brand]),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
