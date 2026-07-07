import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Thin wrapper around Dio that: injects the bearer token, proactively
/// rotates it via `/auth/refresh` shortly before it expires (the backend has
/// no separate refresh-token concept — see plan notes), unwraps the
/// `{success, message, data}` envelope, and normalizes failures into
/// [ApiException]. Callers just get back the decoded `data` payload.
class ApiClient {
  ApiClient({required TokenStorage tokenStorage, void Function()? onSessionExpired})
      : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      headers: const {'Accept': 'application/json'},
      contentType: 'application/json',
    ));
    _refreshDio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      headers: const {'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest, onError: _onError));
  }

  final TokenStorage _tokenStorage;
  final void Function()? _onSessionExpired;
  late final Dio _dio;
  late final Dio _refreshDio;
  Future<String?>? _refreshFuture;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _unwrap(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {dynamic data}) => _unwrap(() => _dio.post(path, data: data));

  Future<dynamic> put(String path, {dynamic data}) => _unwrap(() => _dio.put(path, data: data));

  Future<dynamic> patch(String path, {dynamic data}) => _unwrap(() => _dio.patch(path, data: data));

  Future<dynamic> delete(String path, {dynamic data}) => _unwrap(() => _dio.delete(path, data: data));

  /// Drains every page of a `{items, pagination}` envelope and returns the
  /// concatenated raw item maps — every list endpoint in this API is capped
  /// at 100/page, so this is usually 1-2 requests.
  Future<List<Map<String, dynamic>>> getAllPages(String path, {Map<String, dynamic>? query}) async {
    final items = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final data = await get(path, query: {...?query, 'page': page, 'per_page': 100}) as Map<String, dynamic>;
      items.addAll((data['items'] as List).cast<Map<String, dynamic>>());
      final pagination = data['pagination'] as Map<String, dynamic>;
      final currentPage = pagination['current_page'] as int;
      final lastPage = pagination['last_page'] as int;
      if (currentPage >= lastPage) break;
      page = currentPage + 1;
    }
    return items;
  }

  Future<dynamic> _unwrap(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      final body = response.data;
      return body is Map<String, dynamic> ? body['data'] : body;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _ensureFreshToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  Future<String?> _ensureFreshToken() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) return null;
    final expiresAt = await _tokenStorage.readExpiresAt();
    if (expiresAt == null || expiresAt.difference(DateTime.now()) > const Duration(seconds: 60)) {
      return token;
    }
    return _refreshFuture ??= _refresh(token).whenComplete(() => _refreshFuture = null);
  }

  Future<String?> _refresh(String currentToken) async {
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) return currentToken;
      final newToken = data['access_token'] as String;
      final cachedUser = await _tokenStorage.readCachedUser();
      await _tokenStorage.saveSession(
        accessToken: newToken,
        expiresInSeconds: data['expires_in'] as int,
        sessionId: data['session_id'] as int,
        user: cachedUser,
      );
      return newToken;
    } catch (_) {
      await _tokenStorage.clear();
      _onSessionExpired?.call();
      return null;
    }
  }

  Future<void> _onError(DioException err, ErrorInterceptorHandler handler) async {
    final message = _extractMessage(err.response);
    if (err.response?.statusCode == 401 &&
        (message == 'Unauthenticated.' || message == 'Session expired or revoked')) {
      await _tokenStorage.clear();
      _onSessionExpired?.call();
    }
    handler.next(err);
  }

  ApiException _toApiException(DioException e) {
    final response = e.response;
    final body = response?.data;
    if (body is Map<String, dynamic>) {
      final rawErrors = body['errors'];
      Map<String, List<String>>? errors;
      if (rawErrors is Map) {
        errors = rawErrors.map(
          (key, value) => MapEntry(key.toString(), (value as List).map((m) => m.toString()).toList()),
        );
      }
      return ApiException(
        statusCode: response?.statusCode,
        message: body['message'] as String? ?? 'Something went wrong.',
        errors: errors,
      );
    }
    return ApiException(
      statusCode: response?.statusCode,
      message: e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout
          ? 'Could not reach the server. Check your connection.'
          : (e.message ?? 'Something went wrong.'),
    );
  }

  String? _extractMessage(Response<dynamic>? response) {
    final body = response?.data;
    if (body is Map<String, dynamic>) return body['message'] as String?;
    return null;
  }
}
