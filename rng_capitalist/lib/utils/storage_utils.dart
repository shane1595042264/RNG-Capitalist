import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fixed_cost.dart';
import '../models/purchase_history.dart';

class StorageUtils {
  static const String _strictnessKey = 'strictness';
  static const String _lastBalanceKey = 'lastBalance';
  static const String _lastMonthSpendKey = 'lastMonthSpend';
  static const String _fixedCostsKey = 'fixedCosts';
  static const String _purchaseHistoryKey = 'purchaseHistory';

  static Future<AppData> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final strictnessLevel = prefs.getDouble(_strictnessKey) ?? 1.0;
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
    
    return AppData(
      strictnessLevel: strictnessLevel,
      lastBalance: lastBalance,
      lastMonthSpend: lastMonthSpend,
      fixedCosts: fixedCosts,
      purchaseHistory: purchaseHistory,
    );
  }

  static Future<void> saveSettings(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble(_strictnessKey, data.strictnessLevel);
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
  }

  static Future<void> saveStrictness(double strictness) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_strictnessKey, strictness);
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

class AppData {
  final double strictnessLevel;
  final String lastBalance;
  final double lastMonthSpend;
  final List<FixedCost> fixedCosts;
  final List<PurchaseHistory> purchaseHistory;

  AppData({
    required this.strictnessLevel,
    required this.lastBalance,
    required this.lastMonthSpend,
    required this.fixedCosts,
    required this.purchaseHistory,
  });

  AppData copyWith({
    double? strictnessLevel,
    String? lastBalance,
    double? lastMonthSpend,
    List<FixedCost>? fixedCosts,
    List<PurchaseHistory>? purchaseHistory,
  }) {
    return AppData(
      strictnessLevel: strictnessLevel ?? this.strictnessLevel,
      lastBalance: lastBalance ?? this.lastBalance,
      lastMonthSpend: lastMonthSpend ?? this.lastMonthSpend,
      fixedCosts: fixedCosts ?? this.fixedCosts,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
    );
  }
}
