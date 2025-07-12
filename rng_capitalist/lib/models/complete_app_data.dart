// lib/models/complete_app_data.dart
import 'fixed_cost.dart';
import 'purchase_history.dart';
import 'dice_modifier.dart';
import 'sunk_cost.dart';

class CompleteAppData {
  // Financial data
  final double balance;
  final double lastMonthSpend;
  final double totalFixedCosts;
  final double availableBudget;
  final double remainingBudget;
  
  // Collections
  final List<FixedCost> fixedCosts;
  final List<PurchaseHistory> purchaseHistory;
  final List<DiceModifier> modifiers;
  final List<SunkCost> sunkCosts;
  
  // App settings and state
  final String currentPage;
  final DateTime lastUpdated;
  final String deviceId;
  final Map<String, DateTime> cooldownTimers;
  final Map<String, bool> modifierStates;
  
  // Investment and spinner history
  final List<Map<String, dynamic>> investmentHistory;
  final List<Map<String, dynamic>> spinnerHistory;

  CompleteAppData({
    required this.balance,
    required this.lastMonthSpend,
    required this.totalFixedCosts,
    required this.availableBudget,
    required this.remainingBudget,
    required this.fixedCosts,
    required this.purchaseHistory,
    required this.modifiers,
    required this.sunkCosts,
    required this.currentPage,
    required this.lastUpdated,
    required this.deviceId,
    required this.cooldownTimers,
    required this.modifierStates,
    required this.investmentHistory,
    required this.spinnerHistory,
  });

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'lastMonthSpend': lastMonthSpend,
      'totalFixedCosts': totalFixedCosts,
      'availableBudget': availableBudget,
      'remainingBudget': remainingBudget,
      'fixedCosts': fixedCosts.map((e) => e.toJson()).toList(),
      'purchaseHistory': purchaseHistory.map((e) => e.toJson()).toList(),
      'modifiers': modifiers.map((e) => e.toJson()).toList(),
      'sunkCosts': sunkCosts.map((e) => e.toJson()).toList(),
      'currentPage': currentPage,
      'lastUpdated': lastUpdated.toIso8601String(),
      'deviceId': deviceId,
      'cooldownTimers': cooldownTimers.map((k, v) => MapEntry(k, v.toIso8601String())),
      'modifierStates': modifierStates,
      'investmentHistory': investmentHistory,
      'spinnerHistory': spinnerHistory,
    };
  }

  factory CompleteAppData.fromJson(Map<String, dynamic> json) {
    return CompleteAppData(
      balance: (json['balance'] ?? 0.0).toDouble(),
      lastMonthSpend: (json['lastMonthSpend'] ?? 0.0).toDouble(),
      totalFixedCosts: (json['totalFixedCosts'] ?? 0.0).toDouble(),
      availableBudget: (json['availableBudget'] ?? 0.0).toDouble(),
      remainingBudget: (json['remainingBudget'] ?? 0.0).toDouble(),
      fixedCosts: (json['fixedCosts'] as List<dynamic>? ?? [])
          .map((e) => FixedCost.fromJson(e as Map<String, dynamic>))
          .toList(),
      purchaseHistory: (json['purchaseHistory'] as List<dynamic>? ?? [])
          .map((e) => PurchaseHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifiers: (json['modifiers'] as List<dynamic>? ?? [])
          .map((e) => DiceModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
      sunkCosts: (json['sunkCosts'] as List<dynamic>? ?? [])
          .map((e) => SunkCost.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] ?? 'Oracle',
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      deviceId: json['deviceId'] ?? 'unknown',
      cooldownTimers: (json['cooldownTimers'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, DateTime.parse(v as String))),
      modifierStates: Map<String, bool>.from(json['modifierStates'] ?? {}),
      investmentHistory: List<Map<String, dynamic>>.from(json['investmentHistory'] ?? []),
      spinnerHistory: List<Map<String, dynamic>>.from(json['spinnerHistory'] ?? []),
    );
  }

  factory CompleteAppData.defaultData() {
    return CompleteAppData(
      balance: 0.0,
      lastMonthSpend: 0.0,
      totalFixedCosts: 0.0,
      availableBudget: 0.0,
      remainingBudget: 0.0,
      fixedCosts: [],
      purchaseHistory: [],
      modifiers: DiceModifier.getPresetModifiers(),
      sunkCosts: [],
      currentPage: 'Oracle',
      lastUpdated: DateTime.now(),
      deviceId: 'device_${DateTime.now().millisecondsSinceEpoch}',
      cooldownTimers: {},
      modifierStates: {},
      investmentHistory: [],
      spinnerHistory: [],
    );
  }

  CompleteAppData copyWith({
    double? balance,
    double? lastMonthSpend,
    double? totalFixedCosts,
    double? availableBudget,
    double? remainingBudget,
    List<FixedCost>? fixedCosts,
    List<PurchaseHistory>? purchaseHistory,
    List<DiceModifier>? modifiers,
    List<SunkCost>? sunkCosts,
    String? currentPage,
    DateTime? lastUpdated,
    String? deviceId,
    Map<String, DateTime>? cooldownTimers,
    Map<String, bool>? modifierStates,
    List<Map<String, dynamic>>? investmentHistory,
    List<Map<String, dynamic>>? spinnerHistory,
  }) {
    return CompleteAppData(
      balance: balance ?? this.balance,
      lastMonthSpend: lastMonthSpend ?? this.lastMonthSpend,
      totalFixedCosts: totalFixedCosts ?? this.totalFixedCosts,
      availableBudget: availableBudget ?? this.availableBudget,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      fixedCosts: fixedCosts ?? this.fixedCosts,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      modifiers: modifiers ?? this.modifiers,
      sunkCosts: sunkCosts ?? this.sunkCosts,
      currentPage: currentPage ?? this.currentPage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deviceId: deviceId ?? this.deviceId,
      cooldownTimers: cooldownTimers ?? this.cooldownTimers,
      modifierStates: modifierStates ?? this.modifierStates,
      investmentHistory: investmentHistory ?? this.investmentHistory,
      spinnerHistory: spinnerHistory ?? this.spinnerHistory,
    );
  }
}
