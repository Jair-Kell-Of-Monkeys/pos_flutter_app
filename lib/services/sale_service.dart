import '../services/api_service.dart';
import '../models/sale_model.dart';

class SaleService {
  final ApiService _apiService = ApiService();

  /// Crear venta desde productos escaneados
  /// items: [{"product_id": 15, "quantity": 2}, ...]
  Future<Sale> createFromScan({
    required List<Map<String, dynamic>> items,
    String paymentMethod = 'efectivo',
    String? notes,
  }) async {
    try {
      final body = {
        'items': items,
        'payment_method': paymentMethod,
      };
      
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      print('🔍 Creating sale with body: $body');

      final response = await _apiService.post(
        '/sales/create-from-scan/',
        body: body,
      );

      print('✅ Sale creation response: $response');

      if (response['success'] == true) {
        return Sale.fromJson(response['sale']);
      }

      throw Exception(response['error'] ?? 'Error al crear venta');
    } catch (e) {
      print('❌ Error creating sale: $e');
      throw Exception('Error al crear venta: $e');
    }
  }

  /// Obtener mis ventas como List<Sale> (para el screen)
  Future<List<Sale>> getMySalesList({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      print('🔍 Fetching sales with params: $queryParams');

      final response = await _apiService.get(
        '/sales/my-sales/',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      print('📦 Sales response type: ${response.runtimeType}');
      print('📦 Sales response: $response');

      // Manejar respuesta paginada
      if (response is Map<String, dynamic>) {
        if (response.containsKey('results')) {
          final results = response['results'];
          print('📋 Results found: ${results.runtimeType}');
          
          if (results is List) {
            return results.map((json) {
              if (json is Map<String, dynamic>) {
                return Sale.fromJson(json);
              } else if (json is Map) {
                return Sale.fromJson(Map<String, dynamic>.from(json));
              } else {
                throw Exception('Invalid sale item type: ${json.runtimeType}');
              }
            }).toList();
          }
        } else if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) {
            return data.map((json) {
              if (json is Map<String, dynamic>) {
                return Sale.fromJson(json);
              } else if (json is Map) {
                return Sale.fromJson(Map<String, dynamic>.from(json));
              } else {
                throw Exception('Invalid sale item type: ${json.runtimeType}');
              }
            }).toList();
          }
        }
      } 
      // Manejar lista directa
      else if (response is List) {
        print('📋 Response is direct list with ${response.length} items');
        if (response.isEmpty) {
          return [];
        }
        
        print('First item type: ${response.first.runtimeType}');
        print('First item: ${response.first}');
        
        return response.map((json) {
          if (json is Map<String, dynamic>) {
            return Sale.fromJson(json);
          } else if (json is Map) {
            return Sale.fromJson(Map<String, dynamic>.from(json));
          } else {
            throw Exception('Invalid sale item type: ${json.runtimeType}');
          }
        }).toList();
      }

      print('⚠️ Unexpected response format');
      throw Exception('Formato de respuesta inválido');
    } catch (e, stackTrace) {
      print('❌ Error fetching sales: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al obtener historial de ventas: $e');
    }
  }

  /// Obtener mis ventas (historial del usuario actual) - Formato completo
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
      
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        return {'results': response};
      }
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
      
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        return {'results': response};
      }
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  /// Obtener detalles de una venta específica
  Future<Sale> getById(int saleId) async {
    try {
      final response = await _apiService.get('/sales/$saleId/');
      
      if (response is Map<String, dynamic>) {
        return Sale.fromJson(response);
      } else if (response is Map) {
        return Sale.fromJson(Map<String, dynamic>.from(response));
      }
      
      throw Exception('Formato de respuesta inválido');
    } catch (e) {
      throw Exception('Error al obtener venta: $e');
    }
  }

  /// Obtener detalles de una venta específica (formato Map)
  Future<Map<String, dynamic>> getByIdRaw(int saleId) async {
    try {
      final response = await _apiService.get('/sales/$saleId/');
      
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      
      throw Exception('Formato de respuesta inválido');
    } catch (e) {
      throw Exception('Error al obtener venta: $e');
    }
  }

  /// Cancelar una venta (solo admin)
  Future<Map<String, dynamic>> cancelSale(int saleId) async {
    try {
      final response = await _apiService.post('/sales/$saleId/cancel/');
      
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      
      return {'success': true};
    } catch (e) {
      throw Exception('Error al cancelar venta: $e');
    }
  }

  /// Obtener resumen de ventas
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _apiService.get('/sales/summary/');
      
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      
      throw Exception('Formato de respuesta inválido');
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
      
      if (response is List) {
        return response;
      } else if (response is Map && response['results'] is List) {
        return response['results'] as List;
      }
      
      return [];
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
      
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      
      return {'results': []};
    } catch (e) {
      throw Exception('Error al obtener ventas del usuario: $e');
    }
  }

  /// Validar productos antes de crear venta
  Future<Map<String, dynamic>> validateProducts(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await _apiService.post(
        '/products/validate-products/',
        body: {'items': items},
      );
      
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      
      return {'success': false, 'error': 'Formato de respuesta inválido'};
    } catch (e) {
      throw Exception('Error al validar productos: $e');
    }
  }
}