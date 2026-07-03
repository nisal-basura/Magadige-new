import 'package:equatable/equatable.dart';

/// The user's explicit choice — mirrors the day/auto/night pill toggle on web.
enum ThemeChoice { day, auto, night }

/// Time-of-day bucket — mirrors PERIODS in theme.js. Drives greeting copy,
/// icon, and mood text on the dashboard, independent of the light/dark
/// palette (morning/afternoon/evening are all "day" palette; only night
/// switches the palette).
enum AppDayPeriod { morning, afternoon, evening, night }

extension AppDayPeriodX on AppDayPeriod {
  bool get isDark => this == AppDayPeriod.night;

  String get label => switch (this) {
        AppDayPeriod.morning => 'Morning',
        AppDayPeriod.afternoon => 'Afternoon',
        AppDayPeriod.evening => 'Evening',
        AppDayPeriod.night => 'Night',
      };

  String get greeting => switch (this) {
        AppDayPeriod.morning => 'Good morning',
        AppDayPeriod.afternoon => 'Good afternoon',
        AppDayPeriod.evening => 'Good evening',
        AppDayPeriod.night => 'Good night',
      };

  String get mood => switch (this) {
        AppDayPeriod.morning => 'Fresh start, clear mind.',
        AppDayPeriod.afternoon => 'Keep the momentum going.',
        AppDayPeriod.evening => 'Wind down, wrap up well.',
        AppDayPeriod.night => 'Rest fuels tomorrow\'s focus.',
      };
}

class ThemeState extends Equatable {
  final ThemeChoice choice;
  final AppDayPeriod period;

  const ThemeState({required this.choice, required this.period});

  const ThemeState.initial()
      : choice = ThemeChoice.auto,
        period = AppDayPeriod.afternoon;

  bool get isDark => period.isDark;

  ThemeState copyWith({ThemeChoice? choice, AppDayPeriod? period}) {
    return ThemeState(choice: choice ?? this.choice, period: period ?? this.period);
  }

  @override
  List<Object?> get props => [choice, period];
}
