import 'package:hive/hive.dart';

part 'guest_category.g.dart';

@HiveType(typeId: 1)
class GuestCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  GuestCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  GuestCategory copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuestCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
