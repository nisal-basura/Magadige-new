import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';

class GreetingHeader extends StatelessWidget {
  final String firstName;
  const GreetingHeader({super.key, required this.firstName});

  IconData _iconFor(AppDayPeriod period) => switch (period) {
        AppDayPeriod.morning => Icons.wb_twilight_outlined,
        AppDayPeriod.afternoon => Icons.wb_sunny_outlined,
        AppDayPeriod.evening => Icons.wb_shade_outlined,
        AppDayPeriod.night => Icons.dark_mode_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final period = context.watch<ThemeCubit>().state.period;
    final now = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: p.brand.withValues(alpha: 0.32), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Icon(_iconFor(period), color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${period.greeting}, $firstName.', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 2),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(period.mood, style: Theme.of(context).textTheme.bodySmall),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.access_time_rounded, size: 12, color: p.textTertiary),
                    const SizedBox(width: 3),
                    Text(DateFormat('h:mm a').format(now), style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: p.textTertiary),
                    const SizedBox(width: 3),
                    Text(DateFormat('EEE, MMM d').format(now), style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
