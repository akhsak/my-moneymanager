class Loan {
  final String id;
  final String userId;
  final String name;
  final double principal;
  final double interest;
  final double interestRate;
  final String deadline;
  final String note;
  final String categoryId;
  final List<LoanPayment> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.userId,
    required this.name,
    required this.principal,
    required this.interest,
    required this.interestRate,
    required this.deadline,
    required this.note,
    required this.categoryId,
    this.payments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  double get amountPaid => payments.fold(0.0, (sum, payment) => sum + payment.amount);
  double get balanceToPay => principal - amountPaid;
  double get totalAmount => principal;
  bool get isPaidOff => balanceToPay <= 0;

  // Copy with method for updates
  Loan copyWith({
    String? id,
    String? userId,
    String? name,
    double? principal,
    double? interest,
    double? interestRate,
    String? deadline,
    String? note,
    String? categoryId,
    List<LoanPayment>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      principal: principal ?? this.principal,
      interest: interest ?? this.interest,
      interestRate: interestRate ?? this.interestRate,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'principal': principal,
      'interest': interest,
      'interestRate': interestRate,
      'deadline': deadline,
      'note': note,
      'categoryId': categoryId,
      'payments': payments.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
      interest: (json['interest'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] ?? '',
      note: json['note'] ?? '',
      categoryId: json['categoryId'] ?? '',
      payments: (json['payments'] as List<dynamic>?)
          ?.map((p) => LoanPayment.fromJson(p))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
}

class LoanPayment {
  final String id;
  final double amount;
  final String date;
  final String note;

  LoanPayment({
    required this.id,
    required this.amount,
    required this.date,
    required this.note,
  });

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'date': date,
      'note': note,
    };
  }

  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      note: json['note'] ?? '',
    );
  }
}
