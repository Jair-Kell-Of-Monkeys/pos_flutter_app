import '../services/api_service.dart';

class SaleService {
  final ApiService _apiService = ApiService();

  /// Crear venta desde productos escaneados
  /// items: [{"product_id": 15, "quantity": 2}, ...]
  Future<Map<String, dynamic>> createFromScan(List<Map<String, dynamic>> items) async {
    try {
      final response = await _apiService.post(
        '/sales/create-from-scan/',
        body: {'items': items},
      );
      return response;
    } catch (e) {
      throw Exception('Error al crear venta: $e');
    }
  }

  /// Obtener mis ventas (historial del usuario actual)
  Future<Map<String, dynamic>> getMySales({
    int page = 1,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final response = await _apiService.get(
        '/sales/my-sales/',
        queryParams: queryParams,
      );
      return response;
    } catch (e) {
      throw Exception('Error al obtener historial de ventas: $e');
    }
  }

  /// Obtener todas las ventas (solo admin)
  Future<Map<String, dynamic>> getAll({
    int page = 1,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final response = await _apiService.get(
        '/sales/',
        queryParams: queryParams,
      );
      return response;
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  /// Obtener detalles de una venta específica
  Future<Map<String, dynamic>> getById(int saleId) async {
    try {
      final response = await _apiService.get('/sales/$saleId/');
      return response;
    } catch (e) {
      throw Exception('Error al obtener venta: $e');
    }
  }

  /// Cancelar una venta (solo admin)
  Future<Map<String, dynamic>> cancelSale(int saleId) async {
    try {
      final response = await _apiService.post('/sales/$saleId/cancel/');
      return response;
    } catch (e) {
      throw Exception('Error al cancelar venta: $e');
    }
  }

  /// Obtener resumen de ventas
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _apiService.get('/sales/summary/');
      return response;
    } catch (e) {
      throw Exception('Error al obtener resumen de ventas: $e');
    }
  }

  /// Obtener ventas por período
  /// period: 'day', 'week', 'month'
  Future<List<dynamic>> getByPeriod(String period) async {
    try {
      final response = await _apiService.get(
        '/sales/by_period/',
        queryParams: {'period': period},
      );
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Error al obtener ventas por período: $e');
    }
  }

  /// Obtener ventas de un usuario específico (solo admin)
  Future<Map<String, dynamic>> getByUser(
    int userId, {
    int page = 1,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final response = await _apiService.get(
        '/sales/by-user/$userId/',
        queryParams: queryParams,
      );
      return response;
    } catch (e) {
      throw Exception('Error al obtener ventas del usuario: $e');
    }
  }
}