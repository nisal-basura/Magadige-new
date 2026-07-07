import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../datasources/local_data_store.dart';
import '../models/user_model.dart';

/// Auth contract. Swap [MockAuthRepository] for [ApiAuthRepository] — nothing
/// above this layer (Cubits, screens) needs to change beyond constructor
/// wiring, since both implement the same interface.
abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({required String email, required String token, required String newPassword});

  Future<void> changePassword({required String currentPassword, required String newPassword});

  Future<void> logout();

  Future<void> logoutAllOtherSessions();

  /// The current session's user — a cached value when possible (fast boot),
  /// falling back to `/auth/me`. Null if there's no session at all.
  Future<UserModel?> currentUser();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required ApiClient apiClient, required TokenStorage tokenStorage})
      : _api = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final data = await _api.post('/auth/login', data: {'email': email, 'password': password}) as Map<String, dynamic>;
    return _persistSession(data);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _api.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    }) as Map<String, dynamic>;
    return _persistSession(data);
  }

  Future<UserModel> _persistSession(Map<String, dynamic> data) async {
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);
    await _tokenStorage.saveSession(
      accessToken: data['access_token'] as String,
      expiresInSeconds: data['expires_in'] as int,
      sessionId: data['session_id'] as int,
      user: userJson,
    );
    return user;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _api.post('/auth/forgot-password', data: {'email': email});
  }

  @override
  Future<void> resetPassword({required String email, required String token, required String newPassword}) async {
    await _api.post('/auth/reset-password', data: {
      'token': token,
      'email': email,
      'password': newPassword,
      'password_confirmation': newPassword,
    });
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _api.put('/auth/password', data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPassword,
    });
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Best-effort — always clear the local session regardless.
    }
    await _tokenStorage.clear();
  }

  @override
  Future<void> logoutAllOtherSessions() async {
    await _api.post('/auth/logout-all');
  }

  @override
  Future<UserModel?> currentUser() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) return null;
    final cached = await _tokenStorage.readCachedUser();
    if (cached != null) return UserModel.fromJson(cached);
    try {
      final data = await _api.get('/auth/me') as Map<String, dynamic>;
      await _tokenStorage.saveCachedUser(data);
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
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
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final created = _store.user.copyWith(name: name, email: email, streakCurrent: 0, streakLongest: 0, productivityScore: 0, plan: 'Free');
    _store.user = created;
    _session = created;
    return created;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> resetPassword({required String email, required String token, required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> logout() async {
    _session = null;
  }

  @override
  Future<void> logoutAllOtherSessions() async {}

  @override
  Future<UserModel?> currentUser() async => _session;
}
