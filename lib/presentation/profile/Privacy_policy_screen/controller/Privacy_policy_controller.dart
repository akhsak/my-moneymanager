import 'package:flutter/material.dart';

class PrivacyPolicyController extends ChangeNotifier {
  bool accepted = false;

  void toggleAccepted(bool value) {
    accepted = value;
    notifyListeners();
  }
}
