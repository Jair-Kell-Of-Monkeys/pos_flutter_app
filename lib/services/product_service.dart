import '../services/api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // Escanear código QR o barras
  Future<Map<String, dynamic>> scanProduct(String code, String codeType) async {
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

  // Listar productos
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

  // Búsqueda rápida
  Future<Map<String, dynamic>> quickSearch(String query) async {
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

  // Validar productos
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
}