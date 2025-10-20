class User {
  final int id;
  final String username;
  final String email;
  final UserRole role;
  final Manager? manager;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.manager,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: UserRole.fromJson(json['role']),
      manager: json['manager'] != null ? Manager.fromJson(json['manager']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.toJson(),
      'manager': manager?.toJson(),
    };
  }
}

class UserRole {
  final int id;
  final String name;

  UserRole({required this.id, required this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}