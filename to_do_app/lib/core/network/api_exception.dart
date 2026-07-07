/// Thrown by [ApiClient] for every non-2xx response, normalizing Laravel's
/// `{success:false, message, errors}` envelope into something Cubits can
/// branch on without knowing about Dio.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  /// Laravel validation errors: `{field: [messages]}`. Null for non-422s.
  final Map<String, List<String>>? errors;

  const ApiException({required this.message, this.statusCode, this.errors});

  /// The most useful single line to show a user: the first field-level
  /// validation message if there is one, otherwise the top-level message.
  String get displayMessage {
    final fieldErrors = errors;
    if (fieldErrors != null && fieldErrors.isNotEmpty) {
      final firstList = fieldErrors.values.first;
      if (firstList.isNotEmpty) return firstList.first;
    }
    return message;
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 422;

  @override
  String toString() => 'ApiException($statusCode, $message)';
}
