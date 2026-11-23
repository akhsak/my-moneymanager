import 'package:flutter/material.dart';

import 'package:monaymanagment/repository/reminder/model/reminder_model.dart';
import 'package:monaymanagment/repository/reminder/service/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager extends ChangeNotifier {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final ReminderService _reminderService = ReminderService();
  final Set<String> _readNotificationIds = <String>{};
  List<Reminder> _allNotifications = [];
  bool _isLoading = false;

  // Getters
  List<Reminder> get allNotifications => _allNotifications;
  int get totalCount => _allNotifications.length;
  int get unreadCount => _allNotifications.length - _readNotificationIds.length;
  bool get isLoading => _isLoading;

  // Initialize notification manager
  Future<void> initialize() async {
    await _loadReadNotificationIds();
    await loadNotifications();
  }

  // Load notifications from API
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _reminderService.getReminders(page: 1, limit: 100);
      _allNotifications = response.reminders;
    } catch (e) {
      print('Error loading notifications: $e');
      _allNotifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    _readNotificationIds.add(notificationId);
    await _saveReadNotificationIds();
    notifyListeners();
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _readNotificationIds.addAll(_allNotifications.map((n) => n.id));
    await _saveReadNotificationIds();
    notifyListeners();
  }

  // Check if notification is read
  bool isRead(String notificationId) {
    return _readNotificationIds.contains(notificationId);
  }

  // Get unread notifications
  List<Reminder> get unreadNotifications {
    return _allNotifications.where((n) => !isRead(n.id)).toList();
  }

  // Get read notifications
  List<Reminder> get readNotifications {
    return _allNotifications.where((n) => isRead(n.id)).toList();
  }

  // Add new notification (when created)
  void addNotification(Reminder notification) {
    _allNotifications.insert(0, notification); // Add to beginning
    notifyListeners();
  }

  // Remove notification (when deleted)
  void removeNotification(String notificationId) {
    _allNotifications.removeWhere((n) => n.id == notificationId);
    _readNotificationIds.remove(notificationId);
    notifyListeners();
  }

  // Load read notification IDs from SharedPreferences
  Future<void> _loadReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList('read_notification_ids') ?? [];
      _readNotificationIds.addAll(readIds);
    } catch (e) {
      print('Error loading read notification IDs: $e');
    }
  }

  // Save read notification IDs to SharedPreferences
  Future<void> _saveReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notification_ids', _readNotificationIds.toList());
    } catch (e) {
      print('Error saving read notification IDs: $e');
    }
  }

  // Clear all data (for logout, etc.)
  Future<void> clear() async {
    _readNotificationIds.clear();
    _allNotifications.clear();
    await _saveReadNotificationIds();
    notifyListeners();
  }
}
