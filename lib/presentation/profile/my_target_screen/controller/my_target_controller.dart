import 'package:flutter/material.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';

import 'package:monaymanagment/presentation/profile/add_target_screen/view/add_target_screen.dart';
import 'package:monaymanagment/presentation/profile/edit_goal_screen/view/edit_goal_screen.dart';
import 'package:monaymanagment/repository/reminder/service/reminder_service.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';
import 'package:monaymanagment/repository/target/service/target_service.dart';

class MyTargetController extends ChangeNotifier {
  final TargetService _targetService = TargetService();
  final ReminderService _reminderService = ReminderService();
  final GuestStorageService _guestService = GuestStorageService.instance;
  
  List<Target> _targets = [];
  String? _expandedTargetId;
  bool _isLoading = false;
  String? _errorMessage;

  List<Target> get targets => _targets;
  String? get expandedTargetId => _expandedTargetId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MyTargetController() {
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    _setLoading(true);
    _setErrorMessage(null);
    
    try {
      final response = await _targetService.getTargets();
      _targets = response.targets;
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load targets: $e');
      print('Error loading targets: $e');
    } finally {
      _setLoading(false);
    }
  }

  void toggleTargetExpansion(String targetId) {
    if (_expandedTargetId == targetId) {
      _expandedTargetId = null;
    } else {
      _expandedTargetId = targetId;
    }
    notifyListeners();
  }

  void navigateToAddTarget(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTargetScreen()),
    );
    
    if (result == true) {
      // Refresh targets after adding
      await _loadTargets();
    }
  }

  void navigateToEditGoal(BuildContext context, Target target) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGoalScreen(target: target)),
    );
    
    if (result == true) {
      // Refresh targets after editing
      await _loadTargets();
    }
  }

  Future<bool> addTarget({
    required String categoryId,
    required String category,
    required double amount,
  }) async {
    try {
      // Create the target first
      await _targetService.createTarget(
        categoryId: categoryId,
        category: category,
        amount: amount,
      );
      
      if (!_guestService.isGuestMode) {
        // Create a reminder notification for the new target
        try {
          final now = DateTime.now();
          await _reminderService.createReminder(
            reminder: 'My Target added: $category - ₹${amount.toStringAsFixed(0)}',
            date: _formatDateForAPI(now),
            time: _formatTimeForAPI(now),
            type: 'my target',
          );
          print('Reminder created for new target: $category');
        } catch (reminderError) {
          print('Failed to create reminder for target: $reminderError');
          // Don't fail the entire operation if reminder creation fails
        }
      }
      
      // Refresh targets list
      await _loadTargets();
      return true;
    } catch (e) {
      _setErrorMessage('Failed to add target: $e');
      return false;
    }
  }

  Future<bool> updateTargetProgress({
    required String categoryId,
    required String categoryName,
    required double progress,
  }) async {
    try {
      await _targetService.updateTargetProgress(
        categoryId: categoryId,
        categoryName: categoryName,
        progress: progress,
      );
      
      // Refresh targets list
      await _loadTargets();
      return true;
    } catch (e) {
      _setErrorMessage('Failed to update target: $e');
      return false;
    }
  }

  Future<bool> removeTarget(String targetId) async {
    try {
      final success = await _targetService.deleteTarget(targetId);
      if (success) {
        if (_expandedTargetId == targetId) {
          _expandedTargetId = null;
        }
        // Refresh targets list
        await _loadTargets();
      }
      return success;
    } catch (e) {
      _setErrorMessage('Failed to delete target: $e');
      return false;
    }
  }

  Future<void> refreshTargets() async {
    await _loadTargets();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    _setErrorMessage(null);
  }

  // Helper methods for date/time formatting
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeForAPI(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}
