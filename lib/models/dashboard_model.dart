import 'product_model.dart';
import 'user_model.dart';
import 'sale_model.dart';

class DashboardData {
  final UserInfo userInfo;
  final SalesData todaySales;
  final SalesData weekSales;
  final SalesData monthSales;
  final List<TopProduct> topProducts;
  final LowStockData lowStock;
  final InventorySummary inventorySummary;
  final PersonalStats personalStats;
  final List<RecentSale> recentSales;
  final Comparison comparison;
  final List<EmployeeSales>? salesByEmployee;
  final String timestamp;

  DashboardData({
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

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      userInfo: UserInfo.fromJson(json['user_info']),
      todaySales: SalesData.fromJson(json['today_sales']),
      weekSales: SalesData.fromJson(json['week_sales']),
      monthSales: SalesData.fromJson(json['month_sales']),
      topProducts: (json['top_products'] as List<dynamic>)
          .map((item) => TopProduct.fromJson(item))
          .toList(),
      lowStock: LowStockData.fromJson(json['low_stock']),
      inventorySummary: InventorySummary.fromJson(json['inventory_summary']),
      personalStats: PersonalStats.fromJson(json['personal_stats']),
      recentSales: (json['recent_sales'] as List<dynamic>)
          .map((item) => RecentSale.fromJson(item))
          .toList(),
      comparison: Comparison.fromJson(json['comparison']),
      salesByEmployee: json['sales_by_employee'] != null
          ? (json['sales_by_employee'] as List<dynamic>)
              .map((item) => EmployeeSales.fromJson(item))
              .toList()
          : null,
      timestamp: json['timestamp'],
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
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: RoleInfo.fromJson(json['role']),
    );
  }
}

class RoleInfo {
  final String role;
  final bool canManageProducts;
  final bool canManageEmployees;
  final Manager? manager;
  final int? employeesCount;

  RoleInfo({
    required this.role,
    required this.canManageProducts,
    required this.canManageEmployees,
    this.manager,
    this.employeesCount,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      role: json['role'],
      canManageProducts: json['can_manage_products'],
      canManageEmployees: json['can_manage_employees'],
      manager: json['manager'] != null ? Manager.fromJson(json['manager']) : null,
      employeesCount: json['employees_count'],
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isEmpleado => role == 'empleado';
}

class Manager {
  final int id;
  final String username;

  Manager({required this.id, required this.username});

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'],
      username: json['username'],
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
      count: json['count'] ?? 0,
      total: _parseDouble(json['total']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      productId: json['product_id'],
      productName: json['product_name'],
      productCode: json['product_code'],
      quantitySold: json['quantity_sold'],
      totalAmount: _parseDouble(json['total_amount']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class LowStockData {
  final int count;
  final List<LowStockProduct> products;

  LowStockData({
    required this.count,
    required this.products,
  });

  factory LowStockData.fromJson(Map<String, dynamic> json) {
    return LowStockData(
      count: json['count'] ?? 0,
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => LowStockProduct.fromJson(item))
              .toList() ??
          [],
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
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      stock: json['stock'],
      category: json['category'] ?? 'Sin categoría',
      status: json['status'],
      price: _parseDouble(json['price']),
    );
  }

  bool get isCritical => status == 'critical';

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      totalProducts: json['total_products'] ?? 0,
      lowStockCount: json['low_stock_count'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      salesLast30Days: json['sales_last_30_days'] ?? 0,
      totalLast30Days: _parseDouble(json['total_last_30_days']),
      averageSale: _parseDouble(json['average_sale']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class RecentSale {
  final int id;
  final String date;
  final double totalPrice;
  final SimpleUser user;
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
      id: json['id'],
      date: json['date'],
      totalPrice: _parseDouble(json['total_price']),
      user: SimpleUser.fromJson(json['user']),
      itemsCount: json['items_count'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class SimpleUser {
  final int id;
  final String username;

  SimpleUser({required this.id, required this.username});

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'],
      username: json['username'],
    );
  }
}

class Comparison {
  final double currentMonthTotal;
  final double previousMonthTotal;
  final double percentageChange;
  final String trend;

  Comparison({
    required this.currentMonthTotal,
    required this.previousMonthTotal,
    required this.percentageChange,
    required this.trend,
  });

  factory Comparison.fromJson(Map<String, dynamic> json) {
    return Comparison(
      currentMonthTotal: _parseDouble(json['current_month_total']),
      previousMonthTotal: _parseDouble(json['previous_month_total']),
      percentageChange: _parseDouble(json['percentage_change']),
      trend: json['trend'],
    );
  }

  bool get isPositive => trend == 'up';
  bool get isNegative => trend == 'down';
  bool get isStable => trend == 'stable';

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class EmployeeSales {
  final int employeeId;
  final String employeeName;
  final String? employeeEmail;
  final SalesData today;
  final SalesData month;

  EmployeeSales({
    required this.employeeId,
    required this.employeeName,
    this.employeeEmail,
    required this.today,
    required this.month,
  });

  factory EmployeeSales.fromJson(Map<String, dynamic> json) {
    return EmployeeSales(
      employeeId: json['employee_id'],
      employeeName: json['employee_name'],
      employeeEmail: json['employee_email'],
      today: SalesData.fromJson(json['today']),
      month: SalesData.fromJson(json['month']),
    );
  }
}