import '../datasources/local_data_store.dart';
import '../models/user_model.dart';

/// Auth contract. Swap [MockAuthRepository] for an `ApiAuthRepository` that
/// talks to the real backend once it exists — nothing above this layer
/// (Cubits, screens) needs to change.
abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({required String name, required String email, required String password});

  Future<void> requestPasswordReset(String email);

  Future<bool> verifyOtp({required String email, required String otp});

  Future<void> resetPassword({required String email, required String newPassword});

  Future<void> logout();

  Future<UserModel?> currentUser();
}

class MockAuthRepository implements AuthRepository {
  final LocalDataStore _store = LocalDataStore.instance;
  UserModel? _session;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _session = _store.user;
    return _session!;
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    final created = _store.user.copyWith(
      name: name,
      email: email,
      avatarInitials: initials.isEmpty ? 'U' : initials,
      streakCurrent: 0,
      streakLongest: 0,
      productivityScore: 0,
      plan: 'Free Plan',
    );
    _store.user = created;
    _session = created;
    return created;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return otp.trim().length == 4;
  }

  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }

  @override
  Future<void> logout() async {
    _session = null;
  }

  @override
  Future<UserModel?> currentUser() async => _session;
}
