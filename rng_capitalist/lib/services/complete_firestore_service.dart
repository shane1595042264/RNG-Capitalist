import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/fixed_cost.dart';
import '../models/purchase_history.dart';
import '../models/dice_modifier.dart';
import '../models/sunk_cost.dart';
import '../models/smart_expense.dart';
import 'user_auth_service.dart';

// Comprehensive data model for ALL app data
class CompleteAppData {
  // Core financial data
  final String lastBalance;
  final double lastMonthSpend;
  final double availableBudget;
  final double remainingBudget;
  
  // Collections
  final List<FixedCost> fixedCosts;
  final List<PurchaseHistory> purchaseHistory;
  final List<DiceModifier> modifiers;
  final List<SunkCost> sunkCosts;
  final List<SmartExpense> smartExpenses;
  
  // App state and settings
  final Map<String, dynamic> appSettings;
  final Map<String, DateTime> cooldownTimers;
  final Map<String, bool> modifierStates;
  final String currentPage;
  
  // Schedule and advanced features
  final Map<String, dynamic> scheduleData;
  final List<Map<String, dynamic>> investmentHistory;
  final Map<String, dynamic> spinnerHistory;
  
  // Device and sync info
  final String deviceName;
  final String platform;
  final DateTime lastSyncTime;

  const CompleteAppData({
    required this.lastBalance,
    required this.lastMonthSpend,
    required this.availableBudget,
    required this.remainingBudget,
    required this.fixedCosts,
    required this.purchaseHistory,
    required this.modifiers,
    required this.sunkCosts,
    required this.smartExpenses,
    required this.appSettings,
    required this.cooldownTimers,
    required this.modifierStates,
    required this.currentPage,
    required this.scheduleData,
    required this.investmentHistory,
    required this.spinnerHistory,
    required this.deviceName,
    required this.platform,
    required this.lastSyncTime,
  });

  Map<String, dynamic> toJson() {
    return {
      // Core financial data
      'lastBalance': lastBalance,
      'lastMonthSpend': lastMonthSpend,
      'availableBudget': availableBudget,
      'remainingBudget': remainingBudget,
      
      // Collections
      'fixedCosts': fixedCosts.map((cost) => cost.toJson()).toList(),
      'purchaseHistory': purchaseHistory.map((history) => history.toJson()).toList(),
      'modifiers': modifiers.map((modifier) => modifier.toJson()).toList(),
      'sunkCosts': sunkCosts.map((cost) => cost.toJson()).toList(),
      'smartExpenses': smartExpenses.map((expense) => expense.toJson()).toList(),
      
      // App state and settings
      'appSettings': appSettings,
      'cooldownTimers': cooldownTimers.map((key, value) => MapEntry(key, value.toIso8601String())),
      'modifierStates': modifierStates,
      'currentPage': currentPage,
      
      // Schedule and advanced features
      'scheduleData': scheduleData,
      'investmentHistory': investmentHistory,
      'spinnerHistory': spinnerHistory,
      
      // Device and sync info
      'deviceName': deviceName,
      'platform': platform,
      'lastSyncTime': lastSyncTime.toIso8601String(),
    };
  }

  factory CompleteAppData.fromJson(Map<String, dynamic> json) {
    return CompleteAppData(
      // Core financial data
      lastBalance: json['lastBalance']?.toString() ?? '0.0',
      lastMonthSpend: (json['lastMonthSpend'] as num?)?.toDouble() ?? 0.0,
      availableBudget: (json['availableBudget'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remainingBudget'] as num?)?.toDouble() ?? 0.0,
      
      // Collections
      fixedCosts: (json['fixedCosts'] as List<dynamic>?)
          ?.map((item) => FixedCost.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      purchaseHistory: (json['purchaseHistory'] as List<dynamic>?)
          ?.map((item) => PurchaseHistory.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      modifiers: (json['modifiers'] as List<dynamic>?)
          ?.map((item) => DiceModifier.fromJson(item as Map<String, dynamic>))
          .toList() ?? DiceModifier.getPresetModifiers(),
      sunkCosts: (json['sunkCosts'] as List<dynamic>?)
          ?.map((item) => SunkCost.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      smartExpenses: (json['smartExpenses'] as List<dynamic>?)
          ?.map((item) => SmartExpense.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      
      // App state and settings
      appSettings: (json['appSettings'] as Map<String, dynamic>?) ?? {},
      cooldownTimers: (json['cooldownTimers'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, DateTime.parse(value))) ?? {},
      modifierStates: (json['modifierStates'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)) ?? {},
      currentPage: json['currentPage']?.toString() ?? 'oracle',
      
      // Schedule and advanced features
      scheduleData: (json['scheduleData'] as Map<String, dynamic>?) ?? {},
      investmentHistory: (json['investmentHistory'] as List<dynamic>?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [],
      spinnerHistory: (json['spinnerHistory'] as Map<String, dynamic>?) ?? {},
      
      // Device and sync info
      deviceName: json['deviceName']?.toString() ?? 'Unknown Device',
      platform: json['platform']?.toString() ?? 'unknown',
      lastSyncTime: json['lastSyncTime'] != null 
          ? DateTime.parse(json['lastSyncTime']) 
          : DateTime.now(),
    );
  }

  // Create default data for new users
  factory CompleteAppData.createDefault({
    String? deviceName,
    String? platform,
  }) {
    return CompleteAppData(
      lastBalance: '100.0',
      lastMonthSpend: 0.0,
      availableBudget: 100.0,
      remainingBudget: 100.0,
      fixedCosts: [],
      purchaseHistory: [],
      modifiers: DiceModifier.getPresetModifiers(),
      sunkCosts: [],
      smartExpenses: [],
      appSettings: {
        'theme': 'light',
        'notifications': true,
        'auto_sync': true,
        'offline_mode': false,
      },
      cooldownTimers: {},
      modifierStates: {},
      currentPage: 'oracle',
      scheduleData: {},
      investmentHistory: [],
      spinnerHistory: {},
      deviceName: deviceName ?? 'My Device',
      platform: platform ?? 'unknown',
      lastSyncTime: DateTime.now(),
    );
  }

  // Create a copy with updated fields
  CompleteAppData copyWith({
    String? lastBalance,
    double? lastMonthSpend,
    double? availableBudget,
    double? remainingBudget,
    List<FixedCost>? fixedCosts,
    List<PurchaseHistory>? purchaseHistory,
    List<DiceModifier>? modifiers,
    List<SunkCost>? sunkCosts,
    List<SmartExpense>? smartExpenses,
    Map<String, dynamic>? appSettings,
    Map<String, DateTime>? cooldownTimers,
    Map<String, bool>? modifierStates,
    String? currentPage,
    Map<String, dynamic>? scheduleData,
    List<Map<String, dynamic>>? investmentHistory,
    Map<String, dynamic>? spinnerHistory,
    String? deviceName,
    String? platform,
  }) {
    return CompleteAppData(
      lastBalance: lastBalance ?? this.lastBalance,
      lastMonthSpend: lastMonthSpend ?? this.lastMonthSpend,
      availableBudget: availableBudget ?? this.availableBudget,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      fixedCosts: fixedCosts ?? this.fixedCosts,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      modifiers: modifiers ?? this.modifiers,
      sunkCosts: sunkCosts ?? this.sunkCosts,
      smartExpenses: smartExpenses ?? this.smartExpenses,
      appSettings: appSettings ?? this.appSettings,
      cooldownTimers: cooldownTimers ?? this.cooldownTimers,
      modifierStates: modifierStates ?? this.modifierStates,
      currentPage: currentPage ?? this.currentPage,
      scheduleData: scheduleData ?? this.scheduleData,
      investmentHistory: investmentHistory ?? this.investmentHistory,
      spinnerHistory: spinnerHistory ?? this.spinnerHistory,
      deviceName: deviceName ?? this.deviceName,
      platform: platform ?? this.platform,
      lastSyncTime: DateTime.now(),
    );
  }
}

class CompleteFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserAuthService _authService = UserAuthService();
  static const String _collectionName = 'complete_user_data';
  
  // Get current user ID from auth service
  Future<String?> get _documentId async {
    final userId = await _authService.getCurrentUserId();
    if (kDebugMode && userId != null) {
      print('🔐 Using authenticated User ID: $userId');
    }
    return userId;
  }

  // Save ALL app data to Firestore
  Future<void> saveCompleteData(CompleteAppData data) async {
    try {
      final docId = await _documentId;
      if (docId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(_collectionName)
          .doc(docId)
          .set(data.toJson());
      
      if (kDebugMode) {
        print('✅ Complete app data saved to Firestore');
        print('   - User ID: $docId');
        print('   - ${data.fixedCosts.length} fixed costs');
        print('   - ${data.purchaseHistory.length} purchase history items');
        print('   - ${data.modifiers.length} modifiers');
        print('   - ${data.sunkCosts.length} sunk costs');
        print('   - ${data.investmentHistory.length} investment history items');
        print('   - ${data.cooldownTimers.length} active cooldowns');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving complete data to Firestore: $e');
      }
      rethrow;
    }
  }

  // Load ALL app data from Firestore
  Future<CompleteAppData?> loadCompleteData() async {
    try {
      final docId = await _documentId;
      if (docId == null) {
        if (kDebugMode) {
          print('ℹ️ User not authenticated, cannot load data');
        }
        return null;
      }

      final doc = await _firestore
          .collection(_collectionName)
          .doc(docId)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) {
          print('ℹ️ No data found for user $docId, creating default data');
        }
        return CompleteAppData.createDefault(
          deviceName: Platform.localHostname,
          platform: Platform.operatingSystem,
        );
      }

      final data = CompleteAppData.fromJson(doc.data()!);
      
      if (kDebugMode) {
        print('✅ Complete app data loaded from Firestore');
        print('   - User ID: $docId');
        print('   - ${data.fixedCosts.length} fixed costs');
        print('   - ${data.purchaseHistory.length} purchase history items');
        print('   - ${data.modifiers.length} modifiers');
        print('   - ${data.sunkCosts.length} sunk costs');
        print('   - ${data.investmentHistory.length} investment history items');
        print('   - ${data.cooldownTimers.length} active cooldowns');
        print('   - Last sync: ${data.lastSyncTime}');
      }

      return data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading complete data from Firestore: $e');
      }
      rethrow;
    }
  }

  // Check if user has existing data
  Future<bool> hasExistingData() async {
    try {
      final docId = await _documentId;
      if (docId == null) return false;

      final doc = await _firestore
          .collection(_collectionName)
          .doc(docId)
          .get();

      return doc.exists && doc.data() != null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking existing data: $e');
      }
      return false;
    }
  }

  // Delete all user data (for account deletion)
  Future<void> deleteUserData() async {
    try {
      final docId = await _documentId;
      if (docId == null) return;

      await _firestore
          .collection(_collectionName)
          .doc(docId)
          .delete();

      if (kDebugMode) {
        print('✅ User data deleted from Firestore: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting user data: $e');
      }
      rethrow;
    }
  }

  // Real-time listener for data changes
  Stream<CompleteAppData?> watchCompleteData() {
    return _authService.getCurrentUserId().asStream().asyncExpand((userId) {
      if (userId == null) {
        return Stream.value(null);
      }

      return _firestore
          .collection(_collectionName)
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (!doc.exists || doc.data() == null) {
          return CompleteAppData.createDefault(
            deviceName: Platform.localHostname,
            platform: Platform.operatingSystem,
          );
        }
        return CompleteAppData.fromJson(doc.data()!);
      });
    });
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final docId = await _documentId;
      if (docId == null) {
        return {
          'connected': false,
          'lastSync': null,
          'userId': null,
          'hasData': false,
        };
      }

      final doc = await _firestore
          .collection(_collectionName)
          .doc(docId)
          .get();

      return {
        'connected': true,
        'lastSync': doc.exists && doc.data() != null
            ? doc.data()!['lastSyncTime']
            : null,
        'userId': docId,
        'hasData': doc.exists && doc.data() != null,
      };
    } catch (e) {
      return {
        'connected': false,
        'lastSync': null,
        'userId': null,
        'hasData': false,
        'error': e.toString(),
      };
    }
  }
}
