class Target {
  final String id;
  final String userId;
  final String categoryId;
  final String category;
  final double amount;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  Target({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.category,
    required this.amount,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      id: json['_id'],
      userId: json['userId'],
      categoryId: json['categoryId'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      progress: (json['progress'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'categoryId': categoryId,
      'category': category,
      'amount': amount,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  double get progressPercentage => progress;
  double get savedAmount => (amount * progress / 100);
  double get remainingAmount => amount - savedAmount;
  String get name => category;

  // For UI compatibility with existing Target model
  String? get imageAsset => null;
}

class TargetResponse {
  final String message;
  final Target target;

  TargetResponse({
    required this.message,
    required this.target,
  });

  factory TargetResponse.fromJson(Map<String, dynamic> json) {
    return TargetResponse(
      message: json['message'],
      target: Target.fromJson(json['target']),
    );
  }
}

class TargetListResponse {
  final List<Target> targets;

  TargetListResponse({
    required this.targets,
  });

  factory TargetListResponse.fromJson(List<dynamic> json) {
    return TargetListResponse(
      targets: json.map((item) => Target.fromJson(item)).toList(),
    );
  }
}