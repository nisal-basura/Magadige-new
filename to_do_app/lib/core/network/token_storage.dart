import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the JWT session across launches via `shared_preferences` — plain
/// local app storage rather than the OS keychain (a deliberate tradeoff:
/// `flutter_secure_storage`'s Windows plugin requires an MSVC ATL component
/// not installed on every dev machine, so this keeps the app buildable
/// everywhere with zero native dependencies). Every call is defensive — on
/// platforms/tests without a working prefs channel, reads fail soft to "no
/// session" instead of throwing, so the app still boots to a logged-out state.
class TokenStorage {
  TokenStorage();

  Future<SharedPreferences>? _prefsFuture;
  Future<SharedPreferences> get _prefs => _prefsFuture ??= SharedPreferences.getInstance();

  static const _keyAccessToken = 'magadige.access_token';
  static const _keyExpiresAt = 'magadige.expires_at';
  static const _keySessionId = 'magadige.session_id';
  static const _keyUser = 'magadige.cached_user';

  Future<String?> readAccessToken() => _read(_keyAccessToken);

  Future<DateTime?> readExpiresAt() async {
    final raw = await _read(_keyExpiresAt);
    if (raw == null) return null;
    final millis = int.tryParse(raw);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<int?> readSessionId() async {
    final raw = await _read(_keySessionId);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<Map<String, dynamic>?> readCachedUser() async {
    final raw = await _read(_keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession({
    required String accessToken,
    required int expiresInSeconds,
    required int sessionId,
    Map<String, dynamic>? user,
  }) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await _write(_keyAccessToken, accessToken);
    await _write(_keyExpiresAt, expiresAt.millisecondsSinceEpoch.toString());
    await _write(_keySessionId, sessionId.toString());
    if (user != null) await _write(_keyUser, jsonEncode(user));
  }

  Future<void> saveCachedUser(Map<String, dynamic> user) => _write(_keyUser, jsonEncode(user));

  Future<void> clear() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyExpiresAt);
      await prefs.remove(_keySessionId);
      await prefs.remove(_keyUser);
    } catch (_) {
      // No prefs channel available (e.g. tests) — nothing to clear.
    }
  }

  Future<String?> _read(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(key, value);
    } catch (_) {
      // Ignore — best-effort persistence only.
    }
  }
}
