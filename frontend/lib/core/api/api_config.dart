import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090/api/v1';
    }
    return 'http://localhost:8090/api/v1';
  }

  static final http.Client _defaultClient = http.Client();
  static http.Client? clientOverride;
  static http.Client get client => clientOverride ?? _defaultClient;
}

class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  ApiException({required this.statusCode, required this.code, required this.message});

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
