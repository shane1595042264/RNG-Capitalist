import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/fixed_cost.dart';
import '../models/purchase_history.dart';
import '../models/dice_modifier.dart';
import '../models/sunk_cost.dart';

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
  
  // App state and settings
  final Map<String, dynamic> appSettings;
  final Map<String, DateTime> cooldownTimers;
  final Map<String, bool> modifierStates;
  final String currentPage;
  
  // Schedule and investment data
  final Map<String, dynamic> scheduleData;
  final List<Map<String, dynamic>> investmentHistory;
  final Map<String, dynamic> spinnerHistory;
  
  // Device and sync info
  final String deviceName;
  final String platform;
  final DateTime lastSyncTime;

  CompleteAppData({
    required this.lastBalance,
    required this.lastMonthSpend,
    required this.availableBudget,
    required this.remainingBudget,
    required this.fixedCosts,
    required this.purchaseHistory,
    required this.modifiers,
    required this.sunkCosts,
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
      
      // App state and settings
      'appSettings': appSettings,
      'cooldownTimers': cooldownTimers.map((key, value) => MapEntry(key, value.toIso8601String())),
      'modifierStates': modifierStates,
      'currentPage': currentPage,
      
      // Schedule and investment data
      'scheduleData': scheduleData,
      'investmentHistory': investmentHistory,
      'spinnerHistory': spinnerHistory,
      
      // Device and sync info
      'deviceName': deviceName,
      'platform': platform,
      'lastSyncTime': lastSyncTime.toIso8601String(),
      
      // Firestore metadata
      'version': '2.0',
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory CompleteAppData.fromJson(Map<String, dynamic> json) {
    return CompleteAppData(
      // Core financial data
      lastBalance: json['lastBalance']?.toString() ?? '100.0',
      lastMonthSpend: (json['lastMonthSpend'] as num?)?.toDouble() ?? 0.0,
      availableBudget: (json['availableBudget'] as num?)?.toDouble() ?? 100.0,
      remainingBudget: (json['remainingBudget'] as num?)?.toDouble() ?? 100.0,
      
      // Collections
      fixedCosts: (json['fixedCosts'] as List<dynamic>?)
          ?.map((item) => FixedCost.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      purchaseHistory: (json['purchaseHistory'] as List<dynamic>?)
          ?.map((item) => PurchaseHistory.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      modifiers: (json['modifiers'] as List<dynamic>?)
          ?.map((item) => DiceModifier.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      sunkCosts: (json['sunkCosts'] as List<dynamic>?)
          ?.map((item) => SunkCost.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      
      // App state and settings
      appSettings: (json['appSettings'] as Map<String, dynamic>?) ?? {},
      cooldownTimers: (json['cooldownTimers'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, DateTime.parse(value as String))) ?? {},
      modifierStates: (json['modifierStates'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)) ?? {},
      currentPage: json['currentPage']?.toString() ?? 'Oracle',
      
      // Schedule and investment data
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
      appSettings: {
        'theme': 'light',
        'notifications': true,
        'autoSync': true,
        'currency': 'USD',
      },
      cooldownTimers: {},
      modifierStates: {},
      currentPage: 'Oracle',
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
  static const String _collectionName = 'complete_user_data';
  
  // Generate unique user ID based on system properties
  String _generateUniqueUserId() {
    // Use a combination of system properties to create unique ID
    final String userName = Platform.environment['USERNAME'] ?? 
                           Platform.environment['USER'] ?? 
                           'unknown_user';
    final String computerName = Platform.environment['COMPUTERNAME'] ?? 
                               Platform.environment['HOSTNAME'] ?? 
                               'unknown_computer';
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create a hash of the combined info for privacy
    final String combined = '$userName-$computerName-${Platform.operatingSystem}';
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);
    
    // Use first 16 characters of hash + timestamp suffix for uniqueness
    return '${hash.toString().substring(0, 16)}_${timestamp.substring(timestamp.length - 6)}';
  }
  
  // Get or create unique document ID for this user
  String get _documentId {
    // For now, we'll use a simpler approach that's still unique per installation
    // This creates a unique ID per app installation
    final String userName = Platform.environment['USERNAME'] ?? 
                           Platform.environment['USER'] ?? 
                           'user';
    final String computerName = Platform.environment['COMPUTERNAME'] ?? 
                               Platform.environment['HOSTNAME'] ?? 
                               'device';
    final String osVersion = Platform.operatingSystemVersion;
    
    // Create hash for privacy
    final String combined = '$userName@$computerName-$osVersion';
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);
    
    return 'user_${hash.toString().substring(0, 20)}';
  }

  // Save ALL app data to Firestore
  Future<void> saveCompleteData(CompleteAppData data) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .set(data.toJson());
      
      if (kDebugMode) {
        print('✅ Complete app data saved to Firestore');
        print('   - User ID: $_documentId');
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
  Future<CompleteAppData> loadCompleteData({String? deviceName, String? platform}) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();

      if (doc.exists && doc.data() != null) {
        if (kDebugMode) {
          final data = CompleteAppData.fromJson(doc.data()!);
          print('✅ Complete app data loaded from Firestore');
          print('   - User ID: $_documentId');
          print('   - Balance: \$${data.lastBalance}');
          print('   - ${data.fixedCosts.length} fixed costs');
          print('   - ${data.purchaseHistory.length} purchase history items');
          print('   - ${data.modifiers.length} modifiers');
          print('   - ${data.sunkCosts.length} sunk costs');
          print('   - ${data.investmentHistory.length} investment history items');
          print('   - Last sync: ${data.lastSyncTime}');
          print('   - From device: ${data.deviceName} (${data.platform})');
        }
        return CompleteAppData.fromJson(doc.data()!);
      } else {
        // Return default data for new users
        if (kDebugMode) {
          print('ℹ️ No data found for user $_documentId, creating default data');
        }
        return CompleteAppData.createDefault(
          deviceName: deviceName,
          platform: platform,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading complete data from Firestore: $e');
      }
      rethrow;
    }
  }

  // Check if Firestore is connected
  Future<bool> testConnection() async {
    try {
      await _firestore.enableNetwork();
      await _firestore.collection('test').doc('connection').set({
        'timestamp': DateTime.now(),
        'message': 'Connection test successful'
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firestore connection test failed: $e');
      }
      return false;
    }
  }

  // Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'hasData': true,
          'userId': _documentId,
          'lastSyncTime': data['lastSyncTime'],
          'deviceName': data['deviceName'],
          'platform': data['platform'],
          'version': data['version'],
          'itemCounts': {
            'fixedCosts': (data['fixedCosts'] as List?)?.length ?? 0,
            'purchaseHistory': (data['purchaseHistory'] as List?)?.length ?? 0,
            'modifiers': (data['modifiers'] as List?)?.length ?? 0,
            'sunkCosts': (data['sunkCosts'] as List?)?.length ?? 0,
            'investmentHistory': (data['investmentHistory'] as List?)?.length ?? 0,
            'cooldowns': (data['cooldownTimers'] as Map?)?.length ?? 0,
          },
        };
      } else {
        return {
          'hasData': false,
          'userId': _documentId,
          'message': 'No cloud data found for this user',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting sync status: $e');
      }
      rethrow;
    }
  }

  // Delete all data (for reset/cleanup)
  Future<void> deleteAllData() async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .delete();
      
      if (kDebugMode) {
        print('✅ All app data deleted from Firestore for user $_documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting data from Firestore: $e');
      }
      rethrow;
    }
  }
}
