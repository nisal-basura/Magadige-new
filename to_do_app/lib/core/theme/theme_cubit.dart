import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

/// Drives the day/auto/night experience app-wide — the Flutter equivalent of
/// js/theme.js. Persists the user's explicit choice; "auto" re-derives the
/// period from the wall clock every time [refresh] is called.
class ThemeCubit extends Cubit<ThemeState> {
  static const _prefsKey = 'magadige_theme_choice';
  final SharedPreferences _prefs;
  Timer? _ticker;

  ThemeCubit(this._prefs) : super(const ThemeState.initial()) {
    _restore();
    // Mirrors the web app's 5-minute re-check so a long-open session still
    // drifts from afternoon into evening/night while in auto mode.
    _ticker = Timer.periodic(const Duration(minutes: 5), (_) => refresh());
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  void _restore() {
    final saved = _prefs.getString(_prefsKey);
    final choice = ThemeChoice.values.firstWhere(
      (c) => c.name == saved,
      orElse: () => ThemeChoice.auto,
    );
    emit(ThemeState(choice: choice, period: _periodFor(choice)));
  }

  AppDayPeriod _detectPeriod([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) return AppDayPeriod.morning;
    if (hour >= 12 && hour < 17) return AppDayPeriod.afternoon;
    if (hour >= 17 && hour < 21) return AppDayPeriod.evening;
    return AppDayPeriod.night;
  }

  AppDayPeriod _periodFor(ThemeChoice choice) {
    return switch (choice) {
      ThemeChoice.day => AppDayPeriod.afternoon,
      ThemeChoice.night => AppDayPeriod.night,
      ThemeChoice.auto => _detectPeriod(),
    };
  }

  /// Re-checks the wall clock — call periodically while in auto mode so a
  /// long-open session still transitions from afternoon into evening/night.
  void refresh() {
    if (state.choice != ThemeChoice.auto) return;
    final period = _detectPeriod();
    if (period != state.period) emit(state.copyWith(period: period));
  }

  Future<void> setChoice(ThemeChoice choice) async {
    await _prefs.setString(_prefsKey, choice.name);
    emit(ThemeState(choice: choice, period: _periodFor(choice)));
  }
}
