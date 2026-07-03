import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_theme.dart';
import '../theme/theme_cubit.dart';
import '../theme/theme_state.dart';

/// Day / Auto / Night segmented toggle — mirrors .theme-toggle on web.
class ThemeToggleRow extends StatelessWidget {
  const ThemeToggleRow({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final choice = context.watch<ThemeCubit>().state.choice;

    Widget button(ThemeChoice value, IconData icon, String tooltip) {
      final active = choice == value;
      return Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => context.read<ThemeCubit>().setChoice(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? p.bgSurface : Colors.transparent,
              boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)] : null,
            ),
            child: Icon(icon, size: 16, color: active ? p.accent : p.textTertiary),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: p.bgSunken, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(ThemeChoice.day, Icons.wb_sunny_outlined, 'Day'),
          button(ThemeChoice.auto, Icons.contrast_rounded, 'Auto'),
          button(ThemeChoice.night, Icons.dark_mode_outlined, 'Night'),
        ],
      ),
    );
  }
}
