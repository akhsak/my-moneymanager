class SubTransaction {
  final String id;
  final String name;
  final double amount;
  final String date;
  final String time;
  final String description;

  SubTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.time,
    required this.description,
  });

  factory SubTransaction.fromJson(Map<String, dynamic> json) {
    return SubTransaction(
      id: json['_id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      date: json['date'],
      time: json['time'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'amount': amount,
      'date': date,
      'time': time,
      'description': description,
    };
  }
}

class Transaction {
  final String id;
  final String categoryId;
  final String month;
  final int year;
  final String time;
  final String date;
  final String frequency;
  final double amount;
  final String currency;
  final List<SubTransaction> subTransactions;
  final String userId;
  final String createdAt;
  final String updatedAt;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.time,
    required this.date,
    required this.frequency,
    required this.amount,
    required this.currency,
    required this.subTransactions,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      categoryId: json['categoryId'],
      month: json['month'],
      year: json['year'],
      time: json['time'],
      date: json['date'],
      frequency: json['frequency'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      subTransactions: (json['subTransactions'] as List)
          .map((item) => SubTransaction.fromJson(item))
          .toList(),
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryId': categoryId,
      'month': month,
      'year': year,
      'time': time,
      'date': date,
      'frequency': frequency,
      'amount': amount,
      'currency': currency,
      'subTransactions': subTransactions.map((item) => item.toJson()).toList(),
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class TransactionResponse {
  final bool success;
  final Transaction data;
  final String message;

  TransactionResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'],
      data: Transaction.fromJson(json['data']),
      message: json['message'],
    );
  }
}

// New model for the all sub-transactions API response
class AllSubTransactionsResponse {
  final bool success;
  final List<SubTransactionWithCategory> subTransactions;
  final int totalSubTransactions;
  final int page;
  final int limit;
  final int totalPages;
  final String year;

  AllSubTransactionsResponse({
    required this.success,
    required this.subTransactions,
    required this.totalSubTransactions,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.year,
  });

  factory AllSubTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return AllSubTransactionsResponse(
      success: json['success'],
      subTransactions: (json['data']['subTransactions'] as List)
          .map((item) => SubTransactionWithCategory.fromJson(item))
          .toList(),
      totalSubTransactions: json['data']['totalSubTransactions'],
      page: json['data']['page'],
      limit: json['data']['limit'],
      totalPages: json['data']['totalPages'],
      year: json['data']['year'],
    );
  }
}

// Enhanced SubTransaction with category information
class SubTransactionWithCategory {
  final String id;
  final String name;
  final double amount;
  final String date;
  final String time;
  final String description;
  final String categoryName;
  final String categoryId;
  final String categoryIcon;
  final String parentTransactionId;
  final String parentMonth;
  final int parentYear;
  final double parentAmount;
  final String parentCurrency;
  final String parentFrequency;

  SubTransactionWithCategory({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.time,
    required this.description,
    required this.categoryName,
    required this.categoryId,
    required this.categoryIcon,
    required this.parentTransactionId,
    required this.parentMonth,
    required this.parentYear,
    required this.parentAmount,
    required this.parentCurrency,
    required this.parentFrequency,
  });

  factory SubTransactionWithCategory.fromJson(Map<String, dynamic> json) {
    return SubTransactionWithCategory(
      id: json['_id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      date: json['date'],
      time: json['time'],
      description: json['description'] ?? '',
      categoryName: json['categoryName'],
      categoryId: json['categoryId'],
      categoryIcon: json['categoryIcon'] ?? '',
      parentTransactionId: json['parentTransactionId'],
      parentMonth: json['parentMonth'],
      parentYear: json['parentYear'],
      parentAmount: (json['parentAmount'] as num).toDouble(),
      parentCurrency: json['parentCurrency'],
      parentFrequency: json['parentFrequency'],
    );
  }

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;
}

class CategoryTransactionResponse {
  final bool success;
  final Map<String, dynamic> category;
  final List<Transaction> transactions;

  CategoryTransactionResponse({
    required this.success,
    required this.category,
    required this.transactions,
  });

  factory CategoryTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CategoryTransactionResponse(
      success: json['success'],
      category: json['data']['category'],
      transactions: (json['data']['transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList(),
    );
  }
}
