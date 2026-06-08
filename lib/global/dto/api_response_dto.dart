class GeneralResponseDto {
  final int status;
  final String message;
  final dynamic data;

  GeneralResponseDto({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GeneralResponseDto.fromJson(Map<String, dynamic> json) =>
      GeneralResponseDto(
        status: json['status'],
        message: json['message'],
        data: json['data'],
      );
}

class ErrorResponseDto {
  final int status;
  final String message;
  final Map<String, dynamic>? errors;

  ErrorResponseDto({
    required this.status,
    required this.message,
    required this.errors,
  });

  factory ErrorResponseDto.fromJson(Map<String, dynamic> json) =>
      ErrorResponseDto(
        status: json['status'],
        message: json['message'],
        errors: json['errors'],
      );
}
