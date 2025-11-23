import 'package:flutter/material.dart';
import 'config/routes.dart'; // ✅ Importa tus rutas centralizadas
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Aquí va tu MaterialApp — no fuera de esta clase
    return MaterialApp(
      title: 'POS Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // ✅ La pantalla inicial (AuthWrapper decide login o dashboard)
      home: const AuthWrapper(),

      // ✅ Importa las rutas desde tu AppRoutes
      routes: AppRoutes.routes,

      // ✅ Manejador de rutas inexistentes
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

// ✅ Wrapper para verificar autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
