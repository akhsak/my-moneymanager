import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/reminder/model/reminder_model.dart';

import 'package:monaymanagment/repository/reminder/service/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsController extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  
  // Description text controller
  final TextEditingController descriptionController = TextEditingController();

  // Reminder settings
  bool repeat = true;
  bool vibrate = true;
  bool alarmSound = true;
  bool remindMeLater = false;

  // Remind me later options
  final List<int> remindDaysOptions = [2, 4, 6, 8, 10];
  int selectedRemindDays = 2;
  
  // Date and time selection
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  
  // API data
  List<Reminder> reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Initialize with default description
  NotificationSettingsController() {
    descriptionController.text = '';
    _loadNotificationSettings();
  }

  void toggleRepeat(bool value) {
    repeat = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  void toggleVibrate(bool value) {
    vibrate = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  void toggleAlarmSound(bool value) {
    alarmSound = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  void toggleRemindMeLater(bool value) {
    remindMeLater = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  void updateDescription(String description) {
    descriptionController.text = description;
    notifyListeners();
  }

  void onDescriptionChanged(String value) {
    notifyListeners(); // Trigger rebuild to show/hide save button
  }

  void setSelectedRemindDays(int days) {
    selectedRemindDays = days;
    _saveNotificationSettings();
    notifyListeners();
  }

  // Date and time selection methods
  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  String get formattedDate {
    if (selectedDate == null) return 'dd/mm/yyyy';
    return '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';
  }

  String get formattedTime {
    if (selectedTime == null) return '--:-- --';
    final hour = selectedTime!.hourOfPeriod;
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    final period = selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  // Getters for loading and error states
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load reminders from API
  Future<void> loadReminders() async {
    _setLoading(true);
    _setErrorMessage(null);
    
    try {
      final response = await _reminderService.getReminders(page: 1, limit: 8);
      reminders = response.reminders;
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  // Create a custom reminder
  Future<bool> createCustomReminder() async {
    if (descriptionController.text.trim().isEmpty) return false;
    if (selectedDate == null || selectedTime == null) return false;
    
    _setLoading(true);
    _setErrorMessage(null);
    
    try {
      // Create the reminder with selected date and time
      await _reminderService.createReminder(
        reminder: descriptionController.text.trim(),
        date: _formatDateForAPI(selectedDate!),
        time: _formatTimeForAPI(selectedDate!, selectedTime!),
        type: 'reminder',
        repeat: repeat,
        alarmSound: alarmSound,
        vibrate: vibrate,
        remindMeLater: remindMeLater,
      );
      
      // Reload reminders
      await loadReminders();
      
      return true;
      
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods for date/time formatting
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeForAPI(DateTime date, TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void clearErrorMessage() {
    _setErrorMessage(null);
  }

  // Save notification settings to local storage
  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_repeat', repeat);
      await prefs.setBool('notification_vibrate', vibrate);
      await prefs.setBool('notification_alarm_sound', alarmSound);
      await prefs.setBool('notification_remind_me_later', remindMeLater);
      await prefs.setInt('notification_remind_days', selectedRemindDays);
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  // Load notification settings from local storage
  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      repeat = prefs.getBool('notification_repeat') ?? true;
      vibrate = prefs.getBool('notification_vibrate') ?? true;
      alarmSound = prefs.getBool('notification_alarm_sound') ?? true;
      remindMeLater = prefs.getBool('notification_remind_me_later') ?? false;
      selectedRemindDays = prefs.getInt('notification_remind_days') ?? 2;
      notifyListeners();
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
