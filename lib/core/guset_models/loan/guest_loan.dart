import 'package:hive/hive.dart';
part 'guest_loan.g.dart';

@HiveType(typeId: 5)
class GuestLoanPayment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String note;

  GuestLoanPayment({
    required this.id,
    required this.amount,
    required this.date,
    this.note = '',
  });

  GuestLoanPayment copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return GuestLoanPayment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}

@HiveType(typeId: 6)
class GuestLoan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double principal;

  @HiveField(3)
  final double remainingAmount;

  @HiveField(4)
  final DateTime deadline;

  @HiveField(5)
  final String note;

  @HiveField(6)
  final String categoryId;

  @HiveField(7)
  final List<GuestLoanPayment> payments;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  GuestLoan({
    required this.id,
    required this.name,
    required this.principal,
    required this.remainingAmount,
    required this.deadline,
    this.note = '',
    required this.categoryId,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });

  double get amountPaid => payments.fold(
        0.0,
        (sum, payment) => sum + payment.amount,
      );

  GuestLoan copyWith({
    String? id,
    String? name,
    double? principal,
    double? remainingAmount,
    DateTime? deadline,
    String? note,
    String? categoryId,
    List<GuestLoanPayment>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuestLoan(
      id: id ?? this.id,
      name: name ?? this.name,
      principal: principal ?? this.principal,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': 'guest',
      'name': name,
      'principal': principal,
      'interest': 0.0,
      'interestRate': 0.0,
      'deadline': deadline.toIso8601String(),
      'note': note,
      'categoryId': categoryId,
      'payments': payments.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

