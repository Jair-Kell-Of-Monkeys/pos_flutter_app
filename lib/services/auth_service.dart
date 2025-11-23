import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import 'api_service.dart';

// ⬇️⬇️⬇️ AGREGA ESTA FUNCIÓN AQUÍ (fuera de la clase)
Map<String, dynamic> parseUserString(String userStr) {
  userStr = userStr.replaceAll("{", "").replaceAll("}", "");
  final pairs = userStr.split(",");
  final Map<String, dynamic> userMap = {};

  for (var pair in pairs) {
    final parts = pair.split(":");
    if (parts.length == 2) {
      final key = parts[0].trim();
      final value = parts[1].trim();
      userMap[key] = value;
    }
  }

  return userMap;
}
// ⬆️⬆️⬆️ FIN DE LA FUNCIÓN

class AuthService {
  final ApiService _apiService = ApiService();

  // Login con debug detallado
  Future<User> login(String username, String password) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔵 INICIO LOGIN');
    print('Usuario: $username');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await _apiService.post(
        '/auth/login/',
        body: {'username': username, 'password': password},
      );

      print('✅ Respuesta recibida del servidor');
      print('Tipo de respuesta: ${response.runtimeType}');
      print('Contenido completo: $response');
      print('');

      // Verificar que la respuesta no sea nula
      if (response == null) {
        print('❌ ERROR: Respuesta es null');
        throw Exception('No se recibió respuesta del servidor');
      }

      // Verificar tokens
      print('🔑 Verificando tokens...');
      print('Tiene "access": ${response.containsKey('access')}');
      print('Tiene "refresh": ${response.containsKey('refresh')}');
      print('Tiene "user": ${response.containsKey('user')}');

      if (!response.containsKey('access')) {
        print('❌ ERROR: Falta el token "access"');
        print('Keys disponibles: ${response.keys.toList()}');
        throw Exception('Usuario o contraseña incorrectos');
      }

      if (!response.containsKey('refresh')) {
        print('❌ ERROR: Falta el token "refresh"');
        throw Exception('Usuario o contraseña incorrectos');
      }

      if (!response.containsKey('user')) {
        print('❌ ERROR: Faltan datos de usuario');
        throw Exception('Error en la respuesta del servidor');
      }

      // Guardar tokens
      print('');
      print('💾 Guardando tokens...');
      print('Access token: ${response['access'].substring(0, 20)}...');
      print('Refresh token: ${response['refresh'].substring(0, 20)}...');

      await _apiService.saveTokens(response['access'], response['refresh']);
      print('✅ Tokens guardados');

      // Parsear usuario
      print('');
      print('👤 Procesando datos de usuario...');
      print('Datos de usuario recibidos: ${response['user']}');

      final user = User.fromJson(response['user']);
      print('✅ Usuario parseado: ${user.username}');

      // Guardar usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.keyUser, jsonEncode(user.toJson()));
      print('✅ Usuario guardado en SharedPreferences');

      print('');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ LOGIN EXITOSO');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return user;
    } on ApiException catch (e) {
      print('');
      print('❌ ERROR ApiException:');
      print('Status code: ${e.statusCode}');
      print('Mensaje: ${e.message}');
      print('Error code: ${e.errorCode}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (e.statusCode == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      }
      throw Exception(e.message);
    } on FormatException catch (e) {
      print('');
      print('❌ ERROR FormatException:');
      print('Detalle: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Error al procesar datos del usuario');
    } catch (e, stackTrace) {
      print('');
      print('❌ ERROR INESPERADO:');
      print('Tipo: ${e.runtimeType}');
      print('Mensaje: $e');
      print('Stack trace:');
      print(stackTrace);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      throw Exception('Usuario o contraseña incorrectos');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.clearTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.keyUser);
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
    }
  }

  // Obtener usuario actual guardado
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(AppConfig.keyUser);

      if (userStr != null) {
        return User.fromJson(jsonDecode(userStr));
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener usuario actual: $e');
      return null;
    }
  }

  // Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.containsKey(AppConfig.keyAccessToken);
      return hasToken;
    } catch (e) {
      return false;
    }
  }

  // Obtener info del usuario desde el servidor
  Future<User> getMe() async {
    try {
      final response = await _apiService.get('/users/me/');

      final user = User.fromJson(response);

      // Guardar usuario actualizado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.keyUser, jsonEncode(user.toJson()));

      print('✅ Información de usuario actualizada');
      return user;
    } catch (e) {
      print('❌ Error al obtener información del usuario: $e');
      throw Exception('Error al obtener información del usuario');
    }
  }

  // Registro de usuario
  Future<User> register(String username, String email, String password) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🟢 INICIO REGISTRO');
    print('Username: $username');
    print('Email: $email');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await _apiService.post(
        '/auth/register/',
        body: {'username': username, 'email': email, 'password': password},
      );

      print('📥 Respuesta del servidor: $response');

      if (response == null) {
        throw Exception('No se recibió respuesta del servidor');
      }

      if (!response.containsKey('user')) {
        throw Exception('Error en la respuesta del servidor');
      }

      dynamic userData = response['user'];

      if (userData is String) {
        userData = parseUserString(userData);
      }

      final user = User.fromJson(userData);

      print('✅ Usuario registrado: ${user.username}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return user;
    } on ApiException catch (e) {
      print('❌ ERROR ApiException: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('❌ ERROR inesperado: $e');
      throw Exception('Error al registrar usuario');
    }
  }
}
