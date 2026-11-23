class User {
  final String id;
  final String name;
  final String username;
  final String? phone;
  final String role;
  final String? profilePhoto;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.phone,
    required this.role,
    this.profilePhoto,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'user',
      profilePhoto: json['profilePhoto'],
      isActive: json['isActive'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'phone': phone,
      'role': role,
      'profilePhoto': profilePhoto,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? phone,
    String? role,
    String? profilePhoto,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthResponse {
  final String message;
  final String? accessToken;
  final String? redirectPath;
  final User user;

  AuthResponse({
    required this.message,
    this.accessToken,
    this.redirectPath,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      accessToken: json['accessToken'],
      redirectPath: json['redirectPath'],
      user: User.fromJson(json['user']),
    );
  }
}

class RegisterResponse {
  final String message;
  final User user;

  RegisterResponse({
    required this.message,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}
