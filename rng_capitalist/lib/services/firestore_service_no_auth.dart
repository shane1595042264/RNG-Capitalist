import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fixed_cost.dart';
import '../models/purchase_history.dart';
import '../models/dice_modifier.dart';
import '../models/sunk_cost.dart';

// Temporary cloud data model without authentication
class AppDataCloudNoAuth {
  final double lastBalance;
  final double lastMonthSpend;
  final List<FixedCost> fixedCosts;
  final List<PurchaseHistory> purchaseHistory;
  final List<DiceModifier> modifiers;
  final List<SunkCost> sunkCosts;

  AppDataCloudNoAuth({
    required this.lastBalance,
    required this.lastMonthSpend,
    required this.fixedCosts,
    required this.purchaseHistory,
    required this.modifiers,
    required this.sunkCosts,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastBalance': lastBalance,
      'lastMonthSpend': lastMonthSpend,
      'fixedCosts': fixedCosts.map((cost) => cost.toJson()).toList(),
      'purchaseHistory': purchaseHistory.map((item) => item.toJson()).toList(),
      'modifiers': modifiers.map((modifier) => modifier.toJson()).toList(),
      'sunkCosts': sunkCosts.map((cost) => cost.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  static AppDataCloudNoAuth fromJson(Map<String, dynamic> json) {
    return AppDataCloudNoAuth(
      lastBalance: (json['lastBalance'] ?? 0.0).toDouble(),
      lastMonthSpend: (json['lastMonthSpend'] ?? 0.0).toDouble(),
      fixedCosts: (json['fixedCosts'] as List<dynamic>?)
          ?.map((item) => FixedCost.fromJson(item))
          .toList() ?? [],
      purchaseHistory: (json['purchaseHistory'] as List<dynamic>?)
          ?.map((item) => PurchaseHistory.fromJson(item))
          .toList() ?? [],
      modifiers: (json['modifiers'] as List<dynamic>?)
          ?.map((item) => DiceModifier.fromJson(item))
          .toList() ?? [],
      sunkCosts: (json['sunkCosts'] as List<dynamic>?)
          ?.map((item) => SunkCost.fromJson(item))
          .toList() ?? [],
    );
  }
}

class FirestoreServiceNoAuth {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Use a fixed document ID for testing (in real app this would be user ID)
  static const String _deviceId = 'demo-device';
  
  // Get document reference
  DocumentReference get _dataDoc => _firestore.collection('user_data').doc(_deviceId);

  // Save user data to Firestore
  Future<void> saveUserData(AppDataCloudNoAuth data) async {
    try {
      await _dataDoc.set(data.toJson());
      if (kDebugMode) {
        print('✅ Data saved to Firestore successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving data to Firestore: $e');
      }
      rethrow;
    }
  }

  // Load user data from Firestore
  Future<AppDataCloudNoAuth?> loadUserData() async {
    try {
      final doc = await _dataDoc.get();
      if (doc.exists && doc.data() != null) {
        final data = AppDataCloudNoAuth.fromJson(doc.data() as Map<String, dynamic>);
        if (kDebugMode) {
          print('✅ Data loaded from Firestore successfully');
        }
        return data;
      } else {
        if (kDebugMode) {
          print('ℹ️ No data found in Firestore');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading data from Firestore: $e');
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

  // Simple test methods for demo purposes
  Future<void> saveTestData(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('demo_data').doc('test_user').set(data);
      if (kDebugMode) {
        print('✅ Test data saved to Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving test data: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadTestData() async {
    try {
      final doc = await _firestore.collection('demo_data').doc('test_user').get();
      if (doc.exists && doc.data() != null) {
        if (kDebugMode) {
          print('✅ Test data loaded from Firestore');
        }
        return doc.data()!;
      }
      return {};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading test data: $e');
      }
      rethrow;
    }
  }
}
