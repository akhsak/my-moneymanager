import 'package:hive/hive.dart';

part 'guest_transaction.g.dart';

@HiveType(typeId: 2)
class GuestSubTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime timestamp;

  GuestSubTransaction({
    required this.id,
    required this.name,
    required this.amount,
    this.description = '',
    required this.timestamp,
  });

  GuestSubTransaction copyWith({
    String? id,
    String? name,
    double? amount,
    String? description,
    DateTime? timestamp,
  }) {
    return GuestSubTransaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

@HiveType(typeId: 3)
enum GuestTransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  loan,
}

@HiveType(typeId: 4)
class GuestTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String categoryName;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final String currency;

  @HiveField(6)
  final String frequency;

  @HiveField(7)
  final GuestTransactionType type;

  @HiveField(8)
  final List<GuestSubTransaction> subTransactions;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  GuestTransaction({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.amount,
    this.currency = 'INR',
    this.frequency = 'Daily',
    required this.type,
    required this.subTransactions,
    required this.createdAt,
    required this.updatedAt,
  });

  GuestTransaction copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    String? title,
    double? amount,
    String? currency,
    String? frequency,
    GuestTransactionType? type,
    List<GuestSubTransaction>? subTransactions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuestTransaction(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      type: type ?? this.type,
      subTransactions: subTransactions ?? this.subTransactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
