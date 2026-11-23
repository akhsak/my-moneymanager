import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/repository/reminder/model/reminder_model.dart';

import 'package:monaymanagment/repository/reminder/service/reminder_service.dart';

class NotificationController extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();

  List<NotificationGroup> _notificationGroups = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  List<NotificationGroup> get notificationGroups => _notificationGroups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  // Load initial notifications
  Future<void> loadNotifications() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();

    try {
      final response = await _reminderService.getReminders(
        page: _currentPage,
        limit: 8,
      );
      _notificationGroups = _groupNotificationsByDate(response.reminders);
      _hasMoreData = response.pagination.page < response.pagination.pages;

      print('Loaded ${response.reminders.length} notifications');
    } catch (e) {
      print('Error loading notifications: $e');
      _errorMessage = e.toString();
      // Keep existing data if available
      if (_notificationGroups.isEmpty) {
        _notificationGroups = _getDefaultNotifications();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _reminderService.getReminders(
        page: _currentPage + 1,
        limit: 8,
      );
      final newGroups = _groupNotificationsByDate(response.reminders);
      _mergeNotificationGroups(newGroups);

      _currentPage++;
      _hasMoreData = response.pagination.page < response.pagination.pages;

      print('Loaded ${response.reminders.length} more notifications');
    } catch (e) {
      print('Error loading more notifications: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    _notificationGroups.clear();
    await loadNotifications();
  }

  // Group notifications by date (Today, Yesterday, etc.)
  List<NotificationGroup> _groupNotificationsByDate(List<Reminder> reminders) {
    final Map<String, List<NotificationItem>> groupedNotifications = {};

    for (final reminder in reminders) {
      final notificationItem = _convertReminderToNotificationItem(reminder);
      final dateKey = _getDateKey(reminder.date);

      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }
      groupedNotifications[dateKey]!.add(notificationItem);
    }

    // Convert to NotificationGroup list
    final List<NotificationGroup> groups = [];
    final sortedKeys = groupedNotifications.keys.toList()
      ..sort((a, b) => _getDateSortOrder(a).compareTo(_getDateSortOrder(b)));

    for (final key in sortedKeys) {
      groups.add(
        NotificationGroup(
          title: key,
          notifications: groupedNotifications[key]!,
        ),
      );
    }

    return groups;
  }

  // Convert Reminder to NotificationItem
  NotificationItem _convertReminderToNotificationItem(Reminder reminder) {
    IconData icon;
    String title;
    Color iconColor = const Color(0xFF2F3F87);

    // Determine icon and title based on reminder type
    if (reminder.type == 'my target') {
      icon = Icons.flag;
      title = 'Target Added';
      iconColor = const Color(0xFF9C27B0); // Purple for targets
    } else if (reminder.type == 'reminder') {
      icon = Icons.schedule;
      title = 'Reminder';
      iconColor = const Color(0xFFFF9800); // Orange for custom reminders
    } else if (reminder.reminder.toLowerCase().contains('income')) {
      icon = Icons.trending_up;
      title = 'Income Added';
      iconColor = const Color(0xFF4CAF50); // Green for income
    } else if (reminder.reminder.toLowerCase().contains('expense')) {
      icon = Icons.trending_down;
      title = 'Expense Added';
      iconColor = const Color(0xFFF44336); // Red for expense
    } else if (reminder.type == 'transaction update') {
      icon = Icons.attach_money;
      title = 'Transaction Update';
      iconColor = const Color(0xFF2196F3); // Blue for transaction
    } else {
      icon = MyFlutterApp.vector__8_;
      title = 'Notification';
      iconColor = const Color(0xFF2F3F87); // Default color
    }

    return NotificationItem(
      icon: icon,
      title: title,
      description: reminder.reminder,
      timestamp: '${reminder.time} - ${_formatDate(reminder.date)}',
      iconColor: iconColor,
      isRead: false,
    );
  }

  // Get date key for grouping (Today, Yesterday, etc.)
  String _getDateKey(String dateString) {
    final date = _parseDateString(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return 'This Week';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Parse different date formats from API
  DateTime _parseDateString(String dateString) {
    try {
      // Handle "October 8, 2025" format
      if (dateString.contains(',')) {
        final months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];

        final parts = dateString.split(' ');
        if (parts.length >= 3) {
          final monthName = parts[0];
          final day = int.parse(parts[1].replaceAll(',', ''));
          final year = int.parse(parts[2]);
          final monthIndex = months.indexOf(monthName) + 1;

          return DateTime(year, monthIndex, day);
        }
      }

      // Handle "2025-10-08" format
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      return DateTime.now(); // Fallback to current date
    }
  }

  // Get date sort order for proper grouping
  int _getDateSortOrder(String dateKey) {
    switch (dateKey) {
      case 'Today':
        return 0;
      case 'Yesterday':
        return 1;
      case 'This Week':
        return 2;
      default:
        return 3;
    }
  }

  // Merge new notification groups with existing ones
  void _mergeNotificationGroups(List<NotificationGroup> newGroups) {
    for (final newGroup in newGroups) {
      final existingIndex = _notificationGroups.indexWhere(
        (group) => group.title == newGroup.title,
      );

      if (existingIndex != -1) {
        // Merge with existing group
        _notificationGroups[existingIndex] = NotificationGroup(
          title: newGroup.title,
          notifications: [
            ..._notificationGroups[existingIndex].notifications,
            ...newGroup.notifications,
          ],
        );
      } else {
        // Add new group
        _notificationGroups.add(newGroup);
      }
    }

    // Sort groups again
    _notificationGroups.sort(
      (a, b) =>
          _getDateSortOrder(a.title).compareTo(_getDateSortOrder(b.title)),
    );
  }

  // Format date for display
  String _formatDate(String dateString) {
    final date = _parseDateString(dateString);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  // Get default notifications when API fails
  List<NotificationGroup> _getDefaultNotifications() {
    return [
      NotificationGroup(
        title: 'Today',
        notifications: [
          NotificationItem(
            icon: MyFlutterApp.vector__8_,
            title: 'Welcome!',
            description: 'Your notifications will appear here when available.',
            timestamp: 'Now',
            iconColor: const Color(0xFF2F3F87),
          ),
        ],
      ),
    ];
  }

  // Mark notification as read
  void markAsRead(int groupIndex, int notificationIndex) {
    if (groupIndex < _notificationGroups.length &&
        notificationIndex <
            _notificationGroups[groupIndex].notifications.length) {
      _notificationGroups[groupIndex].notifications[notificationIndex].isRead =
          true;
      notifyListeners();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (var group in _notificationGroups) {
      for (var notification in group.notifications) {
        notification.isRead = true;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class NotificationGroup {
  final String title;
  final List<NotificationItem> notifications;

  NotificationGroup({required this.title, required this.notifications});
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String description;
  final String timestamp;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconColor,
    this.isRead = false,
  });
}
