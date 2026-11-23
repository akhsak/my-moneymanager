import 'package:flutter/material.dart';

class PinChangeController extends ChangeNotifier {
  final TextEditingController currentPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  void toggleCurrent() {
    showCurrent = !showCurrent;
    notifyListeners();
  }

  void toggleNew() {
    showNew = !showNew;
    notifyListeners();
  }

  void toggleConfirm() {
    showConfirm = !showConfirm;
    notifyListeners();
  }

  void submitChange() {
    // Add validation as needed
  }

  @override
  void dispose() {
    currentPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }
}
