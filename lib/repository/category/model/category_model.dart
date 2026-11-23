class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final bool isActive;
  final String icon;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.isActive,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      userId: json['userId'],
      name: json['name'],
      isActive: json['isActive'],
      icon: json['icon'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'isActive': isActive,
      'icon': icon,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CategoryResponse {
  final bool success;
  final CategoryModel? data;
  final String message;

  CategoryResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'],
      data: json['data'] != null ? CategoryModel.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class CategoryListResponse {
  final bool success;
  final List<CategoryModel> data;
  final String? message;

  CategoryListResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList(),
      message: json['message'],
    );
  }
}
