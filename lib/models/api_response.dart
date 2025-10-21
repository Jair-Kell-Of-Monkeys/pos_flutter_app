class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final List<dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.errors,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {String? errorCode, List<dynamic>? errors}) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      errors: errors,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] ?? json['error'],
      errorCode: json['error_code'],
      errors: json['errors'],
    );
  }
}