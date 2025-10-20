import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  // Obtener resumen completo del dashboard
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
}