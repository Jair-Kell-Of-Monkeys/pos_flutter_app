import './user_model.dart';
/// Parse seguro de enteros desde cualquier tipo
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return int.tryParse(value.toString()) ?? 0;
}

/// Parse seguro de doubles desde cualquier tipo
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}

/// Parse seguro de booleanos
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return false;
}

class DashboardSummary {
  final UserInfo userInfo;
  final SalesData todaySales;
  final SalesData weekSales;
  final SalesData monthSales;
  final List<TopProduct> topProducts;
  final LowStockInfo lowStock;
  final InventorySummary inventorySummary;
  final PersonalStats personalStats;
  final List<RecentSale> recentSales;
  final ComparisonData comparison;
  final List<EmployeeSales>? salesByEmployee;
  final DateTime timestamp;

  DashboardSummary({
    required this.userInfo,
    required this.todaySales,
    required this.weekSales,
    required this.monthSales,
    required this.topProducts,
    required this.lowStock,
    required this.inventorySummary,
    required this.personalStats,
    required this.recentSales,
    required this.comparison,
    this.salesByEmployee,
    required this.timestamp,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      userInfo: UserInfo.fromJson(json['user_info'] ?? {}),
      todaySales: SalesData.fromJson(json['today_sales'] ?? {}),
      weekSales: SalesData.fromJson(json['week_sales'] ?? {}),
      monthSales: SalesData.fromJson(json['month_sales'] ?? {}),
      topProducts: (json['top_products'] as List<dynamic>? ?? [])
          .map((item) => TopProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      lowStock: LowStockInfo.fromJson(json['low_stock'] ?? {}),
      inventorySummary: InventorySummary.fromJson(json['inventory_summary'] ?? {}),
      personalStats: PersonalStats.fromJson(json['personal_stats'] ?? {}),
      recentSales: (json['recent_sales'] as List<dynamic>? ?? [])
          .map((item) => RecentSale.fromJson(item as Map<String, dynamic>))
          .toList(),
      comparison: ComparisonData.fromJson(json['comparison'] ?? {}),
      salesByEmployee: json['sales_by_employee'] != null
          ? (json['sales_by_employee'] as List<dynamic>)
              .map((item) => EmployeeSales.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class UserInfo {
  final int id;
  final String username;
  final String email;
  final RoleInfo role;

  UserInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: RoleInfo.fromJson(json['role'] ?? {}),
    );
  }
}

class RoleInfo {
  final String role;
  final bool canManageProducts;
  final bool canManageEmployees;
  final int? employeesCount;

  RoleInfo({
    required this.role,
    required this.canManageProducts,
    required this.canManageEmployees,
    this.employeesCount,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      role: json['role']?.toString() ?? '',
      canManageProducts: _parseBool(json['can_manage_products']),
      canManageEmployees: _parseBool(json['can_manage_employees']),
      employeesCount: json['employees_count'] != null ? _parseInt(json['employees_count']) : null,
    );
  }
}

class SalesData {
  final int count;
  final double total;

  SalesData({
    required this.count,
    required this.total,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      count: _parseInt(json['count']),
      total: _parseDouble(json['total']),
    );
  }
}

class TopProduct {
  final int productId;
  final String productName;
  final String productCode;
  final int quantitySold;
  final double totalAmount;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantitySold,
    required this.totalAmount,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: _parseInt(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      productCode: json['product_code']?.toString() ?? '',
      quantitySold: _parseInt(json['quantity_sold']),
      totalAmount: _parseDouble(json['total_amount']),
    );
  }
}

class LowStockInfo {
  final int count;
  final List<LowStockProduct> products;

  LowStockInfo({
    required this.count,
    required this.products,
  });

  factory LowStockInfo.fromJson(Map<String, dynamic> json) {
    return LowStockInfo(
      count: _parseInt(json['count']),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((item) => LowStockProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LowStockProduct {
  final int id;
  final String name;
  final String code;
  final int stock;
  final String category;
  final String status;
  final double price;

  LowStockProduct({
    required this.id,
    required this.name,
    required this.code,
    required this.stock,
    required this.category,
    required this.status,
    required this.price,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      stock: _parseInt(json['stock']),
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      price: _parseDouble(json['price']),
    );
  }
}

class InventorySummary {
  final double totalValue;
  final int totalProducts;
  final int lowStockCount;

  InventorySummary({
    required this.totalValue,
    required this.totalProducts,
    required this.lowStockCount,
  });

  factory InventorySummary.fromJson(Map<String, dynamic> json) {
    return InventorySummary(
      totalValue: _parseDouble(json['total_value']),
      totalProducts: _parseInt(json['total_products']),
      lowStockCount: _parseInt(json['low_stock_count']),
    );
  }
}

class PersonalStats {
  final int salesLast30Days;
  final double totalLast30Days;
  final double averageSale;

  PersonalStats({
    required this.salesLast30Days,
    required this.totalLast30Days,
    required this.averageSale,
  });

  factory PersonalStats.fromJson(Map<String, dynamic> json) {
    return PersonalStats(
      salesLast30Days: _parseInt(json['sales_last_30_days']),
      totalLast30Days: _parseDouble(json['total_last_30_days']),
      averageSale: _parseDouble(json['average_sale']),
    );
  }
}

class RecentSale {
  final int id;
  final DateTime date;
  final double totalPrice;
  final UserBasic user;
  final int itemsCount;

  RecentSale({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.user,
    required this.itemsCount,
  });

  factory RecentSale.fromJson(Map<String, dynamic> json) {
    return RecentSale(
      id: _parseInt(json['id']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      totalPrice: _parseDouble(json['total_price']),
      user: UserBasic.fromJson(json['user'] ?? {}),
      itemsCount: _parseInt(json['items_count']),
    );
  }
}

class ComparisonData {
  final double currentMonthTotal;
  final double previousMonthTotal;
  final double percentageChange;
  final String trend;

  ComparisonData({
    required this.currentMonthTotal,
    required this.previousMonthTotal,
    required this.percentageChange,
    required this.trend,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) {
    return ComparisonData(
      currentMonthTotal: _parseDouble(json['current_month_total']),
      previousMonthTotal: _parseDouble(json['previous_month_total']),
      percentageChange: _parseDouble(json['percentage_change']),
      trend: json['trend']?.toString() ?? 'stable',
    );
  }
}

class EmployeeSales {
  final int employeeId;
  final String employeeName;
  final String employeeEmail;
  final SalesData today;
  final SalesData month;

  EmployeeSales({
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.today,
    required this.month,
  });

  factory EmployeeSales.fromJson(Map<String, dynamic> json) {
    return EmployeeSales(
      employeeId: _parseInt(json['employee_id']),
      employeeName: json['employee_name']?.toString() ?? '',
      employeeEmail: json['employee_email']?.toString() ?? '',
      today: SalesData.fromJson(json['today'] ?? {}),
      month: SalesData.fromJson(json['month'] ?? {}),
    );
  }
}