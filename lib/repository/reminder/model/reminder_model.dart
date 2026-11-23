class Reminder {
  final String id;
  final String userId;
  final String reminder;
  final String date;
  final String time;
  final String type;
  final String createdAt;
  final String updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.reminder,
    required this.date,
    required this.time,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['_id'],
      userId: json['userId'],
      reminder: json['reminder'],
      date: json['date'],
      time: json['time'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'reminder': reminder,
      'date': date,
      'time': time,
      'type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ReminderResponse {
  final String message;
  final Reminder reminder;

  ReminderResponse({
    required this.message,
    required this.reminder,
  });

  factory ReminderResponse.fromJson(Map<String, dynamic> json) {
    return ReminderResponse(
      message: json['message'],
      reminder: Reminder.fromJson(json['reminder']),
    );
  }
}

class ReminderListResponse {
  final List<Reminder> reminders;
  final Pagination pagination;

  ReminderListResponse({
    required this.reminders,
    required this.pagination,
  });

  factory ReminderListResponse.fromJson(Map<String, dynamic> json) {
    return ReminderListResponse(
      reminders: (json['reminders'] as List)
          .map((item) => Reminder.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int pages;
  final int limit;
  final Map<String, dynamic> filter;

  Pagination({
    required this.total,
    required this.page,
    required this.pages,
    required this.limit,
    required this.filter,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
      limit: json['limit'],
      filter: json['filter'] ?? {},
    );
  }
}
