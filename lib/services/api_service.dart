import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // Headers base CON el header de ngrok
  Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true', // CRÍTICO para ngrok
      };

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.keyAccessToken);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.keyRefreshToken);
  }

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyAccessToken, access);
    await prefs.setString(AppConfig.keyRefreshToken, refresh);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.keyAccessToken);
    await prefs.remove(AppConfig.keyRefreshToken);
    await prefs.remove(AppConfig.keyUser);
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAccessToken();
    final headers = Map<String, String>.from(_baseHeaders);
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _client.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh/'),
        headers: _baseHeaders,
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint')
          .replace(queryParameters: queryParams);
      
      final headers = await _getAuthHeaders();
      var response = await _client.get(uri, headers: headers)
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newHeaders = await _getAuthHeaders();
          response = await _client.get(uri, headers: newHeaders);
        } else {
          throw ApiException(
            statusCode: 401,
            message: 'Sesión expirada',
            errorCode: 'SESSION_EXPIRED',
          );
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Error de conexión: $e',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getAuthHeaders();
      
      var response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 401 && endpoint != '/auth/login/') {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newHeaders = await _getAuthHeaders();
          response = await _client.post(
            uri,
            headers: newHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        } else {
          throw ApiException(
            statusCode: 401,
            message: 'Sesión expirada',
            errorCode: 'SESSION_EXPIRED',
          );
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Error de conexión: $e',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        return {'success': true, 'data': response.body};
      }
    } else {
      Map<String, dynamic> errorBody;
      try {
        errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        errorBody = {'error': 'Error desconocido'};
      }
      
      throw ApiException(
        statusCode: statusCode,
        message: errorBody['error'] ?? 
                 errorBody['detail'] ?? 
                 'Error $statusCode',
        errorCode: errorBody['error_code'],
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? errorCode;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errorCode,
  });

  @override
  String toString() => message;
}