import '../datasources/local_data_store.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getCurrentUser();

  Future<List<BadgeModel>> getBadges();

  Future<List<ActivityModel>> getActivity();
}

class MockUserRepository implements UserRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.user;
  }

  @override
  Future<List<BadgeModel>> getBadges() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store.badges);
  }

  @override
  Future<List<ActivityModel>> getActivity() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store.activity);
  }
}
