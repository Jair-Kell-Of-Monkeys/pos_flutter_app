class AppConfig {
  // URL del backend (ACTUALIZAR CADA VEZ QUE REINICIES NGROK)
  static const String apiBaseUrl = 'https://gilma-uncomprehensible-determinably.ngrok-free.dev/api';

  // Headers requeridos por ngrok
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  // Configuración de la app
  static const String appName = 'POS Mobile';
  static const String appVersion = '1.0.0';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Claves de almacenamiento
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user_data';
}