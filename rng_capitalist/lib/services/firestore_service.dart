import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fixed_cost.dart';
import '../models/purchase_history.dart';
import '../models/dice_modifier.dart';
import '../models/sunk_cost.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _defaultUserId = 'default_user'; // Use a default user ID instead of auth

  // Get user document reference
  DocumentReference get _userDoc => _firestore.collection('users').doc(_defaultUserId);

  // Save user data to Firestore
  Future<void> saveUserData(AppDataCloud data) async {
    try {
      await _userDoc.set({
        'lastBalance': data.lastBalance,
        'lastMonthSpend': data.lastMonthSpend,
        'fixedCosts': data.fixedCosts.map((cost) => cost.toJson()).toList(),
        'purchaseHistory': data.purchaseHistory.map((item) => item.toJson()).toList(),
        'modifiers': data.modifiers.map((modifier) => modifier.toJson()).toList(),
        'sunkCosts': data.sunkCosts.map((cost) => cost.toJson()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
      rethrow;
    }
  }

  // Load user data from Firestore
  Future<AppDataCloud> loadUserData() async {
    try {
      final doc = await _userDoc.get();
      
      if (!doc.exists) {
        // Return default data if user document doesn't exist
        return AppDataCloud(
          lastBalance: '',
          lastMonthSpend: 0.0,
          fixedCosts: [],
          purchaseHistory: [],
          modifiers: [],
          sunkCosts: [],
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      
      return AppDataCloud(
        lastBalance: data['lastBalance'] ?? '',
        lastMonthSpend: (data['lastMonthSpend'] ?? 0.0).toDouble(),
        fixedCosts: (data['fixedCosts'] as List<dynamic>? ?? [])
            .map((json) => FixedCost.fromJson(json))
            .toList(),
        purchaseHistory: (data['purchaseHistory'] as List<dynamic>? ?? [])
            .map((json) => PurchaseHistory.fromJson(json))
            .toList(),
        modifiers: (data['modifiers'] as List<dynamic>? ?? [])
            .map((json) => DiceModifier.fromJson(json))
            .toList(),
        sunkCosts: (data['sunkCosts'] as List<dynamic>? ?? [])
            .map((json) => SunkCost.fromJson(json))
            .toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      rethrow;
    }
  }

  // Listen to user data changes in real-time
  Stream<AppDataCloud> get userDataStream {
    return _userDoc.snapshots().map((doc) {
      if (!doc.exists) {
        return AppDataCloud(
          lastBalance: '',
          lastMonthSpend: 0.0,
          fixedCosts: [],
          purchaseHistory: [],
          modifiers: [],
          sunkCosts: [],
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      
      return AppDataCloud(
        lastBalance: data['lastBalance'] ?? '',
        lastMonthSpend: (data['lastMonthSpend'] ?? 0.0).toDouble(),
        fixedCosts: (data['fixedCosts'] as List<dynamic>? ?? [])
            .map((json) => FixedCost.fromJson(json))
            .toList(),
        purchaseHistory: (data['purchaseHistory'] as List<dynamic>? ?? [])
            .map((json) => PurchaseHistory.fromJson(json))
            .toList(),
        modifiers: (data['modifiers'] as List<dynamic>? ?? [])
            .map((json) => DiceModifier.fromJson(json))
            .toList(),
        sunkCosts: (data['sunkCosts'] as List<dynamic>? ?? [])
            .map((json) => SunkCost.fromJson(json))
            .toList(),
      );
    });
  }

  // Save specific data types
  Future<void> saveLastBalance(String balance) async {
    await _userDoc.update({'lastBalance': balance});
  }

  Future<void> saveLastMonthSpend(double amount) async {
    await _userDoc.update({'lastMonthSpend': amount});
  }

  // Delete user data (for account deletion)
  Future<void> deleteUserData() async {
    try {
      await _userDoc.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user data: $e');
      }
      rethrow;
    }
  }
}

// Cloud-based data model
class AppDataCloud {
  final String lastBalance;
  final double lastMonthSpend;
  final List<FixedCost> fixedCosts;
  final List<PurchaseHistory> purchaseHistory;
  final List<DiceModifier> modifiers;
  final List<SunkCost> sunkCosts;

  AppDataCloud({
    required this.lastBalance,
    required this.lastMonthSpend,
    required this.fixedCosts,
    required this.purchaseHistory,
    required this.modifiers,
    required this.sunkCosts,
  });

  AppDataCloud copyWith({
    String? lastBalance,
    double? lastMonthSpend,
    List<FixedCost>? fixedCosts,
    List<PurchaseHistory>? purchaseHistory,
    List<DiceModifier>? modifiers,
    List<SunkCost>? sunkCosts,
  }) {
    return AppDataCloud(
      lastBalance: lastBalance ?? this.lastBalance,
      lastMonthSpend: lastMonthSpend ?? this.lastMonthSpend,
      fixedCosts: fixedCosts ?? this.fixedCosts,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      modifiers: modifiers ?? this.modifiers,
      sunkCosts: sunkCosts ?? this.sunkCosts,
    );
  }
}
