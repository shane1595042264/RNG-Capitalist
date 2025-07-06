// lib/utils/storage_utils_dnd.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fixed_cost.dart';
import '../models/purchase_history.dart';
import '../models/dice_modifier.dart';

class StorageUtilsDnD {
  static const String _lastBalanceKey = 'lastBalance';
  static const String _lastMonthSpendKey = 'lastMonthSpend';
  static const String _fixedCostsKey = 'fixedCosts';
  static const String _purchaseHistoryKey = 'purchaseHistory';
  static const String _modifiersKey = 'diceModifiers';

  static Future<AppDataDnD> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final lastBalance = prefs.getString(_lastBalanceKey) ?? '';
    final lastMonthSpend = prefs.getDouble(_lastMonthSpendKey) ?? 0.0;
    
    // Load fixed costs
    final fixedCostsJson = prefs.getStringList(_fixedCostsKey) ?? [];
    final fixedCosts = fixedCostsJson
        .map((json) => FixedCost.fromJson(jsonDecode(json)))
        .toList();
    
    // Load purchase history
    final historyJson = prefs.getStringList(_purchaseHistoryKey) ?? [];
    final purchaseHistory = historyJson
        .map((json) => PurchaseHistory.fromJson(jsonDecode(json)))
        .toList();
    
    // Load modifiers
    final modifiersJson = prefs.getStringList(_modifiersKey) ?? [];
    final modifiers = modifiersJson
        .map((json) => DiceModifier.fromJson(jsonDecode(json)))
        .toList();
    
    return AppDataDnD(
      lastBalance: lastBalance,
      lastMonthSpend: lastMonthSpend,
      fixedCosts: fixedCosts,
      purchaseHistory: purchaseHistory,
      modifiers: modifiers,
    );
  }

  static Future<void> saveSettings(AppDataDnD data) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_lastBalanceKey, data.lastBalance);
    await prefs.setDouble(_lastMonthSpendKey, data.lastMonthSpend);
    
    // Save fixed costs
    final fixedCostsJson = data.fixedCosts
        .map((cost) => jsonEncode(cost.toJson()))
        .toList();
    await prefs.setStringList(_fixedCostsKey, fixedCostsJson);
    
    // Save purchase history
    final historyJson = data.purchaseHistory
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_purchaseHistoryKey, historyJson);
    
    // Save modifiers
    final modifiersJson = data.modifiers
        .map((modifier) => jsonEncode(modifier.toJson()))
        .toList();
    await prefs.setStringList(_modifiersKey, modifiersJson);
  }

  static Future<void> saveLastBalance(String balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBalanceKey, balance);
  }

  static Future<void> saveLastMonthSpend(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastMonthSpendKey, amount);
  }
}

class AppDataDnD {
  final String lastBalance;
  final double lastMonthSpend;
  final List<FixedCost> fixedCosts;
  final List<PurchaseHistory> purchaseHistory;
  final List<DiceModifier> modifiers;

  AppDataDnD({
    required this.lastBalance,
    required this.lastMonthSpend,
    required this.fixedCosts,
    required this.purchaseHistory,
    required this.modifiers,
  });

  AppDataDnD copyWith({
    String? lastBalance,
    double? lastMonthSpend,
    List<FixedCost>? fixedCosts,
    List<PurchaseHistory>? purchaseHistory,
    List<DiceModifier>? modifiers,
  }) {
    return AppDataDnD(
      lastBalance: lastBalance ?? this.lastBalance,
      lastMonthSpend: lastMonthSpend ?? this.lastMonthSpend,
      fixedCosts: fixedCosts ?? this.fixedCosts,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      modifiers: modifiers ?? this.modifiers,
    );
  }
}

