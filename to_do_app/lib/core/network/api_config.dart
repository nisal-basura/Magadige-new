/// Single source of truth for the backend host. Override at build/run time
/// with `--dart-define=API_BASE_URL=https://your-host` — nothing else in the
/// app needs to change when the backend moves.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String apiPrefix = '/api/v1';

  static String get apiBaseUrl => '$baseUrl$apiPrefix';
}
