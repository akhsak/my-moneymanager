import 'package:flutter/material.dart';
import 'package:monaymanagment/core/guset_models/transaction/guest_transaction.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';

class GuestModeController extends ChangeNotifier {
  final GuestStorageService _storage = GuestStorageService.instance;

  bool get isGuestMode => _storage.isGuestMode;

  Map<String, dynamic> get profile => _storage.guestProfile;

  List<GuestTransaction> get transactions => _storage.guestTransactions;

  Future<void> enterGuestMode() async {
    await _storage.setGuestMode(true);
    await _storage.init();
    notifyListeners();
  }

  Future<void> exitGuestMode() async {
    await _storage.setGuestMode(false);
    notifyListeners();
  }

  Future<void> resetGuestData() async {
    await _storage.clearGuestData();
    notifyListeners();
  }
}
