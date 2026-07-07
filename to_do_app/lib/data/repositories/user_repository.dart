import '../../core/network/api_client.dart';
import '../datasources/local_data_store.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';

class UserStats extends Object {
  final int streakCurrent;
  final int streakLongest;
  final int productivityScore;
  final int badgesEarnedCount;
  final int tasksCompletedTotal;
  final int dreamsCompletedTotal;

  const UserStats({
    this.streakCurrent = 0,
    this.streakLongest = 0,
    this.productivityScore = 0,
    this.badgesEarnedCount = 0,
    this.tasksCompletedTotal = 0,
    this.dreamsCompletedTotal = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        streakCurrent: json['streak_current'] as int? ?? 0,
        streakLongest: json['streak_longest'] as int? ?? 0,
        productivityScore: json['productivity_score'] as int? ?? 0,
        badgesEarnedCount: json['badges_earned_count'] as int? ?? 0,
        tasksCompletedTotal: json['tasks_completed_total'] as int? ?? 0,
        dreamsCompletedTotal: json['dreams_completed_total'] as int? ?? 0,
      );
}

abstract class UserRepository {
  Future<UserModel> getCurrentUser();

  Future<List<UserBadgeModel>> getBadges();

  Future<UserStats> getStats();
}

class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._api);
  final ApiClient _api;

  @override
  Future<UserModel> getCurrentUser() async {
    final data = await _api.get('/auth/me') as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<List<UserBadgeModel>> getBadges() async {
    final data = await _api.get('/users/me/badges') as List;
    return data.map((b) => UserBadgeModel.fromJson(b as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserStats> getStats() async {
    final data = await _api.get('/users/me/stats') as Map<String, dynamic>;
    return UserStats.fromJson(data);
  }
}

class MockUserRepository implements UserRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.user;
  }

  @override
  Future<List<UserBadgeModel>> getBadges() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store.userBadges);
  }

  @override
  Future<UserStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final user = _store.user;
    return UserStats(
      streakCurrent: user.streakCurrent,
      streakLongest: user.streakLongest,
      productivityScore: user.productivityScore,
      badgesEarnedCount: _store.userBadges.where((b) => b.earned).length,
      tasksCompletedTotal: _store.tasks.where((t) => t.progress == 100).length,
      dreamsCompletedTotal: _store.dreams.where((d) => d.progress == 100).length,
    );
  }
}
