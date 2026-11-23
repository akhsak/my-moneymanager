import 'package:hive_flutter/hive_flutter.dart';
import 'package:monaymanagment/core/guset_models/cateqory/guest_category.dart';
import 'package:monaymanagment/core/guset_models/transaction/guest_transaction.dart';

import 'package:monaymanagment/core/guset_models/loan/guest_loan.dart';
import 'package:monaymanagment/repository/category/model/category_model.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';
import 'package:monaymanagment/repository/transaction/model/transaction_model.dart';

class GuestStorageService {
  GuestStorageService._();

  static final GuestStorageService instance = GuestStorageService._();

  static const String _settingsBoxName = 'guest_settings';
  static const String _transactionsBoxName = 'guest_transactions';
  static const String _categoriesBoxName = 'guest_categories';
  static final String _loansBoxName = 'guest_loans';
  static const String _targetsStorageKey = 'guest_targets';
  static const String _targetsCleanupKey = 'guest_cleanup_done';

  Box<dynamic>? _settingsBox;
  Box<GuestCategory>? _categoriesBox;
  Box<GuestTransaction>? _transactionsBox;
  Box<GuestLoan>? _loansBox;

  bool get isReady =>
      _settingsBox != null &&
      _categoriesBox != null &&
      _transactionsBox != null &&
      _loansBox != null;

  Future<void> init() async {
    _registerAdapters();
    _settingsBox ??= await Hive.openBox<dynamic>(_settingsBoxName);
    await _migrateLegacyData();
    _categoriesBox ??= await Hive.openBox<GuestCategory>(_categoriesBoxName);
    _transactionsBox ??= await Hive.openBox<GuestTransaction>(
      _transactionsBoxName,
    );
    _loansBox ??= await Hive.openBox<GuestLoan>(_loansBoxName);
    await _seedDefaults();
    await _cleanupDefaultGuestData();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(GuestCategoryAdapter().typeId)) {
      Hive.registerAdapter(GuestCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(GuestSubTransactionAdapter().typeId)) {
      Hive.registerAdapter(GuestSubTransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(GuestTransactionTypeAdapter().typeId)) {
      Hive.registerAdapter(GuestTransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(GuestTransactionAdapter().typeId)) {
      Hive.registerAdapter(GuestTransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(GuestLoanPaymentAdapter().typeId)) {
      Hive.registerAdapter(GuestLoanPaymentAdapter());
    }
    if (!Hive.isAdapterRegistered(GuestLoanAdapter().typeId)) {
      Hive.registerAdapter(GuestLoanAdapter());
    }
  }

  Future<void> _migrateLegacyData() async {
    await _migrateLegacyCategories();
    await _migrateLegacyTransactions();
  }

  Future<void> _migrateLegacyCategories() async {
    // Check if box is already open before trying to open it
    Box? rawBox;
    bool boxWasOpen = Hive.isBoxOpen(_categoriesBoxName);
    bool shouldClose = false;

    try {
      if (boxWasOpen) {
        // Box is already open, use it
        rawBox = Hive.box(_categoriesBoxName);
      } else {
        // Box is not open, open it and mark for closing
        rawBox = await Hive.openBox(_categoriesBoxName);
        shouldClose = true;
      }
    } catch (e) {
      print('Error opening box for migration: $e');
      return;
    }

    bool changed = false;

    try {
      for (final key in List.of(rawBox.keys)) {
        final value = rawBox.get(key);
        if (value is Map) {
          final migrated = _convertLegacyCategory(value);
          if (migrated != null) {
            await rawBox.put(key.toString(), migrated);
          } else {
            await rawBox.delete(key);
          }
          changed = true;
        } else if (value is! GuestCategory) {
          await rawBox.delete(key);
          changed = true;
        }
      }
      if (changed) {
        print('GuestStorageService: migrated legacy category data');
      }
    } finally {
      // Only close if we opened it (not if it was already open)
      if (shouldClose) {
        try {
          await rawBox.close();
        } catch (e) {
          print('Error closing migration box: $e');
        }
      }
    }
  }

  Future<void> _migrateLegacyTransactions() async {
    // Check if box is already open before trying to open it
    Box? rawBox;
    bool boxWasOpen = Hive.isBoxOpen(_transactionsBoxName);
    bool shouldClose = false;

    try {
      if (boxWasOpen) {
        // Box is already open, use it
        rawBox = Hive.box(_transactionsBoxName);
      } else {
        // Box is not open, open it and mark for closing
        rawBox = await Hive.openBox(_transactionsBoxName);
        shouldClose = true;
      }
    } catch (e) {
      print('Error opening transactions box for migration: $e');
      return;
    }

    bool changed = false;

    try {
      for (final key in List.of(rawBox.keys)) {
        final value = rawBox.get(key);
        if (value is Map) {
          final migrated = _convertLegacyTransaction(value);
          if (migrated != null) {
            await rawBox.put(key.toString(), migrated);
          } else {
            await rawBox.delete(key);
          }
          changed = true;
        } else if (value is! GuestTransaction) {
          await rawBox.delete(key);
          changed = true;
        }
      }
      if (changed) {
        print('GuestStorageService: migrated legacy transaction data');
      }
    } finally {
      // Only close if we opened it (not if it was already open)
      if (shouldClose) {
        try {
          await rawBox.close();
        } catch (e) {
          print('Error closing migration box: $e');
        }
      }
    }
  }

  GuestCategory? _convertLegacyCategory(Map<dynamic, dynamic> data) {
    final id = data['_id']?.toString();
    final name = data['name']?.toString();
    if (id == null || name == null) {
      return null;
    }
    final nowString = data['createdAt']?.toString();
    DateTime parseDate(String? value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }

    return GuestCategory(
      id: id,
      name: name,
      icon: data['icon']?.toString() ?? _iconForCategory(name),
      isActive: (data['isActive'] is bool) ? data['isActive'] as bool : true,
      createdAt: parseDate(nowString),
      updatedAt: parseDate(data['updatedAt']?.toString()),
    );
  }

  GuestTransaction? _convertLegacyTransaction(Map<dynamic, dynamic> data) {
    final parentId =
        data['parentTransactionId']?.toString() ??
        data['_id']?.toString() ??
        'guest-tx-${DateTime.now().microsecondsSinceEpoch}';
    final categoryId =
        data['categoryId']?.toString() ?? 'guest-${_slug('general')}';
    final categoryName = data['categoryName']?.toString() ?? 'General';
    final title = data['name']?.toString() ?? 'Transaction';
    final amount = (data['parentAmount'] ?? data['amount'] ?? 0).toDouble();
    final currency = data['parentCurrency']?.toString() ?? 'INR';
    final frequency = data['parentFrequency']?.toString() ?? 'Daily';
    final description = data['description']?.toString() ?? '';
    final timestamp = _parseLegacyTimestamp(
      data['date']?.toString(),
      data['time']?.toString(),
    );
    final type = amount >= 0
        ? GuestTransactionType.income
        : GuestTransactionType.expense;

    final subId =
        data['_id']?.toString() ??
        'guest-sub-${DateTime.now().microsecondsSinceEpoch}';
    final sub = GuestSubTransaction(
      id: subId,
      name: title,
      amount: (data['amount'] is num)
          ? (data['amount'] as num).toDouble()
          : amount,
      description: description,
      timestamp: timestamp,
    );

    return GuestTransaction(
      id: parentId,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      amount: amount,
      currency: currency,
      frequency: frequency,
      type: type,
      subTransactions: [sub],
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  DateTime _parseLegacyTimestamp(String? date, String? time) {
    DateTime base = DateTime.now();
    if (date != null && date.isNotEmpty) {
      final parts = date.replaceAll(',', '').split(' ');
      if (parts.length >= 3) {
        final month = _monthNameIndex(parts[0]);
        final day = int.tryParse(parts[1]) ?? base.day;
        final year = int.tryParse(parts[2]) ?? base.year;
        base = DateTime(year, month, day);
      }
    }
    if (time != null && time.isNotEmpty) {
      final timeParts = time.split(' ');
      if (timeParts.isNotEmpty) {
        final hm = timeParts[0].split(':');
        int hour = hm.isNotEmpty ? int.tryParse(hm[0]) ?? base.hour : base.hour;
        final minute = hm.length > 1 ? int.tryParse(hm[1]) ?? 0 : 0;
        final period = timeParts.length > 1 ? timeParts[1].toUpperCase() : 'AM';
        if (period == 'PM' && hour < 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }
        base = DateTime(base.year, base.month, base.day, hour, minute);
      }
    }
    return base;
  }

  int _monthNameIndex(String monthName) {
    const months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    final index = months.indexOf(monthName.toLowerCase());
    return index >= 0 ? index + 1 : DateTime.now().month;
  }

  bool get isGuestMode =>
      (_settingsBox?.get('guest_mode', defaultValue: false) as bool?) ?? false;

  Future<void> setGuestMode(bool value) async {
    await _settingsBox?.put('guest_mode', value);
    if (value) {
      await _seedDefaults();
    }
  }

  Map<String, dynamic> get guestProfile {
    final stored = _settingsBox?.get('guest_profile');
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }
    return Map<String, dynamic>.from(_defaultProfile);
  }

  Future<void> saveGuestProfile(Map<String, dynamic> profile) async {
    await _settingsBox?.put('guest_profile', profile);
  }

  List<GuestCategory> get guestCategories =>
      _categoriesBox?.values.toList() ?? [];

  List<GuestTransaction> get guestTransactions =>
      _transactionsBox?.values.toList() ?? [];

  List<GuestLoan> get guestLoans => _loansBox?.values.toList() ?? [];

  List<CategoryModel> get guestCategoryModels =>
      guestCategories.map(_mapGuestCategoryToModel).toList();

  List<SubTransactionWithCategory> get guestSubTransactions {
    final iconMap = <String, String>{};
    for (final category in guestCategories) {
      iconMap[category.id] = category.icon;
    }

    final List<SubTransactionWithCategory> items = [];

    for (final transaction in guestTransactions) {
      for (final sub in transaction.subTransactions) {
        items.add(
          SubTransactionWithCategory(
            id: sub.id,
            name: sub.name,
            amount: sub.amount,
            date: _formatDate(sub.timestamp),
            time: _formatTime(sub.timestamp),
            description: sub.description,
            categoryName: transaction.categoryName,
            categoryId: transaction.categoryId,
            categoryIcon:
                iconMap[transaction.categoryId] ??
                _iconForCategory(transaction.categoryName),
            parentTransactionId: transaction.id,
            parentMonth: _monthName(sub.timestamp.month),
            parentYear: sub.timestamp.year,
            parentAmount: transaction.amount,
            parentCurrency: transaction.currency,
            parentFrequency: transaction.frequency,
          ),
        );
      }
    }

    return items;
  }

  List<Target> get guestTargets =>
      _readGuestTargetMaps().map(_mapGuestTargetFromMap).toList();

  Future<GuestCategory> createCategory({
    required String name,
    String icon = '💰',
  }) async {
    final normalized = name.trim();
    final now = DateTime.now();
    final id = 'guest-${_slug(normalized)}-${now.microsecondsSinceEpoch}';
    final category = GuestCategory(
      id: id,
      name: normalized,
      icon: icon,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await _categoriesBox?.put(id, category);
    return category;
  }

  Future<GuestCategory?> updateCategory(
    String id, {
    String? name,
    String? icon,
    bool? isActive,
  }) async {
    final existing = _categoriesBox?.get(id);
    if (existing == null) return null;

    final updated = existing.copyWith(
      name: name ?? existing.name,
      icon: icon ?? existing.icon,
      isActive: isActive ?? existing.isActive,
      updatedAt: DateTime.now(),
    );
    await _categoriesBox?.put(id, updated);
    return updated;
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesBox?.delete(id);
    final toDelete = guestTransactions
        .where((transaction) => transaction.categoryId == id)
        .map((transaction) => transaction.id)
        .toList();
    for (final txId in toDelete) {
      await _transactionsBox?.delete(txId);
    }
  }

  Future<GuestTransaction> createTransaction({
    required String categoryId,
    required String categoryName,
    required String title,
    required double amount,
    required DateTime date,
    GuestTransactionType type = GuestTransactionType.expense,
    String description = '',
    String frequency = 'Daily',
    String currency = 'INR',
    List<GuestSubTransaction>? subTransactions,
  }) async {
    final now = DateTime.now();
    final id = 'guest-tx-${now.microsecondsSinceEpoch}';
    final subList =
        subTransactions ??
        [
          GuestSubTransaction(
            id: 'guest-sub-${now.microsecondsSinceEpoch}',
            name: title,
            amount: amount,
            description: description,
            timestamp: date,
          ),
        ];

    final transaction = GuestTransaction(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      amount: amount,
      currency: currency,
      frequency: frequency,
      type: type,
      subTransactions: subList,
      createdAt: now,
      updatedAt: now,
    );

    await _transactionsBox?.put(id, transaction);
    return transaction;
  }

  Future<GuestTransaction?> updateTransaction(
    String id, {
    String? title,
    double? amount,
    String? description,
    GuestTransactionType? type,
    List<GuestSubTransaction>? subTransactions,
  }) async {
    final existing = _transactionsBox?.get(id);
    if (existing == null) return null;

    final updated = existing.copyWith(
      title: title ?? existing.title,
      amount: amount ?? existing.amount,
      type: type ?? existing.type,
      subTransactions:
          subTransactions ??
          existing.subTransactions.map((sub) {
            if (description != null && sub == existing.subTransactions.first) {
              return sub.copyWith(description: description);
            }
            return sub;
          }).toList(),
      updatedAt: DateTime.now(),
    );

    await _transactionsBox?.put(id, updated);
    return updated;
  }

  Future<bool> updateSubTransaction({
    required String transactionId,
    required int subTransactionIndex,
    required String name,
    required double amount,
    required DateTime date,
    required String time,
    required String description,
  }) async {
    final transaction = _transactionsBox?.get(transactionId);
    if (transaction == null) {
      print('GuestStorageService: Transaction not found: $transactionId');
      return false;
    }

    if (subTransactionIndex < 0 ||
        subTransactionIndex >= transaction.subTransactions.length) {
      print(
        'GuestStorageService: Invalid sub-transaction index: $subTransactionIndex',
      );
      return false;
    }

    final updatedTimestamp = _combineDateAndTime(date, time);
    final updatedSubs = List<GuestSubTransaction>.from(
      transaction.subTransactions,
    );
    final originalSub = updatedSubs[subTransactionIndex];

    updatedSubs[subTransactionIndex] = originalSub.copyWith(
      name: name,
      amount: amount,
      description: description,
      timestamp: updatedTimestamp,
    );

    final updatedAmount = updatedSubs.fold<double>(
      0.0,
      (sum, sub) => sum + sub.amount,
    );

    final updatedTransaction = transaction.copyWith(
      subTransactions: updatedSubs,
      amount: updatedAmount,
      updatedAt: DateTime.now(),
    );

    await _transactionsBox?.put(transaction.id, updatedTransaction);
    return true;
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox?.delete(id);
  }

  Future<bool> deleteSubTransaction({
    required String transactionId,
    required int subTransactionIndex,
  }) async {
    final transaction = _transactionsBox?.get(transactionId);
    if (transaction == null) {
      print('Transaction not found: $transactionId');
      return false;
    }

    if (subTransactionIndex < 0 ||
        subTransactionIndex >= transaction.subTransactions.length) {
      print(
        'Invalid sub-transaction index: $subTransactionIndex (total: ${transaction.subTransactions.length})',
      );
      return false;
    }

    // Remove the sub-transaction at the specified index
    final updatedSubTransactions = List<GuestSubTransaction>.from(
      transaction.subTransactions,
    );
    updatedSubTransactions.removeAt(subTransactionIndex);

    // If no sub-transactions remain, delete the entire transaction
    if (updatedSubTransactions.isEmpty) {
      await _transactionsBox?.delete(transactionId);
      print(
        'Deleted transaction $transactionId (no sub-transactions remaining)',
      );
      return true;
    }

    // Recalculate the transaction amount based on remaining sub-transactions
    final newAmount = updatedSubTransactions.fold<double>(
      0.0,
      (sum, sub) => sum + sub.amount,
    );

    // Update the transaction with remaining sub-transactions and new amount
    final updated = transaction.copyWith(
      amount: newAmount,
      subTransactions: updatedSubTransactions,
      updatedAt: DateTime.now(),
    );

    await _transactionsBox?.put(transactionId, updated);
    print(
      'Deleted sub-transaction at index $subTransactionIndex from transaction $transactionId',
    );
    return true;
  }

  Future<Target> createGuestTarget({
    required String categoryId,
    required String categoryName,
    required double amount,
  }) async {
    final now = DateTime.now();
    final id = _generateGuestTargetId(now);
    final map = _createGuestTargetMap(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      amount: amount,
      progress: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    final targets = _readGuestTargetMaps();
    targets.add(map);
    await _saveGuestTargetMaps(targets);
    return _mapGuestTargetFromMap(map);
  }

  Future<Target?> updateGuestTarget({
    required String targetId,
    String? categoryId,
    String? categoryName,
    double? amount,
    double? progress,
  }) async {
    final targets = _readGuestTargetMaps();
    final index = targets.indexWhere((map) => map['id'] == targetId);
    if (index == -1) return null;

    final existing = Map<String, dynamic>.from(targets[index]);
    if (categoryId != null) existing['categoryId'] = categoryId;
    if (categoryName != null) existing['categoryName'] = categoryName;
    if (amount != null) existing['amount'] = amount;
    if (progress != null) existing['progress'] = progress;
    existing['updatedAt'] = DateTime.now().toIso8601String();

    targets[index] = existing;
    await _saveGuestTargetMaps(targets);
    return _mapGuestTargetFromMap(existing);
  }

  Future<bool> updateGuestTargetProgress({
    required String categoryId,
    required double progress,
  }) async {
    final targets = _readGuestTargetMaps();
    final index = targets.indexWhere((map) => map['categoryId'] == categoryId);
    if (index == -1) {
      print('GuestStorageService: No target found for category $categoryId');
      return false;
    }

    final updated = Map<String, dynamic>.from(targets[index]);
    updated['progress'] = progress;
    updated['updatedAt'] = DateTime.now().toIso8601String();
    targets[index] = updated;
    await _saveGuestTargetMaps(targets);
    return true;
  }

  Future<bool> deleteGuestTarget(String targetId) async {
    final targets = _readGuestTargetMaps();
    final initialLength = targets.length;
    targets.removeWhere((map) => map['id'] == targetId);
    if (targets.length == initialLength) return false;
    await _saveGuestTargetMaps(targets);
    return true;
  }

  Future<GuestLoan> createLoan({
    required String name,
    required double principal,
    required DateTime deadline,
    String note = '',
    String? categoryId,
  }) async {
    final now = DateTime.now();
    final id = 'guest-loan-${now.microsecondsSinceEpoch}';
    final resolvedCategory =
        categoryId ??
        (guestCategories.isNotEmpty ? guestCategories.first.id : 'guest-loan');

    final loan = GuestLoan(
      id: id,
      name: name,
      principal: principal,
      remainingAmount: principal,
      deadline: deadline,
      note: note,
      categoryId: resolvedCategory,
      payments: const [],
      createdAt: now,
      updatedAt: now,
    );

    await _loansBox?.put(id, loan);
    return loan;
  }

  Future<GuestLoan?> updateLoan({
    required String loanId,
    String? name,
    double? principal,
    DateTime? deadline,
    String? note,
    String? categoryId,
  }) async {
    final existing = _loansBox?.get(loanId);
    if (existing == null) return null;

    final updated = existing.copyWith(
      name: name ?? existing.name,
      principal: principal ?? existing.principal,
      remainingAmount: principal != null
          ? (principal - existing.amountPaid)
          : existing.remainingAmount,
      deadline: deadline ?? existing.deadline,
      note: note ?? existing.note,
      categoryId: categoryId ?? existing.categoryId,
      updatedAt: DateTime.now(),
    );

    await _loansBox?.put(loanId, updated);
    return updated;
  }

  Future<GuestLoan?> addLoanPayment({
    required String loanId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final existing = _loansBox?.get(loanId);
    if (existing == null) return null;
    final payment = GuestLoanPayment(
      id: 'guest-loan-pay-${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      date: date,
      note: note,
    );
    final payments = [...existing.payments, payment];
    final remaining = (existing.remainingAmount - amount).clamp(
      0.0,
      double.infinity,
    );
    final updated = existing.copyWith(
      payments: payments,
      remainingAmount: remaining,
      updatedAt: DateTime.now(),
    );
    await _loansBox?.put(loanId, updated);
    return updated;
  }

  Future<GuestLoan?> addLoanIncome({
    required String loanId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final existing = _loansBox?.get(loanId);
    if (existing == null) return null;
    final adjustment = GuestLoanPayment(
      id: 'guest-loan-income-${DateTime.now().microsecondsSinceEpoch}',
      amount: -amount,
      date: date,
      note: note,
    );
    final payments = [...existing.payments, adjustment];
    final remaining = existing.remainingAmount + amount;
    final updated = existing.copyWith(
      payments: payments,
      remainingAmount: remaining,
      updatedAt: DateTime.now(),
    );
    await _loansBox?.put(loanId, updated);
    return updated;
  }

  Future<bool> deleteLoan(String loanId) async {
    if (_loansBox?.containsKey(loanId) ?? false) {
      await _loansBox?.delete(loanId);
      return true;
    }
    return false;
  }

  Future<void> clearGuestData() async {
    await _transactionsBox?.clear();
    await _categoriesBox?.clear();
    await _loansBox?.clear();
    await _settingsBox?.delete('guest_profile');
    await _settingsBox?.put('guest_mode', false);
    await _settingsBox?.delete(_targetsStorageKey);
    await _settingsBox?.delete(_targetsCleanupKey);
  }

  Future<void> _seedDefaults() async {
    if (_settingsBox == null ||
        _transactionsBox == null ||
        _categoriesBox == null) {
      return;
    }

    if (!_settingsBox!.containsKey('guest_profile')) {
      await _settingsBox!.put('guest_profile', _defaultProfile);
    }

    // Migrate legacy categories if they exist, but don't seed new ones
    if (_categoriesBox!.isEmpty) {
      final legacyCategories = _settingsBox!.get('guest_categories');
      if (legacyCategories is List) {
        for (final item in legacyCategories) {
          if (item is Map) {
            final converted = _convertLegacyCategory(item);
            if (converted != null) {
              await _categoriesBox!.put(converted.id, converted);
            }
          }
        }
        await _settingsBox!.delete('guest_categories');
      }
      // Don't seed default categories - start with empty list
    }

    if (_transactionsBox!.isEmpty) {
      for (final transaction in _sampleTransactions) {
        await _transactionsBox!.put(transaction.id, transaction);
      }
    }
  }

  // Future<void> _cleanupDefaultGuestData() async {
  //   if (_settingsBox == null ||
  //       _categoriesBox == null ||
  //       _transactionsBox == null) {
  //     return;
  //   }

  //   final alreadyCleaned =
  //       _settingsBox!.get('guest_cleanup_done') as bool? ?? false;
  //   if (alreadyCleaned) return;

  //   const legacyNames = {
  //     'food',
  //     'transport',
  //     'shopping',
  //     'salary',
  //     'entertainment',
  //     'bills',
  //     'healthcare',
  //     'education',
  //   };

  //   final legacyCategoryIds = <String>{};
  //   for (final category in _categoriesBox!.values) {
  //     if (legacyNames.contains(category.name.toLowerCase())) {
  //       legacyCategoryIds.add(category.id);
  //     }
  //   }

  //   for (final id in legacyCategoryIds) {
  //     await _categoriesBox!.delete(id);
  //   }

  //   final txKeysToDelete = <String>[];
  //   for (final key in _transactionsBox!.keys) {
  //     final transaction = _transactionsBox!.get(key);
  //     if (transaction is GuestTransaction &&
  //         legacyCategoryIds.contains(transaction.categoryId)) {
  //       txKeysToDelete.add(transaction.id);
  //     }
  //   }

  //   for (final id in txKeysToDelete) {
  //     await _transactionsBox!.delete(id);
  //   }

  //   await _settingsBox!.put('guest_cleanup_done', true);
  // }

  Future<void> _cleanupDefaultGuestData() async {
    if (_settingsBox == null ||
        _categoriesBox == null ||
        _transactionsBox == null) {
      return;
    }

    final alreadyCleaned =
        _settingsBox!.get(_targetsCleanupKey) as bool? ?? false;
    if (alreadyCleaned) return;

    const legacyNames = {
      'food',
      'transport',
      'shopping',
      'salary',
      'entertainment',
      'bills',
      'healthcare',
      'education',
    };

    final legacyCategoryIds = <String>{};
    for (final category in _categoriesBox!.values) {
      if (legacyNames.contains(category.name.toLowerCase())) {
        legacyCategoryIds.add(category.id);
      }
    }

    for (final id in legacyCategoryIds) {
      await _categoriesBox!.delete(id);
    }

    final txKeysToDelete = <String>[];
    for (final key in _transactionsBox!.keys) {
      final transaction = _transactionsBox!.get(key);
      if (transaction is GuestTransaction &&
          legacyCategoryIds.contains(transaction.categoryId)) {
        txKeysToDelete.add(transaction.id);
      }
    }

    for (final id in txKeysToDelete) {
      await _transactionsBox!.delete(id);
    }

    await _settingsBox!.put(_targetsCleanupKey, true);
  }

  List<Map<String, dynamic>> _readGuestTargetMaps() {
    final stored = _settingsBox?.get(_targetsStorageKey);
    if (stored is List) {
      return stored
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  Future<void> _saveGuestTargetMaps(List<Map<String, dynamic>> targets) async {
    await _settingsBox?.put(_targetsStorageKey, targets);
  }

  Map<String, dynamic> _createGuestTargetMap({
    required String id,
    required String categoryId,
    required String categoryName,
    required double amount,
    required double progress,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Target _mapGuestTargetFromMap(Map<String, dynamic> data) {
    DateTime parseDate(String key) {
      final value = data[key];
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return DateTime.now();
    }

    return Target(
      id: data['id'] as String,
      userId: 'guest',
      categoryId: data['categoryId'] as String? ?? 'guest-category',
      category: data['categoryName'] as String? ?? 'General',
      amount: _parseDouble(data['amount']),
      progress: _parseDouble(data['progress']),
      createdAt: parseDate('createdAt'),
      updatedAt: parseDate('updatedAt'),
    );
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _generateGuestTargetId(DateTime now) =>
      'guest-target-${now.microsecondsSinceEpoch}';

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    try {
      final parts = time.trim().split(' ');
      if (parts.isEmpty) return date;

      final timeParts = parts.first.split(':');
      if (timeParts.length < 2) return date;

      int hour = int.tryParse(timeParts[0]) ?? date.hour;
      final minute = int.tryParse(timeParts[1]) ?? date.minute;
      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour < 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }
      }
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      print('GuestStorageService: Failed to parse time "$time": $e');
      return date;
    }
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _slug(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }

  String _iconForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food')) return '🍔';
    if (lower.contains('travel') || lower.contains('transport')) return '🚌';
    if (lower.contains('salary') || lower.contains('income')) return '💼';
    if (lower.contains('shopping')) return '🛍️';
    if (lower.contains('health')) return '💊';
    if (lower.contains('entertainment')) return '🎬';
    if (lower.contains('loan')) return '💳';
    return '💰';
  }

  Map<String, dynamic> get _defaultProfile => {
    'name': 'Guest User',
    'email': 'guest@finura.app',
    'avatar': null,
    'createdAt': DateTime.now().toIso8601String(),
  };

  CategoryModel _mapGuestCategoryToModel(GuestCategory category) {
    return CategoryModel(
      id: category.id,
      userId: 'guest',
      name: category.name,
      isActive: category.isActive,
      icon: category.icon,
      createdAt: category.createdAt.toIso8601String(),
      updatedAt: category.updatedAt.toIso8601String(),
    );
  }

  List<GuestTransaction> get _sampleTransactions {
    return [];
  }
}
