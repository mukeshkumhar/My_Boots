class ApiResponse {
  final int? statusCode;
  final bool success;
  final String? message;
  final dynamic data;                // your backend "data" blob
  final Map<String, dynamic>? raw;   // full JSON if needed

  const ApiResponse({
    this.statusCode,
    required this.success,
    this.message,
    this.data,
    this.raw,
  });
}
