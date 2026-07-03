import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState extends Equatable {
  final bool taskReminders;
  final bool dailySummary;
  final bool streakAlerts;
  final bool dreamNudges;
  final bool marketingEmails;
  final bool publicProfile;
  final bool usageAnalytics;
  final bool twoFactor;

  const SettingsState({
    this.taskReminders = true,
    this.dailySummary = true,
    this.streakAlerts = true,
    this.dreamNudges = false,
    this.marketingEmails = false,
    this.publicProfile = false,
    this.usageAnalytics = true,
    this.twoFactor = false,
  });

  SettingsState copyWith({
    bool? taskReminders,
    bool? dailySummary,
    bool? streakAlerts,
    bool? dreamNudges,
    bool? marketingEmails,
    bool? publicProfile,
    bool? usageAnalytics,
    bool? twoFactor,
  }) {
    return SettingsState(
      taskReminders: taskReminders ?? this.taskReminders,
      dailySummary: dailySummary ?? this.dailySummary,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      dreamNudges: dreamNudges ?? this.dreamNudges,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      publicProfile: publicProfile ?? this.publicProfile,
      usageAnalytics: usageAnalytics ?? this.usageAnalytics,
      twoFactor: twoFactor ?? this.twoFactor,
    );
  }

  @override
  List<Object?> get props => [taskReminders, dailySummary, streakAlerts, dreamNudges, marketingEmails, publicProfile, usageAnalytics, twoFactor];
}

/// Purely local UI-preference state — no backend concept of "settings" yet,
/// so there's no repository here. When one exists, this Cubit starts calling
/// it instead of just emitting new state directly.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleTaskReminders() => emit(state.copyWith(taskReminders: !state.taskReminders));
  void toggleDailySummary() => emit(state.copyWith(dailySummary: !state.dailySummary));
  void toggleStreakAlerts() => emit(state.copyWith(streakAlerts: !state.streakAlerts));
  void toggleDreamNudges() => emit(state.copyWith(dreamNudges: !state.dreamNudges));
  void toggleMarketingEmails() => emit(state.copyWith(marketingEmails: !state.marketingEmails));
  void togglePublicProfile() => emit(state.copyWith(publicProfile: !state.publicProfile));
  void toggleUsageAnalytics() => emit(state.copyWith(usageAnalytics: !state.usageAnalytics));
  void toggleTwoFactor() => emit(state.copyWith(twoFactor: !state.twoFactor));
}
