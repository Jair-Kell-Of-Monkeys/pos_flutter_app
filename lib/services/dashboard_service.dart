import 'api_service.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  // Obtener resumen completo del dashboard
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _apiService.get('/dashboard/summary/');
      return DashboardSummary.fromJson(response);
    } catch (e) {
      throw Exception('Error al cargar dashboard: $e');
    }
  }

  // Mantener el método getSummary por si lo usas en otro lugar
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _apiService.get('/dashboard/summary/');
      return response;
    } catch (e) {
      throw Exception('Error al cargar dashboard: $e');
    }
  }

  // Obtener estadísticas rápidas
  Future<Map<String, dynamic>> getQuickStats() async {
    try {
      final response = await _apiService.get('/dashboard/quick-stats/');
      return response;
    } catch (e) {
      throw Exception('Error al cargar estadísticas: $e');
    }
  }

  // Obtener datos para gráficos
  Future<Map<String, dynamic>> getSalesChart({String period = 'day'}) async {
    try {
      final response = await _apiService.get(
        '/dashboard/sales-chart/',
        queryParams: {'period': period},
      );
      return response;
    } catch (e) {
      throw Exception('Error al cargar gráfico de ventas: $e');
    }
  }
}