import '../services/api_service.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  /// Obtener lista de productos como List<Product>
  /// Los empleados verán productos de su manager automáticamente
  Future<List<Product>> getProducts({String? search}) async {
    try {
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get('/products/', queryParams: queryParams);
      
      // El backend puede retornar con paginación o directo
      if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      } else if (response is Map && response['results'] is List) {
        return (response['results'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
      
      throw Exception('Formato de respuesta inválido');
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  /// Obtener producto por ID
  Future<Product> getProductById(int id) async {
    try {
      final response = await _apiService.get('/products/$id/');
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Error al cargar producto: $e');
    }
  }

  /// Escanear código QR o barras
  /// Retorna el producto escaneado
  Future<Product> scanProduct(String code, {String codeType = 'qr'}) async {
    try {
      final response = await _apiService.post(
        '/products/scan/',
        body: {
          'code': code,
          'code_type': codeType,
        },
      );

      if (response['success'] == true) {
        return Product.fromJson(response['product']);
      }

      throw Exception(response['error'] ?? 'Error al escanear producto');
    } catch (e) {
      throw Exception('Error al escanear producto: $e');
    }
  }

  /// Escanear (formato Map completo)
  Future<Map<String, dynamic>> scanProductRaw(String code, String codeType) async {
    try {
      final response = await _apiService.post(
        '/products/scan/',
        body: {
          'code': code,
          'code_type': codeType,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Error al escanear producto: $e');
    }
  }

  /// Listar productos (formato Map con paginación)
  Future<Map<String, dynamic>> getAll({
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get('/products/', queryParams: queryParams);
      return response;
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  /// Búsqueda rápida
  /// Retorna lista de productos que coinciden con la búsqueda
  Future<List<Product>> quickSearch(String query) async {
    try {
      final response = await _apiService.get(
        '/products/quick-search/',
        queryParams: {'q': query},
      );

      if (response['success'] == true && response['products'] is List) {
        return (response['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error en búsqueda: $e');
    }
  }

  /// Búsqueda rápida (formato Map completo)
  Future<Map<String, dynamic>> quickSearchRaw(String query) async {
    try {
      final response = await _apiService.get(
        '/products/quick-search/',
        queryParams: {'q': query},
      );
      return response;
    } catch (e) {
      throw Exception('Error en búsqueda: $e');
    }
  }

  /// Validar productos antes de crear venta
  Future<Map<String, dynamic>> validateProducts(List<Map<String, dynamic>> items) async {
    try {
      final response = await _apiService.post(
        '/products/validate-products/',
        body: {'items': items},
      );
      return response;
    } catch (e) {
      throw Exception('Error al validar productos: $e');
    }
  }

  /// Obtener productos con stock bajo
  Future<List<Product>> getLowStockProducts() async {
    try {
      final response = await _apiService.get(
        '/products/',
        queryParams: {'low_stock': 'true'},
      );

      if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      } else if (response is Map && response['results'] is List) {
        return (response['results'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener productos con stock bajo: $e');
    }
  }
}