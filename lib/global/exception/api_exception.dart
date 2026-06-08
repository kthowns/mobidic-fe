class ApiException implements Exception {
  final int status;
  final String message;
  final Map<String, dynamic> errors;

  ApiException({
    required this.status,
    required this.message,
    required this.errors,
  });

  @override
  String toString() => 'ApiException: $message';

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      status: json['status'] ?? 500,
      message: json['message'] ?? 'Unknown error',
      errors: Map<String, dynamic>.from(json['errors'] ?? {}),
    );
  }
}
