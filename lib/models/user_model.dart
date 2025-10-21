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

class Role {
  final int id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => 'Role(id: $id, name: $name)';
}

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isSuperuser;
  final Role? role;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.isStaff = false,
    this.isSuperuser = false,
    this.role,
  });

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) {
      return username;
    }
    return '$firstName $lastName'.trim();
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (username.length >= 2) {
      return username.substring(0, 2).toUpperCase();
    }
    return username[0].toUpperCase();
  }

  bool get isAdmin => role?.name == 'admin';
  bool get isEmployee => role?.name == 'empleado';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      isStaff: _parseBool(json['is_staff']),
      isSuperuser: _parseBool(json['is_superuser']),
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'role': role?.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isStaff,
    bool? isSuperuser,
    Role? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      role: role ?? this.role,
    );
  }

  @override
  String toString() => 'User(id: $id, username: $username, role: ${role?.name})';
}

class UserBasic {
  final int id;
  final String username;

  UserBasic({
    required this.id,
    required this.username,
  });

  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
      };

  @override
  String toString() => 'UserBasic(id: $id, username: $username)';
}
